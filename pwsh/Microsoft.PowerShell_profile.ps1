# =============================================================================
# PowerShell Profile for Ivers
# Real entry: ~/.config/pwsh/Microsoft.PowerShell_profile.ps1
# =============================================================================

$PwshConfigHome = "$HOME\.config\pwsh"

$ProfileModules = @(
    "env.ps1",
    "path.ps1",
    "aliases.ps1",
    "git.ps1",
    "cmake.ps1",
    "search.ps1",
    "psreadline.ps1",
    "prompt.ps1"
)

foreach ($module in $ProfileModules) {
    $modulePath = Join-Path $PwshConfigHome $module

    if (Test-Path $modulePath) {
        . $modulePath
    } else {
        Write-Host "Profile module missing: $modulePath" -ForegroundColor Yellow
    }
}
