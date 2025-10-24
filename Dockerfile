################################################################################
# Mautic 6 Production Dockerfile for Railway.app
# Optimized for performance, security, and ease of deployment
################################################################################

FROM php:8.3-fpm-alpine AS base

# Set working directory
WORKDIR /app

# Install system dependencies and PHP extensions required by Mautic 6
RUN apk add --no-cache \
    # Core utilities
    bash \
    curl \
    git \
    unzip \
    nginx \
    supervisor \
    # Image processing
    imagemagick \
    imagemagick-dev \
    # Database clients
    mysql-client \
    # Build dependencies (will be removed later)
    $PHPIZE_DEPS \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        mysqli \
        zip \
        intl \
        mbstring \
        xml \
        soap \
        bcmath \
        opcache \
    && pecl install imagick redis \
    && docker-php-ext-enable imagick redis \
    && apk del $PHPIZE_DEPS

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install Node.js and npm
RUN apk add --no-cache nodejs npm

# Configure PHP for production
RUN { \
    echo 'memory_limit = 512M'; \
    echo 'max_execution_time = 300'; \
    echo 'upload_max_filesize = 64M'; \
    echo 'post_max_size = 64M'; \
    echo 'max_input_vars = 10000'; \
    echo 'date.timezone = UTC'; \
    echo 'expose_php = Off'; \
    } > /usr/local/etc/php/conf.d/mautic.ini

# Configure PHP OpCache for optimal performance
RUN { \
    echo 'opcache.enable = 1'; \
    echo 'opcache.enable_cli = 1'; \
    echo 'opcache.memory_consumption = 256'; \
    echo 'opcache.interned_strings_buffer = 16'; \
    echo 'opcache.max_accelerated_files = 20000'; \
    echo 'opcache.validate_timestamps = 0'; \
    echo 'opcache.save_comments = 1'; \
    echo 'opcache.fast_shutdown = 1'; \
    } > /usr/local/etc/php/conf.d/opcache.ini

################################################################################
# Build stage - Install dependencies
################################################################################
FROM base AS builder

# Copy composer files
COPY composer.json composer.lock* /app/

# Install Composer dependencies
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-progress \
    --no-scripts \
    --prefer-dist

# Copy package files for Node.js
COPY package*.json /app/

# Install Node.js dependencies
RUN npm ci --prefer-offline --no-audit

################################################################################
# Production stage
################################################################################
FROM base AS production

# Copy vendor and node_modules from builder
COPY --from=builder /app/vendor /app/vendor
COPY --from=builder /app/node_modules /app/node_modules

# Copy application files
COPY . /app/

# Set up nginx configuration
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# Set up PHP-FPM configuration
COPY docker/php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf

# Set up Supervisor configuration
COPY docker/supervisor/supervisord.conf /etc/supervisord.conf

# Copy entrypoint script
COPY docker/docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Create necessary directories and set permissions
RUN mkdir -p \
    /app/docroot/media \
    /app/docroot/media/files \
    /app/docroot/media/images \
    /app/var/cache \
    /app/var/logs \
    /app/var/spool \
    /run/nginx \
    /run/php-fpm \
    && chown -R www-data:www-data \
        /app/docroot/media \
        /app/var \
        /run/nginx \
        /run/php-fpm

# Generate assets (if possible at build time)
RUN composer run-script post-install-cmd || echo "Assets will be generated at runtime"

# Expose port for Railway
ENV PORT=8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD curl -f http://localhost:8080/s/login || exit 1

# Use supervisor to manage nginx and php-fpm
CMD ["/app/docker-entrypoint.sh"]
