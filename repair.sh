#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit 1
fi

PANEL_DIR="/var/www/pterodactyl"

repairPanel() {
    echo "Putting panel in maintenance mode..."
    cd "$PANEL_DIR" || exit 1
    php artisan down

    echo "Downloading latest panel release..."
    curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv

    chmod -R 755 storage/* bootstrap/cache

    echo "Installing composer dependencies..."
    composer install --no-dev --optimize-autoloader

    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force

    chown -R www-data:www-data /var/www/pterodactyl/*

    php artisan queue:restart
    php artisan up

    echo "Panel repaired. Re-apply theme manually with install.sh."
}

read -rp "This will reset panel resources to default. Continue? [y/N] " yn
[[ "$yn" =~ ^[Yy]$ ]] && repairPanel || echo "Cancelled."
