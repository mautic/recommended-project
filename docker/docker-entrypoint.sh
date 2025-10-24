#!/bin/bash
################################################################################
# Mautic 6 Docker Entrypoint Script
# Handles initialization, database setup, and service startup
################################################################################

set -e

echo "=========================================="
echo "Mautic 6 Railway Deployment Starting..."
echo "=========================================="

# Set environment variables with defaults
export APP_ENV=${APP_ENV:-prod}
export PORT=${PORT:-8080}
export MAUTIC_URL=${MAUTIC_URL:-http://localhost:${PORT}}

# Function to wait for database
wait_for_database() {
    echo "Waiting for database connection..."

    # Extract database connection details from DATABASE_URL
    if [ -n "$DATABASE_URL" ]; then
        # Parse DATABASE_URL for connection test
        # Format: mysql://user:password@host:port/database
        DB_HOST=$(echo $DATABASE_URL | sed -n 's|.*@\([^:]*\):.*|\1|p')
        DB_PORT=$(echo $DATABASE_URL | sed -n 's|.*:\([0-9]*\)/.*|\1|p')

        # Wait for database to be ready (max 60 seconds)
        counter=0
        until mysql -h"$DB_HOST" -P"$DB_PORT" -e "SELECT 1" > /dev/null 2>&1 || [ $counter -eq 60 ]; do
            counter=$((counter + 1))
            echo "Waiting for database... ($counter/60)"
            sleep 1
        done

        if [ $counter -eq 60 ]; then
            echo "ERROR: Database connection timeout"
            exit 1
        fi

        echo "Database connection successful!"
    else
        echo "WARNING: DATABASE_URL not set, skipping database wait"
    fi
}

# Function to check if Mautic is installed
is_mautic_installed() {
    if [ -f "/app/docroot/app/config/local.php" ]; then
        return 0  # Installed
    else
        return 1  # Not installed
    fi
}

# Function to run database migrations
run_migrations() {
    echo "Running database migrations..."
    php /app/docroot/bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration || {
        echo "WARNING: Migration failed, but continuing..."
    }
}

# Function to clear cache
clear_cache() {
    echo "Clearing Mautic cache..."
    php /app/docroot/bin/console cache:clear --no-interaction || {
        echo "WARNING: Cache clear failed, but continuing..."
    }
}

# Function to warm up cache
warmup_cache() {
    echo "Warming up cache..."
    php /app/docroot/bin/console cache:warmup --no-interaction || {
        echo "WARNING: Cache warmup failed, but continuing..."
    }
}

# Function to generate assets
generate_assets() {
    echo "Generating assets..."
    php /app/docroot/bin/console mautic:assets:generate --no-interaction || {
        echo "WARNING: Asset generation failed, but continuing..."
    }
}

# Function to install Mautic (if needed)
install_mautic() {
    if [ "$MAUTIC_INSTALL_MODE" = "1" ]; then
        echo "Running automated Mautic installation..."

        # Create install configuration
        php /app/docroot/bin/console mautic:install \
            --db_driver=pdo_mysql \
            --db_host="$DB_HOST" \
            --db_port="$DB_PORT" \
            --db_name="$DB_NAME" \
            --db_user="$DB_USER" \
            --db_password="$DB_PASSWORD" \
            --admin_username="${MAUTIC_ADMIN_USERNAME:-admin}" \
            --admin_password="${MAUTIC_ADMIN_PASSWORD:-ChangeThisPassword123!}" \
            --admin_email="${MAUTIC_ADMIN_EMAIL:-admin@example.com}" \
            --admin_firstname="${MAUTIC_ADMIN_FIRSTNAME:-Admin}" \
            --admin_lastname="${MAUTIC_ADMIN_LASTNAME:-User}" \
            --site_url="$MAUTIC_URL" \
            --no-interaction || {
                echo "WARNING: Automated installation failed. Please use web installer."
            }

        echo "Automated installation complete!"
        echo "IMPORTANT: Set MAUTIC_INSTALL_MODE=0 in your environment variables now!"
    fi
}

# Function to set proper permissions
set_permissions() {
    echo "Setting file permissions..."
    chown -R www-data:www-data /app/docroot/media /app/var || {
        echo "WARNING: Permission setting failed, but continuing..."
    }
}

# Function to replace PORT in nginx config
configure_nginx() {
    echo "Configuring nginx for port $PORT..."
    envsubst '${PORT}' < /etc/nginx/http.d/default.conf > /etc/nginx/http.d/default.conf.tmp
    mv /etc/nginx/http.d/default.conf.tmp /etc/nginx/http.d/default.conf
}

# Main initialization sequence
echo "Step 1: Configuring services..."
configure_nginx

echo "Step 2: Waiting for database..."
wait_for_database

echo "Step 3: Setting permissions..."
set_permissions

echo "Step 4: Checking Mautic installation status..."
if is_mautic_installed; then
    echo "Mautic is already installed."

    echo "Step 5: Running migrations..."
    run_migrations

    echo "Step 6: Clearing cache..."
    clear_cache

    echo "Step 7: Warming up cache..."
    warmup_cache
else
    echo "Mautic is not installed yet."

    if [ "$MAUTIC_INSTALL_MODE" = "1" ]; then
        echo "Step 5: Running automated installation..."
        install_mautic

        echo "Step 6: Generating assets..."
        generate_assets
    else
        echo "Step 5: Skipping automated installation (MAUTIC_INSTALL_MODE not set)"
        echo "Please complete installation via web interface at: $MAUTIC_URL"
        echo "Then generate assets with: php bin/console mautic:assets:generate"
    fi
fi

echo ""
echo "=========================================="
echo "Mautic 6 Initialization Complete!"
echo "=========================================="
echo "Application URL: $MAUTIC_URL"
echo "Environment: $APP_ENV"
echo "Port: $PORT"
echo ""
echo "Starting services..."
echo "=========================================="

# Start supervisor (which manages nginx and php-fpm)
exec /usr/bin/supervisord -c /etc/supervisord.conf
