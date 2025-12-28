#!/bin/sh

set -e

echo "Starting WordPress setup..."

# Cleanup partial downloads if wp-config.php doesn't exist
if [ ! -f /var/www/html/wp-config.php ] && [ -d /var/www/html ]; then
	echo "Cleaning up partial installation..."
	rm -rf /var/www/html/*
fi

# Wait for MariaDB to be ready
echo "Waiting for database connection..."
while ! nc -z mariadb 3306 2>/dev/null; do
	echo "Waiting for MariaDB to be ready..."
	sleep 2
done
echo "Database is ready!"

# Check if WordPress is already installed
if [ ! -f /var/www/html/wp-config.php ]; then
	echo "WordPress not found. Downloading..."

	# Download WordPress
	wp core download --allow-root --path=/var/www/html

	echo "Creating wp-config.php..."

	# Create WordPress configuration
	wp config create \
		--allow-root \
		--path=/var/www/html \
		--dbname=${WORDPRESS_DB_NAME} \
		--dbuser=${WORDPRESS_DB_USER} \
		--dbpass=${WORDPRESS_DB_PASSWORD} \
		--dbhost=${WORDPRESS_DB_HOST}

	echo "Installing WordPress..."
	# Install WordPress
	wp core install \
		--allow-root \
		--path=/var/www/html \
		--url=${DOMAIN_NAME} \
		--title="${WP_TITLE}" \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL}

	echo "Creating additional user..."
	# Create additional user
	wp user create \
		--allow-root \
		--path=/var/www/html \
		${WP_USER} \
		${WP_USER_EMAIL} \
		--role=author \
		--user_pass=${WP_USER_PASSWORD}

	echo "WordPress installation complete!"
else
	echo "WordPress already installed."
fi

# Install Redis Object Cache plugin
if ! wp plugin is-installed redis-cache --allow-root; then
	echo "Installing Redis Object Cache plugin..."
	wp plugin install redis-cache --activate --allow-root
else
	echo "Redis Object Cache plugin already installed"
	wp plugin activate redis-cache --allow-root 2>/dev/null || true
fi

# Configure Redis in wp-config.php
echo "Configuring Redis..."

# Add Redis configuration if not present
if ! grep -q "WP_REDIS_HOST" wp-config.php; then
	sed -i "/That's all, stop editing/i \\
\\
/* Redis Object Cache Configuration */\\
define ('WP_REDIS_HOST', 'redis'); \\
define ('WP_REDIS_PORT', '6379'); \\
define ('WP_REDIS_DATABASE', 0); \\
define ('WP_REDIS_TIMEOUT', 1); \\
define ('WP_REDIS_READ_TIMEOUT', 1); \\
define ('WP_CACHE', true); \\
" wp-config.php
fi

# Enable Redis Object Cache
echo "Enabling Redis Object Cache..."
wp redis enable --allow-root 2>/dev/null || true

# Set proper permissions
echo "Setting permissions..."
chown -R nobody:nobody /var/www/html

echo "Starting PHP-FPM..."
# Start PHP-FPM in foreground (php-fpm84 for PHP 8.4)
exec php-fpm84 -F
