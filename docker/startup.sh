#!/bin/bash

# Inbox SOS - Mautic 6 Startup Script for Railway.com
# This script initializes the database, runs migrations, and starts services

set -e

echo "==================================="
echo "Inbox SOS - Mautic 6 Starting Up"
echo "==================================="

# Function to wait for database to be ready
wait_for_db() {
    echo "Waiting for database to be ready..."

    # Extract database connection details from DATABASE_URL or individual env vars
    if [ -n "$DATABASE_URL" ]; then
        # Parse DATABASE_URL format: mysql://user:password@host:port/database
        DB_HOST=$(echo $DATABASE_URL | sed -n 's|.*@\([^:]*\):.*|\1|p')
        DB_PORT=$(echo $DATABASE_URL | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
    else
        DB_HOST=${MAUTIC_DB_HOST:-mysql}
        DB_PORT=${MAUTIC_DB_PORT:-3306}
    fi

    echo "Checking database connection at ${DB_HOST}:${DB_PORT}..."

    # Wait up to 60 seconds for database
    for i in {1..60}; do
        if mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" --silent 2>/dev/null; then
            echo "✓ Database is ready!"
            return 0
        fi
        echo "  Attempt $i/60: Database not ready yet, waiting..."
        sleep 1
    done

    echo "✗ ERROR: Database failed to become ready after 60 seconds"
    exit 1
}

# Function to wait for Redis to be ready (optional but recommended)
wait_for_redis() {
    if [ -n "$REDIS_URL" ]; then
        echo "Waiting for Redis to be ready..."

        # Extract Redis host from REDIS_URL
        REDIS_HOST=$(echo $REDIS_URL | sed -n 's|redis://\([^:]*\):.*|\1|p')
        REDIS_PORT=$(echo $REDIS_URL | sed -n 's|redis://[^:]*:\([0-9]*\)|\1|p')

        # Wait up to 30 seconds for Redis
        for i in {1..30}; do
            if nc -z "$REDIS_HOST" "$REDIS_PORT" 2>/dev/null; then
                echo "✓ Redis is ready!"
                return 0
            fi
            echo "  Attempt $i/30: Redis not ready yet, waiting..."
            sleep 1
        done

        echo "⚠ WARNING: Redis not available, continuing without cache"
    fi
}

# Function to generate Mautic local.php configuration
generate_local_config() {
    echo "Generating Mautic configuration..."

    LOCAL_CONFIG_PATH="/var/www/html/docroot/app/config/local.php"

    # Only generate if it doesn't exist
    if [ ! -f "$LOCAL_CONFIG_PATH" ]; then
        mkdir -p /var/www/html/docroot/app/config

        cat > "$LOCAL_CONFIG_PATH" <<'LOCALCONFIG'
<?php
// Inbox SOS - Mautic 6 Railway.com Configuration
// This file is auto-generated on first deployment

$parameters = [
    'db_driver' => 'pdo_mysql',
    'db_host' => getenv('MAUTIC_DB_HOST') ?: 'localhost',
    'db_port' => getenv('MAUTIC_DB_PORT') ?: 3306,
    'db_name' => getenv('MAUTIC_DB_NAME') ?: 'mautic',
    'db_user' => getenv('MAUTIC_DB_USER') ?: 'mautic',
    'db_password' => getenv('MAUTIC_DB_PASSWORD') ?: '',
    'db_table_prefix' => getenv('MAUTIC_DB_TABLE_PREFIX') ?: null,

    // Redis cache configuration (if available)
    'cache_adapter' => getenv('REDIS_URL') ? 'mautic.cache.adapter.redis' : 'mautic.cache.adapter.filesystem',
    'cache_prefix' => 'mautic',
    'cache_lifetime' => 86400,

    // Messenger queue configuration
    'messenger_transport_name' => getenv('REDIS_URL') ? 'redis' : 'doctrine',

    // Site URL (set by Railway)
    'site_url' => getenv('RAILWAY_PUBLIC_DOMAIN') ? 'https://' . getenv('RAILWAY_PUBLIC_DOMAIN') : getenv('MAUTIC_SITE_URL'),

    // Security
    'secret_key' => getenv('MAUTIC_SECRET_KEY') ?: bin2hex(random_bytes(32)),
    'trusted_proxies' => getenv('MAUTIC_TRUSTED_PROXIES') ? explode(',', getenv('MAUTIC_TRUSTED_PROXIES')) : null,

    // Email configuration (to be configured via UI)
    'mailer_from_name' => getenv('MAILER_FROM_NAME') ?: 'Mautic',
    'mailer_from_email' => getenv('MAILER_FROM_EMAIL') ?: 'noreply@example.com',

    // Performance optimizations
    'max_entity_lock_time' => 0,
    'default_timezone' => getenv('MAUTIC_TIMEZONE') ?: 'UTC',
    'locale' => getenv('MAUTIC_LOCALE') ?: 'en_US',

    // API settings
    'api_enabled' => true,
    'api_enable_basic_auth' => true,

    // Tracking settings
    'track_contact_by_ip' => false,
    'track_by_tracking_url' => true,

    // Image optimization
    'image_path' => 'media/images',
    'max_size' => 6,

    // Queue processing
    'queue_mode' => 'immediate_process',

    // System settings
    'update_stability' => 'stable',
];

// Parse DATABASE_URL if provided (Railway format)
if ($databaseUrl = getenv('DATABASE_URL')) {
    $url = parse_url($databaseUrl);
    $parameters['db_host'] = $url['host'] ?? 'localhost';
    $parameters['db_port'] = $url['port'] ?? 3306;
    $parameters['db_name'] = ltrim($url['path'] ?? '/mautic', '/');
    $parameters['db_user'] = $url['user'] ?? 'mautic';
    $parameters['db_password'] = $url['pass'] ?? '';
}

// Redis configuration
if ($redisUrl = getenv('REDIS_URL')) {
    $parameters['redis_host'] = parse_url($redisUrl, PHP_URL_HOST);
    $parameters['redis_port'] = parse_url($redisUrl, PHP_URL_PORT) ?: 6379;
    $parameters['redis_db'] = ltrim(parse_url($redisUrl, PHP_URL_PATH) ?: '/0', '/');
}

return $parameters;
LOCALCONFIG

        chown www-data:www-data "$LOCAL_CONFIG_PATH"
        chmod 644 "$LOCAL_CONFIG_PATH"
        echo "✓ Configuration file generated"
    else
        echo "✓ Configuration file already exists"
    fi
}

# Function to install/update database schema
setup_database() {
    echo "Setting up Mautic database..."

    # Check if database is already installed
    if php /var/www/html/bin/console mautic:install:check 2>/dev/null; then
        echo "✓ Mautic is already installed"

        # Run migrations if needed
        echo "Running database migrations..."
        php /var/www/html/bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration || true

        echo "Clearing cache..."
        php /var/www/html/bin/console cache:clear --no-warmup
        php /var/www/html/bin/console cache:warmup
    else
        echo "Installing Mautic database schema..."

        # Create database if it doesn't exist
        php /var/www/html/bin/console doctrine:database:create --if-not-exists --no-interaction || true

        # Install database schema
        php /var/www/html/bin/console mautic:install:data --no-interaction || true

        # Run migrations
        php /var/www/html/bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration || true

        echo "Clearing cache..."
        php /var/www/html/bin/console cache:clear --no-warmup
        php /var/www/html/bin/console cache:warmup

        echo "✓ Mautic database installed successfully"
        echo ""
        echo "==========================================="
        echo "IMPORTANT: Complete Setup via Web Browser"
        echo "==========================================="
        echo "Visit your Railway public URL to complete"
        echo "the Mautic setup wizard and create your"
        echo "admin account."
        echo "==========================================="
    fi
}

# Function to set proper permissions
set_permissions() {
    echo "Setting file permissions..."
    chown -R www-data:www-data /var/www/html/docroot/media /var/www/html/var || true
    chmod -R 775 /var/www/html/docroot/media /var/www/html/var || true
    echo "✓ Permissions set"
}

# Main startup sequence
echo ""
echo "Step 1: Waiting for required services..."
wait_for_db
wait_for_redis

echo ""
echo "Step 2: Generating configuration..."
generate_local_config

echo ""
echo "Step 3: Setting up database..."
setup_database

echo ""
echo "Step 4: Setting permissions..."
set_permissions

echo ""
echo "Step 5: Installing Amazon SES plugin..."
# Clone Amazon SES plugin if not already present
if [ ! -d "/var/www/html/docroot/plugins/AmazonSesBundle" ]; then
    echo "Installing Amazon SES Bundle..."
    git clone https://github.com/pm-pmaas/etailors_amazon_ses.git /var/www/html/docroot/plugins/AmazonSesBundle
    chown -R www-data:www-data /var/www/html/docroot/plugins/AmazonSesBundle
    php /var/www/html/bin/console cache:clear --no-interaction || true
    echo "✓ Amazon SES Bundle installed"
else
    echo "✓ Amazon SES Bundle already installed"
fi

echo ""
echo "==================================="
echo "✓ Inbox SOS - Mautic 6 is ready!"
echo "==================================="
echo "Starting Apache and Cron services..."
echo ""

# Start supervisord (manages Apache + cron + queue workers)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
