
$__DIR_TEMP="$Env:TEMP\dpires-temp"

git clone https://github.com/tj/git-extras.git "$__DIR_TEMP"

Push-Location -Path "$__DIR_TEMP\git-extras"

.\install.cmd

Pop-Location