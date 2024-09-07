#!/bin/bash

download_file() {
    if command -v curl &> /dev/null; then
        curl -L -o "$2" "$1"
    elif command -v wget &> /dev/null; then
        wget -O "$2" "$1"
    else
        echo "Error: Neither curl nor wget is installed. Please install one of them and try again."
        exit 1
    fi
}

config_url="https://raw.githubusercontent.com/LegionTD2-Modding/.github/main/mods/config.json"
config_file="config.json"
download_file "$config_url" "$config_file"

if command -v jq &> /dev/null; then
    installer_url=$(jq -r '.core.installers.linux' "$config_file")
else
    echo "Error: jq is not installed. Please install jq and try again."
    exit 1
fi

installer_file="LegionTD2-Mods-Installer.sh"
download_file "$installer_url" "$installer_file"

chmod +x "$installer_file"

./"$installer_file"

rm "$config_file" "$installer_file"

echo "Installation complete!"
