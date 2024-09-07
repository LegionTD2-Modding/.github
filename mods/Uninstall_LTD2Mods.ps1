function Find-GameFolder {
    $steamPath = "C:\Program Files (x86)\Steam"
    $gamePath = Join-Path $steamPath "steamapps\common\Legion TD 2"
    
    if (-not (Test-Path $gamePath)) {
        Write-Host "Legion TD 2 folder not found in the default Steam location."
        $gamePath = Read-Host "Please enter the full path to your Legion TD 2 game folder"
        
        if (-not (Test-Path $gamePath)) {
            Write-Host "Error: The provided path does not exist or is not a directory."
            exit 1
        }
    }
    
    return $gamePath
}

$gameFolder = Find-GameFolder

$removeList = @(
    "BepInEx",
    ".doorstop_version",
    "changelog.txt",
    "winhttp.dll",
    "doorstop_config.ini"
)

foreach ($item in $removeList) {
    $fullPath = Join-Path $gameFolder $item
    if (Test-Path $fullPath) {
        Write-Host "Removing: $fullPath"
        if (Test-Path $fullPath -PathType Container) {
            Remove-Item -Path $fullPath -Recurse -Force
        } else {
            Remove-Item -Path $fullPath -Force
        }
    } else {
        Write-Host "Not found, skipping: $fullPath"
    }
}

Write-Host "Uninstallation complete. The mod manager and its components have been removed from: $gameFolder"
Write-Host "If you want to completely reset your game, you might consider verifying the game files through Steam."
