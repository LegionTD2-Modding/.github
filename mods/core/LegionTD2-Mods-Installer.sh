#!/bin/bash

set -e

REQUIRED_DEPS=(curl jq unzip protontricks)

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_missing_dependencies() {
  local missing_deps=()

  for dep in "${REQUIRED_DEPS[@]}"; do
    if ! command_exists "$dep"; then
      missing_deps+=("$dep")
    fi
  done

  if [ ${#missing_deps[@]} -eq 0 ]; then
    return
  fi

  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
    ubuntu | debian)
      sudo apt-get update
      sudo apt-get install -y "${missing_deps[@]}"
      ;;
    fedora | centos | rhel)
      sudo dnf install -y "${missing_deps[@]}"
      ;;
    arch | manjaro)
      sudo pacman -Sy --needed "${missing_deps[@]}"
      ;;
    *)
      echo "Unsupported distribution. Please install ${missing_deps[*]} manually."
      exit 1
      ;;
    esac
  else
    echo "Unable to detect the distribution. Please install ${missing_deps[*]} manually."
    exit 1
  fi
}

install_missing_dependencies

download_file() {
  curl -L -o "$2" "$1"
}

download_binary_file() {
  curl -L --remote-name-all -O "$1"
}

extract_zip() {
  unzip -o "$1" -d "$2"
}

restart_steam() {
  echo "Restarting Steam to apply the changes..."
  steam steam://flushconfig
  steam steam://exit
}

config_url="https://raw.githubusercontent.com/LegionTD2-Modding/.github/main/mods/config.json"
config_file="config.json"
download_file "$config_url" "$config_file"

core_version=$(jq -r '.core.version' "$config_file")
core_url=$(jq -r '.core.url["*"]' "$config_file" | sed "s/\\\$/${core_version}/")
dependencies_url=$(jq -r '.core.dependancies[0]["*"]' "$config_file")

core_zip="ModsGate.zip"
dependencies_zip="Core.zip"

download_binary_file "$core_url"
download_binary_file "$dependencies_url"

if [ ! -f "$core_zip" ] || [ ! -f "$dependencies_zip" ]; then
  echo "Error: Failed to download one or both zip files."
  exit 1
fi

file "$core_zip"
file "$dependencies_zip"

steam_path="$HOME/.steam/steam"
game_path="$steam_path/steamapps/common/Legion TD 2"
APP_ID="469600"

if [ ! -d "$game_path" ]; then
  echo "Legion TD 2 folder not found in the default Steam location."
  read -e -p "Please enter the full path to your Legion TD 2 game folder: " -i "$game_path" game_path

  if [ ! -d "$game_path" ]; then
    echo "Error: The provided path does not exist or is not a directory."
    exit 1
  fi
fi

extract_zip "$dependencies_zip" "$game_path"

temp_dir=$(mktemp -d)
extract_zip "$core_zip" "$temp_dir"
plugins_dir="$game_path/BepInEx/plugins"
mkdir -p "$plugins_dir"
find "$temp_dir" -name "*.dll" -exec mv {} "$plugins_dir" \;

rm "$core_zip" "$dependencies_zip"
rm -rf "$temp_dir"

echo "Installation complete! Mods have been installed to: $game_path"

# Use Protontricks to configure winhttp library override for the game
echo "Configuring Protontricks for Legion TD 2..."
protontricks "$APP_ID" win10
WINEPREFIX="$HOME/.steam/steam/steamapps/compatdata/$APP_ID/pfx" WINEARCH=win64 winecfg -v winhttp.dll

# Apply winhttp override in winecfg
WINEPREFIX="$HOME/.steam/steam/steamapps/compatdata/$APP_ID/pfx" winecfg -v winhttp.dll

# Force Steam to use Proton Experimental for Legion TD 2
echo "Forcing Proton Experimental for Legion TD 2..."
# Create or modify Steam compatibility file
mkdir -p "$HOME/.steam/steam/steamapps/compatdata/$APP_ID"
echo '{ "compat_tool": "proton_experimental" }' >"$HOME/.steam/steam/steamapps/compatdata/$APP_ID/compatibilitytool.vdf"

restart_steam

echo "Protontricks configuration complete. Launch Legion TD 2 from Steam."
