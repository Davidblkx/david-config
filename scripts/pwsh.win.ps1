#Requires -RunAsAdministrator
# ---------------------------------------------------
# Install Powershell Core in windows
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# ---------------------------------------------------

$__DIR_TEMP="$Env:TEMP\dpires-temp"

New-Item -Path "$__DIR_TEMP" -Force -ItemType "Directory" | Out-Null

#region HELPERS
Function Get-RedirectedUrl {
 
    Param (
        [Parameter(Mandatory=$true)]
        [String]$URL
    )
 
    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect=$false
    $response=$request.GetResponse()
 
    If ($response.StatusCode -eq "Found")
    {
        $response.GetResponseHeader("Location")
    }
}

Function Get-PowershellVersion {
    If((Get-RedirectedUrl -URL "https://github.com/PowerShell/PowerShell/releases/latest") -match '\d+\.\d+\.\d+') { $matches[0] }
    else { "0.0.0" }
}

Function Get-MajorVersion {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$VERSION
    )
    If ($VERSION -match '^\d+') { $Matches[0] } 
    else { "0" }
}
#endregion

$__PWSH_VERSION=Get-PowershellVersion
$__PWSH_MAJOR=(Get-MajorVersion -VERSION $__PWSH_VERSION)

Write-Output "Latest powershell version founded is $__PWSH_MAJOR ($__PWSH_VERSION)"

$__PWSH_INSTALL_PATH="$Env:ProgramFiles\PowerShell\$__PWSH_MAJOR\pwsh.exe"
$__PWSH_VALID=(Test-Path $__PWSH_INSTALL_PATH)
$__PWSH_INSTALL_VERSION=[System.Diagnostics.FileVersionInfo]::GetVersionInfo($__PWSH_INSTALL_PATH).FileVersion

If (-Not $__PWSH_VALID -and $__PWSH_INSTALL_VERSION -match $__PWSH_VERSION) {
    $__PWSH_URL="https://github.com/PowerShell/PowerShell/releases/download/v$__PWSH_VERSION/PowerShell-$__PWSH_VERSION-win-x64.msi"
    $__PWSH_OUT="$__DIR_TEMP\pwsh.exe"

    Write-Output "Downloading powershell core (v$__PWSH_VERSION)"
    Invoke-WebRequest -Uri "$__PWSH_URL" -OutFile "$__PWSH_OUT"

    Write-Output "Installing powershell core"
    Start-Process "msiexec" -Wait -ArgumentList "/i `"$__PWSH_OUT`" /q"
}

Write-Output "Powershell $__PWSH_VERSION is installed"