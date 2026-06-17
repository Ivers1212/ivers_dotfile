# =============================================================================
# path.ps1
# Project / Config jumpers
# =============================================================================

function work {
    Set-Location $env:WORKROOT
}

function note {
    Set-Location $env:NOTEROOT
}

function ch395 {
    Set-Location "F:\OneDrive\00_work\CPrj_CH395-NET-SER-TTL422"
}

function sideslip {
    Set-Location "F:\OneDrive\00_work\CPrj_SideSlip"
}

function cprj {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    switch ($Name.ToLower()) {
        "ch395"    { ch395 }
        "sideslip" { sideslip }
        default    { Write-Host "Unknown project: $Name" -ForegroundColor Yellow }
    }
}

function dot {
    Set-Location "$HOME\.config"
}

function sp_shims {
    Set-Location "$HOME\scoop\shims"
}

function pconf {
    nvim "$HOME\.config\pwsh\Microsoft.PowerShell_profile.ps1"
}

function pconf_dir {
    Set-Location "$HOME\.config\pwsh"
}

function vconf {
    nvim "$HOME\.config\nvim\init.lua"
}

function wconf {
    nvim "$HOME\.config\wezterm\wezterm.lua"
}

function reload {
    . $PROFILE
    Write-Host "PowerShell profile reloaded." -ForegroundColor Green
}
