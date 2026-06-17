# =============================================================================
# search.ps1
# rg / fd helpers
# =============================================================================

function ff {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern
    )

    if (Get-Command rg -ErrorAction SilentlyContinue) {
        rg --line-number --hidden --glob '!.git' $Pattern
    } else {
        Write-Host "rg not found." -ForegroundColor Yellow
    }
}

function ffile {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern
    )

    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd $Pattern
    } else {
        Get-ChildItem -Recurse -File | Where-Object { $_.Name -match $Pattern }
    }
}

function grep {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern,

        [string[]]$Path = @(".")
    )

    Select-String -Pattern $Pattern -Path $Path
}

function grepr {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern,

        [string]$Path = "."
    )

    Get-ChildItem -Recurse -File $Path | Select-String -Pattern $Pattern
}
