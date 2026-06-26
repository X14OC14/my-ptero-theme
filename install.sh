#!/bin/bash

# XIAOCIA Pterodactyl Theme Installer
# Based on Nightcore Theme by NoPro200 & Angelillo15

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

THEME_NAME="Pterodactyl_XIAOCIA_Theme"
PANEL_DIR="/var/www/pterodactyl"
SCRIPTS_DIR="$PANEL_DIR/resources/scripts"
BACKUP_PATH="/var/www/${THEME_NAME}_backup.tar.gz"
REPO_URL="https://github.com/X14OC14/my-ptero-theme.git" # <-- GANTI KE REPO LO

if (( $EUID != 0 )); then
    echo -e "${RED}Run as root.${RESET}"
    exit 1
fi

installTheme() {
    echo -e "${CYAN}[1/6]${RESET} Backing up panel..."
    cd /var/www/ || exit 1
    tar -czf "$BACKUP_PATH" pterodactyl
    echo -e "${GREEN}Backup saved to $BACKUP_PATH${RESET}"

    echo -e "${CYAN}[2/6]${RESET} Cloning theme..."
    cd "$PANEL_DIR" || exit 1
    rm -rf "$THEME_NAME"
    git clone "$REPO_URL" "$THEME_NAME"
    cd "$THEME_NAME" || exit 1

    echo -e "${CYAN}[3/6]${RESET} Installing theme files..."
    rm -f "$SCRIPTS_DIR/${THEME_NAME}.css"
    rm -f "$SCRIPTS_DIR/index.tsx"
    cp "${THEME_NAME}.css" "$SCRIPTS_DIR/${THEME_NAME}.css"
    cp index.tsx "$SCRIPTS_DIR/index.tsx"

    echo -e "${CYAN}[4/6]${RESET} Checking Node.js..."
    NODE_VERSION=$(node -v 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ -z "$NODE_VERSION" ]] || [[ "$NODE_VERSION" -lt 18 ]]; then
        echo -e "${YELLOW}Node.js not found or outdated. Installing Node 18...${RESET}"
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
        apt install -y nodejs
    else
        echo -e "${GREEN}Node.js v$(node -v) OK${RESET}"
    fi

    echo -e "${CYAN}[5/6]${RESET} Installing dependencies..."
    cd "$PANEL_DIR" || exit 1
    npm i -g yarn > /dev/null 2>&1
    yarn > /dev/null 2>&1

    echo -e "${CYAN}[6/6]${RESET} Building panel..."
    yarn build:production
    php artisan optimize:clear

    echo -e "\n${GREEN}Theme installed successfully!${RESET}"
}

restoreBackup() {
    if [[ ! -f "$BACKUP_PATH" ]]; then
        echo -e "${RED}No backup found at $BACKUP_PATH${RESET}"
        exit 1
    fi
    echo -e "${CYAN}Restoring backup...${RESET}"
    cd /var/www/ || exit 1
    tar -xzf "$BACKUP_PATH"
    rm "$BACKUP_PATH"
    cd "$PANEL_DIR" || exit 1
    yarn build:production
    php artisan optimize:clear
    echo -e "${GREEN}Restored!${RESET}"
}

repairPanel() {
    echo -e "${CYAN}Running repair...${RESET}"
    cd "$PANEL_DIR" || exit 1
    yarn build:production
    php artisan optimize:clear
    echo -e "${GREEN}Done.${RESET}"
}

echo ""
echo -e " ${CYAN}XIAOCIA Pterodactyl Theme${RESET}"
echo ""
echo " [1] Install theme"
echo " [2] Restore backup"
echo " [3] Repair panel"
echo " [4] Exit"
echo ""
read -rp " Choice: " choice

case $choice in
    1)
        read -rp " Install theme? [y/N] " yn
        [[ "$yn" =~ ^[Yy]$ ]] && installTheme || echo "Cancelled."
        ;;
    2) restoreBackup ;;
    3) repairPanel ;;
    4) exit 0 ;;
    *) echo "Invalid choice." ;;
esac
