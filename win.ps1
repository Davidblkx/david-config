#Requires -RunAsAdministrator
# ---------------------------------------------------
# Install and config windows for me
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# ---------------------------------------------------
$__ROOT=(Get-Item $PSScriptRoot).ToString()

# Environment variables for windows
$__SCRIPT="$__ROOT\install.ps1"
$__DIR_TEMP="$Env:TEMP\dpires-temp"
$__PROJECTS="$Env:HOMEDRIVE\projects"

# Prepare folders
New-Item -Path "$__DIR_TEMP" -Force -ItemType "Directory" | Out-Null
New-Item -Path "$__PROJECTS" -Force -ItemType "Directory" | Out-Null

# Install powershell core
powershell "$__ROOT\scripts\pwsh.win.ps1"

# Install scoop
If (-Not (installed scoop)) {
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# Refresh env
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Configure scoop buckets
scoop install git
scoop update
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add java

# Start installing all application in apps.json
pwsh "$__SCRIPT"