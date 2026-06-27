#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit 1
fi

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

REPO="https://github.com/X14OC14/my-ptero-theme"
THEME_NAME="my-ptero-theme"
PANEL_DIR="/var/www/pterodactyl"
SCRIPTS_DIR="$PANEL_DIR/resources/scripts"
BACKUP_FILE="/var/www/${THEME_NAME}_backup.tar.gz"

installTheme() {
    echo -e "${CYAN}[1/7]${RESET} Backing up panel..."
    cd /var/www/ || exit 1
    tar -czf "$BACKUP_FILE" pterodactyl
    echo -e "${GREEN}Backup saved to $BACKUP_FILE${RESET}"

    echo -e "${CYAN}[2/7]${RESET} Cloning theme..."
    cd "$PANEL_DIR" || exit 1
    rm -rf "$THEME_NAME"
    git clone "$REPO" "$THEME_NAME"
    cd "$THEME_NAME" || exit 1

    echo -e "${CYAN}[3/7]${RESET} Installing theme files..."
    rm -f "$SCRIPTS_DIR/Pterodactyl_XIAOCIA_Theme.css"
    rm -f "$SCRIPTS_DIR/index.tsx"
    cp Pterodactyl_XIAOCIA_Theme.css "$SCRIPTS_DIR/Pterodactyl_XIAOCIA_Theme.css"
    cp index.tsx "$SCRIPTS_DIR/index.tsx"

    echo -e "${CYAN}[4/7]${RESET} Checking Node.js..."
    NODE_VERSION=$(node -v 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ -z "$NODE_VERSION" ]] || [[ "$NODE_VERSION" -lt 22 ]]; then
        echo -e "${YELLOW}Node.js not found or outdated (found: v${NODE_VERSION}). Installing Node 22...${RESET}"
        apt remove nodejs -y > /dev/null 2>&1
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash - > /dev/null 2>&1
        apt install -y nodejs > /dev/null 2>&1
        echo -e "${GREEN}Node.js $(node -v) installed${RESET}"
    else
        echo -e "${GREEN}Node.js v$(node -v) OK${RESET}"
    fi

    echo -e "${CYAN}[5/7]${RESET} Installing dependencies..."
    cd "$PANEL_DIR" || exit 1
    npm i -g yarn > /dev/null 2>&1
    yarn > /dev/null 2>&1

    echo -e "${CYAN}[6/7]${RESET} Building panel..."
    export NODE_OPTIONS=--openssl-legacy-provider
    yarn build:production
    
    echo -e "${CYAN}[7/7]${RESET} Optimizing..."
    php artisan optimize:clear

    echo -e "\n${GREEN}Theme installed successfully!${RESET}"
}

restoreBackup() {
    if [[ ! -f "$BACKUP_FILE" ]]; then
        echo -e "${RED}No backup found at $BACKUP_FILE${RESET}"
        exit 1
    fi
    echo -e "${CYAN}Restoring backup...${RESET}"
    cd /var/www/ || exit 1
    tar -xzf "$BACKUP_FILE"
    rm "$BACKUP_FILE"
    cd "$PANEL_DIR" || exit 1
    export NODE_OPTIONS=--openssl-legacy-provider
    yarn build:production
    php artisan optimize:clear
    echo -e "${GREEN}Restored successfully!${RESET}"
}

repairPanel() {
    echo -e "${CYAN}Downloading repair script...${RESET}"
    curl -s "$REPO/raw/main/repair.sh" -o /tmp/ptero_repair.sh
    bash /tmp/ptero_repair.sh
    rm /tmp/ptero_repair.sh
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
