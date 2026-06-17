# =============================================================================
# env.ps1
# Encoding / Environment / PSDrive
# =============================================================================

[Console]::InputEncoding  = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$env:DOTFILES = "$HOME\.config"
$env:WORKROOT = "F:\OneDrive\00_work"
$env:NOTEROOT = "F:\OneDrive\00_Obsidian@simpread\note"

if (-not (Get-PSDrive -Name work -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name work -PSProvider FileSystem -Root $env:WORKROOT -Scope Global | Out-Null
}

if (-not (Get-PSDrive -Name note -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name note -PSProvider FileSystem -Root $env:NOTEROOT -Scope Global | Out-Null
}
