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
	       --dbhost=mariadb:3306

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

# Set proper permissions
chown -R nobody:nobody /var/www/html

echo "Starting PHP-FPM..."
# Start PHP-FPM in foreground (php-fpm83 for PHP 8.3)
exec php-fpm83 -F
