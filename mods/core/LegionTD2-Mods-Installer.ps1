function Download-File {
    param(
        [string]$Url,
        [string]$OutputFile
    )
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($Url, $OutputFile)
}

function Extract-Zip {
    param(
        [string]$ZipFile,
        [string]$Destination
    )
    Expand-Archive -Path $ZipFile -DestinationPath $Destination -Force
}

function Read-HostWithCompletion {
    param(
        [string]$Prompt,
        [string]$DefaultPath
    )
    $prevPath = Get-Location
    try {
        Set-Location $DefaultPath
        $userInput = Read-Host -Prompt $Prompt
        if ([string]::IsNullOrWhiteSpace($userInput)) {
            return $DefaultPath
        }
        return $userInput
    }
    finally {
        Set-Location $prevPath
    }
}

$configUrl = "https://raw.githubusercontent.com/LegionTD2-Modding/.github/main/mods/config.json"
$configFile = "config.json"
Download-File -Url $configUrl -OutputFile $configFile

$config = Get-Content $configFile | ConvertFrom-Json
$coreVersion = $config.core.version
$coreUrl = $config.core.url.'*' -replace '\$', $coreVersion
$dependenciesUrl = $config.core.dependancies[0].'*'

$coreZip = "ModsGate.zip"
$dependenciesZip = "Core.zip"
Download-File -Url $coreUrl -OutputFile $coreZip
Download-File -Url $dependenciesUrl -OutputFile $dependenciesZip

$steamPath = "C:\Program Files (x86)\Steam"
$gamePath = Join-Path $steamPath "steamapps\common\Legion TD 2"

if (-not (Test-Path $gamePath)) {
    Write-Host "Legion TD 2 folder not found in the default Steam location."
    $gamePath = Read-HostWithCompletion -Prompt "Please enter the full path to your Legion TD 2 game folder" -DefaultPath $gamePath
    
    if (-not (Test-Path $gamePath)) {
        Write-Host "Error: The provided path does not exist or is not a directory."
        exit 1
    }
}

Extract-Zip -ZipFile $dependenciesZip -Destination $gamePath

$tempDir = Join-Path $env:TEMP "ModsGateTemp"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
Extract-Zip -ZipFile $coreZip -Destination $tempDir
$pluginsDir = Join-Path $gamePath "BepInEx\plugins"
New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null
Get-ChildItem -Path $tempDir -Recurse -Filter "*.dll" | Move-Item -Destination $pluginsDir -Force

Remove-Item $configFile, $coreZip, $dependenciesZip
Remove-Item -Recurse -Force $tempDir

Write-Host "Installation complete! Mods have been installed to: $gamePath"
