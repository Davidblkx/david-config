$__SCRIPTS = (Get-Item $PSScriptRoot).Parent.ToString() + "/scripts"
$__DIR_TEMP="$Env:TEMP\dpires-temp"
$__OUT="$__DIR_TEMP\edge.exe"

$__INSTALL_PATH="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$IsInstalled = Test-Path $__INSTALL_PATH

If (-Not $IsInstalled) {
    . "$__SCRIPTS/pwsh.helpers.ps1"

    $BASE_URL = "https://go.microsoft.com/fwlink/?linkid=2108834&Channel=Stable&language=en-gb"
    $URL = Get-RedirectedUrl $BASE_URL

    Write-Output "Downloading Edge browser"
    Invoke-WebRequest -Uri "$URL" -OutFile "$__OUT"

    Write-Output "Installing Edge"
    Start-Process $__OUT
}