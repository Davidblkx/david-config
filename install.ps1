#Requires -RunAsAdministrator
# ---------------------------------------------------
# Install and config my applications
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# ---------------------------------------------------
$__ROOT=(Get-Item $PSScriptRoot).ToString()
$__APPS = (Get-Content "$__ROOT/apps.json" | ConvertFrom-Json)
$__TO_INSTALL = $args[0]

# Load helper function
. "$__ROOT/scripts/pwsh.helpers.ps1"

# get os name
$__OS = Get-OSName

#region Functions
Function Get-ScriptName {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$TARGET
    )
    $PATH = "$__ROOT/install/$TARGET"
    If (-Not (Test-Path $PATH)) { $PATH="$__ROOT/install/$TARGET.$__OS.ps1" }
    If (-Not (Test-Path $PATH)) { $PATH="$__ROOT/install/$TARGET.$__OS.sh" }
    If (-Not (Test-Path $PATH)) { $PATH="$__ROOT/install/$TARGET.$__OS.fish" }
    If (-Not (Test-Path $PATH)) { $PATH="$__ROOT/install/$TARGET.$__OS.zsh" }
    If (-Not (Test-Path $PATH)) { $PATH="$__ROOT/install/$TARGET.$__OS" }
    
    If (-Not (Test-Path $PATH)) { $false }
    else { $PATH }
}

#Check if manifest is valid for current OS
Function IsValidForCurrent {
    Param (
        [Parameter(Mandatory=$true)]
        $VAL
    )

    
    if ($app -is [string]) {
        $true
    } elseif (($app -isnot [bool]) -and (($app.target -isnot [string]) -or $app.target -eq "*" -or $app.target -eq "$__OS")) {
        $true
    } else {
        $false
    }
}

Function IsAppManifest {
    Param (
        [Parameter(Mandatory=$true)]
        $VALUE
    )

    if (($VALUE -is [System.Object]) -and ($VALUE.name -is [string])) {
        $true
    } else {
        $false
    }
}

Function Find-AppByName {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$NAME
    )

    $RESULT=($false)
    foreach ($app in $__APPS) {
        if (($app -is [string]) -and $app -eq $NAME) {
            $RESULT = $app
            break
        } elseif ($app.name -eq $NAME -and (IsValidForCurrent -VAL $app)) {
            $RESULT = $app
            break
        }
    }

    $RESULT
}

Function Install-PackageManager {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$TARGET
    )

    if ($__OS -eq "win") {
        scoop install $TARGET
    } else {
        "Linux package manager not found"
    }
}

Function Install-ForScript {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$TARGET
    )

    $F = (Get-ChildItem $TARGET).Extension
    
    switch ($F) {
        ".ps1" { pwsh $TARGET }
        default { Start-Process $TARGET -Wait }
    }
}

Function Install-ForName {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$TARGET
    )

    $PATH = Get-ScriptName -TARGET $TARGET
    If ($PATH -is [string]) {
        "Running script $PATH"
        Install-ForScript -TARGET $PATH
    } else {
        "Installing package $TARGET"
        Install-PackageManager -TARGET $TARGET
    }
}

Function Install-ByManifest {
    Param(
        [Parameter(Mandatory=$true)]
        [System.Object]$VAL
    )

    $NAME = $VAL.path
    If ($NAME -isnot [string]) { $NAME = $VAL.name }

    If ($VAL.type -eq "script") {
        $PATH = Get-ScriptName -TARGET $NAME
        If ($PATH -is [string]) {
            "Running script $PATH"
            Install-ForScript -TARGET $PATH
        } else {
            "Can't find script for: $NAME"
        }
    } elseif ($VAL.type -eq "package") {
        "Installing package $TARGET"
        Install-PackageManager -TARGET $TARGET
    } elseif ($VAL.type -isnot [string]) {
        Install-ForName -TARGET $NAME
    } else {
        $VAL_TYPE = $VAL.type
        "type is not valid: $VAL_TYPE"
    }
}

Function Install-AppDeps {
    Param(
        [Parameter(Mandatory=$true)]
        [array]$DEPS
    )

    foreach ($D in $DEPS) {
        $DEP = Find-AppByName -NAME $D
        if (($DEP -isnot [bool]) -and (IsValidForCurrent -VAL $DEP)) {
            Install-App -TARGET $DEP
        } else {
            Install-ForName -TARGET $D
        }
    }
}

Function Install-App {
    Param(
        [Parameter(Mandatory=$true)]
        $TARGET
    )

    If ($TARGET -is [string]) {
        Install-ForName -TARGET $TARGET
    } elseif (IsAppManifest -VALUE $TARGET) {
        if ($TARGET.deps -is [array]) {
            Install-AppDeps -DEPS $TARGET.deps
        }
        Install-ByManifest -VAL $TARGET
    } else {
        "Can't install $TARGET"
    }
}

Function Install-Target {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$NAME
    )
    
    $APP = Find-AppByName -NAME $NAME
    if (-NOT $APP) {
        "Can't find valid app in list: $NAME"
    } elseif (IsValidForCurrent -VAL $APP) {
        Install-App -TARGET $APP
    } else {
        "Error while trying to get $NAME"
    }
}
#endregion

if ($__TO_INSTALL -is [string]) {
    "Installing $__TO_INSTALL"
    Install-Target -NAME $__TO_INSTALL
} else {
    foreach ($APP in $__APPS) {
        if (IsValidForCurrent -VAL $APP) {
            Install-App -TARGET $APP
        }
    }
}
