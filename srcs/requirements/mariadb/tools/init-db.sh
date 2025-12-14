#!/bin/sh

set -e

# initialize data directory if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB data directory"
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	echo "MariaDB data directory initialized"
fi

# Check if database has been set up
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
		echo "Setting up database and users..."

		mariadbd --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 & pid=$!
		echo "Waiting for MariaDB to start..."
		for i in $(seq 1 30); do
				if mariadb-admin ping -h localhost --silent 2>/dev/null; then
						echo "MariaDB is ready!"
						break
				fi
				sleep 1
		done

		echo "Creating database: ${MYSQL_DATABASE}"
		echo "Creating user: ${MYSQL_USER}"

		mariadb -u root <<-EOSQL
				CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
				CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
				GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
				ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
				FLUSH PRIVILEGES;
EOSQL

		echo "Database setup complete!"

		mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
		wait $pid
fi

echo "Starting MariaDB server..."
# start MariaDB in the foreground
exec mariadbd --user=mysql --datadir=/var/lib/mysql
