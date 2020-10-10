param (
    [Parameter(Mandatory=$true)]
    [string]$Name
)

$__ROOT=(Get-Item $PSScriptRoot).ToString()

# Load helper function
. "$__ROOT/pwsh.helpers.ps1"

# get os name
$__OS = Get-OSName

if ($__OS -eq "win") {
    scoop install $Name
} else {
    "Linux package manager not found"
}