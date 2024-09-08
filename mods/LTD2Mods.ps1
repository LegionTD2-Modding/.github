function Download-File {
    param(
        [string]$Url,
        [string]$OutputFile
    )
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($Url, $OutputFile)
}

$configUrl = "https://raw.githubusercontent.com/LegionTD2-Modding/.github/main/mods/config.json"
$configFile = "config.json"
Download-File -Url $configUrl -OutputFile $configFile

$config = Get-Content $configFile | ConvertFrom-Json
$installerUrl = $config.core.installers.win

$installerFile = "LegionTD2-Mods-Installer.ps1"
Download-File -Url $installerUrl -OutputFile $installerFile

Start-Process msiexec.exe -Wait -ArgumentList "/i $installerFile /qn"

Remove-Item $configFile
Remove-Item $installerFile

Write-Host "Installation complete!"
