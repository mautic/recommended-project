# Inbox SOS - Production-Ready Mautic 6 Dockerfile for Railway.com
# Optimized for email marketers from solopreneurs to enterprises

FROM php:8.2-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions required by Mautic 6
RUN apt-get update && apt-get install -y \
    # Core utilities
    git \
    unzip \
    wget \
    curl \
    cron \
    supervisor \
    # Node.js and npm for asset building
    nodejs \
    npm \
    # Image processing
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    # Internationalization
    libicu-dev \
    # XML processing
    libxml2-dev \
    # ZIP support
    libzip-dev \
    # Database client
    default-mysql-client \
    # SSL/TLS
    ca-certificates \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
# Note: IMAP extension removed (requires unavailable packages in newer Debian)
# Modern ESPs use webhooks for bounce/complaint handling, making IMAP unnecessary
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    gd \
    intl \
    pdo_mysql \
    zip \
    opcache \
    exif

# Install Composer 2.x
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Enable Apache modules required by Mautic
RUN a2enmod rewrite headers expires deflate

# Configure PHP for production (optimized for email marketing workloads)
RUN { \
    echo 'memory_limit = 512M'; \
    echo 'upload_max_filesize = 64M'; \
    echo 'post_max_size = 64M'; \
    echo 'max_execution_time = 300'; \
    echo 'max_input_time = 300'; \
    echo 'max_input_vars = 5000'; \
    echo 'date.timezone = UTC'; \
    echo ''; \
    echo '; OPcache settings for production performance'; \
    echo 'opcache.enable = 1'; \
    echo 'opcache.memory_consumption = 256'; \
    echo 'opcache.interned_strings_buffer = 16'; \
    echo 'opcache.max_accelerated_files = 20000'; \
    echo 'opcache.validate_timestamps = 0'; \
    echo 'opcache.save_comments = 1'; \
    echo 'opcache.fast_shutdown = 1'; \
    echo ''; \
    echo '; Session settings'; \
    echo 'session.use_strict_mode = 1'; \
    echo 'session.cookie_httponly = 1'; \
    echo 'session.cookie_secure = 1'; \
    echo 'session.cookie_samesite = Lax'; \
    } > /usr/local/etc/php/conf.d/mautic-production.ini

# Copy Apache virtual host configuration
COPY docker/apache-vhost.conf /etc/apache2/sites-available/000-default.conf

# Copy supervisord configuration (runs Apache + cron)
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy Mautic cron configuration
COPY docker/mautic-cron /etc/cron.d/mautic-cron
RUN chmod 0644 /etc/cron.d/mautic-cron && crontab /etc/cron.d/mautic-cron

# Copy project files
COPY . /var/www/html/

# Install Composer dependencies (production optimized)
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Create required directories with proper permissions
RUN mkdir -p \
    docroot/media \
    docroot/translations \
    var/cache \
    var/logs \
    var/spool \
    && chown -R www-data:www-data \
    docroot/media \
    docroot/translations \
    var \
    && chmod -R 775 \
    docroot/media \
    docroot/translations \
    var

# Copy startup script
COPY docker/startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Expose port for Railway
EXPOSE 80

# Health check for Railway
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/s/health || exit 1

# Start supervisord (manages Apache + cron)
CMD ["/usr/local/bin/startup.sh"]
