#!/bin/bash

echo "COnfiguring the website..."
wp core install  --path=/var/www/html --title="${WORDPRESS_TITLE}" --admin_user="${WORDPRESS_ADMIN_USER}" --admin_password="${WORDPRESS_ADMIN_PASSWORD}" --url="${WORDPRESS_URL}" --admin_email="${WORDPRESS_ADMIN_EMAIL}" --title="${WORDPRESS_TITLE}" --skip-email
echo "Add a new user..."
wp user create   --path=/var/www/html ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} --role=author --user_pass=${WORDPRESS_PASSWORD}