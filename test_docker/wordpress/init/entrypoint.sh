#!/bin/sh

echo "1) Download wordpress, please wait..."
php -d memory_limit=512M /opt/wp --allow-root core download --path=/var/www/html
echo "2) Configuring wp-config, please wait..."
php -d memory_limit=512M /opt/wp --allow-root config create --path=/var/www/html --dbname=${WORDPRESS_DB_NAME} --dbuser=${WORDPRESS_DB_USER} --dbpass=${WORDPRESS_DB_PASSWORD} --dbhost=${WORDPRESS_DB_HOST}
echo "3) Wordpress core install..."
php -d memory_limit=512M /opt/wp --allow-root core install --path=/var/www/html --admin_user=${WORDPRESS_ADMIN_USER} --admin_password=${WORDPRESS_ADMIN_PASSWORD} --url=${WORDPRESS_URL} --admin_email=${WORDPRESS_ADMIN_EMAIL} --title=${WORDPRESS_TITLE} --skip-email
echo "4) Create new user..."
php -d memory_limit=512M /opt/wp --allow-root user create ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} --role=author --path=/var/www/html --user_pass=${WORDPRESS_PASSWORD}

exec "$@"