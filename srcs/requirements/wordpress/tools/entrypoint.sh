#!/bin/bash

cd /var/www/wordpress

if [ ! -f wp-config.php ]; then

wp core download --allow-root

fi