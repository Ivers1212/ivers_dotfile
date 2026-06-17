# =============================================================================
# aliases.ps1
# Linux-like helpers
# =============================================================================

function l {
    Get-ChildItem @args
}

function ll {
    Get-ChildItem -Force @args | Format-Table Mode, LastWriteTime, Length, Name
}

function la {
    Get-ChildItem -Force @args
}

function .. {
    Set-Location ..
}

function ... {
    Set-Location ../..
}

function .... {
    Set-Location ../../..
}

function tmp {
    Set-Location $env:TEMP
}

function mkcd {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location $Path
}

function touch {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$Path
    )

    foreach ($p in $Path) {
        if (Test-Path $p) {
            (Get-Item $p).LastWriteTime = Get-Date
        } else {
            New-Item -ItemType File -Path $p | Out-Null
        }
    }
}

function rmrf {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$Path
    )

    Remove-Item -Recurse -Force -Path $Path
}

function rmrfq {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$Path
    )

    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path $Path
}

function which {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    Get-Command $Name -ErrorAction SilentlyContinue
}

function open {
    param(
        [string]$Path = "."
    )

    Invoke-Item $Path
}

function cdlatest {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern
    )

    $target = Get-ChildItem -Directory -Path $Pattern |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($null -eq $target) {
        Write-Host "No directory matched: $Pattern" -ForegroundColor Yellow
        return
    }

    Set-Location $target.FullName
}

function croot {
    $root = git rev-parse --show-toplevel 2>$null

    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($root)) {
        Write-Host "Not inside a git repository." -ForegroundColor Yellow
        return
    }

    Set-Location $root
}
