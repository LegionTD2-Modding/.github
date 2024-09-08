#!/bin/bash

set -e

find_game_folder() {
    local steam_path="$HOME/.steam/steam"
    local game_path="$steam_path/steamapps/common/Legion TD 2"
    
    if [ ! -d "$game_path" ]; then
        echo "Legion TD 2 folder not found in the default Steam location."
        read -e -p "Please enter the full path to your Legion TD 2 game folder: " -i "$game_path" game_path
        
        if [ ! -d "$game_path" ]; then
            echo "Error: The provided path does not exist or is not a directory."
            exit 1
        fi
    fi
    
    echo "$game_path"
}

GAME_FOLDER=$(find_game_folder)

REMOVE_LIST=(
    "BepInEx"
    ".doorstop_version"
    "changelog.txt"
    "winhttp.dll"
    "doorstop_config.ini"
)

for item in "${REMOVE_LIST[@]}"; do
    full_path="$GAME_FOLDER/$item"
    if [ -e "$full_path" ]; then
        echo "Removing: $full_path"
        if [ -d "$full_path" ]; then
            rm -rf "$full_path"
        else
            rm -f "$full_path"
        fi
    else
        echo "Not found, skipping: $full_path"
    fi
done

echo "Uninstallation complete. The mod manager and its components have been removed from: $GAME_FOLDER"
echo "If you want to completely reset your game, you might consider verifying the game files through Steam."
