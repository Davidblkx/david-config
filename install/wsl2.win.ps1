Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

$__SCRIPTS = (Get-Item $PSScriptRoot).Parent.ToString() + "/scripts"
$__DIR_TEMP="$Env:TEMP\dpires-temp"
$__OUT="$__DIR_TEMP\kernel.exe"

. "$__SCRIPTS/pwsh.helpers.ps1"

#region Kernel
$BASE_URL = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$URL = Get-RedirectedUrl $BASE_URL

Write-Output "Downloading x64 Kernel"
Invoke-WebRequest -Uri "$URL" -OutFile "$__OUT"

Write-Output "Installing Kernel"
Start-Process "msiexec" -Wait -ArgumentList "/i `"$__OUT`""
Update-Env
#endregion

wsl --set-default-version 2

Start-Process "https://www.microsoft.com/pt-pt/p/debian/9msvkqc78pk6?rtc=1&activetab=pivot:overviewtab"

"Wait for Debian to install"
Pause
