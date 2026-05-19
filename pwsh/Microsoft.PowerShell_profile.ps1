# =============================================================================
# PowerShell Profile for Ivers
# Location: ~/.config/pwsh/profile.ps1
# =============================================================================

# -----------------------------------------------------------------------------
# 基础：编码 / 交互体验
# -----------------------------------------------------------------------------

# 统一 UTF-8，减少中文乱码概率
[Console]::InputEncoding  = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

# -----------------------------------------------------------------------------
# 常用路径
# -----------------------------------------------------------------------------

$env:DOTFILES = "$HOME\.config"
$env:WORKROOT = "F:\OneDrive\00_work"
$env:NOTEROOT = "F:\OneDrive\00_Obsidian@simpread\note"
    

# 给工作目录挂一个短盘符，后面可以直接：
#   cd work:
#   cd work:\CPrj_CH395-NET-SER-TTL422
if (-not (Get-PSDrive -Name work -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name work -PSProvider FileSystem -Root $env:WORKROOT -Scope Global | Out-Null
}

#   cd note:
#   cd note:\00_logs
if (-not (Get-PSDrive -Name note -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name note -PSProvider FileSystem -Root $env:NOTEROOT -Scope Global | Out-Null
}
# -----------------------------------------------------------------------------
# 快捷函数：工程跳转
# -----------------------------------------------------------------------------

function ch395 {
    Set-Location "F:\OneDrive\00_work\CPrj_CH395-NET-SER-TTL422"
}

function sideslip {
    Set-Location "F:\OneDrive\00_work\CPrj_SideSlip"
}

function note {
    Set-Location $env:NOTEROOT
}

function work {
    Set-Location $env:WORKROOT
}

# 通用工程跳转器
# 用法：
#   cprj ch395
#   cprj sideslip
function cprj {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    switch ($Name.ToLower()) {
        "ch395"    { Set-Location "F:\OneDrive\00_work\CPrj_CH395-NET-SER-TTL422" }
        "sideslip" { Set-Location "F:\OneDrive\00_work\CPrj_SideSlip" }
        default    { Write-Host "Unknown project: $Name" -ForegroundColor Yellow }
    }
}

# -----------------------------------------------------------------------------
# 快捷函数：配置文件直达
# -----------------------------------------------------------------------------

function pconf {
    nvim "$HOME\.config\pwsh\profile.ps1"
}

function vconf {
    nvim "$HOME\.config\nvim\init.lua"
}

function wconf {
    nvim "$HOME\.config\wezterm\wezterm.lua"
}

function dot {
    Set-Location "$HOME\.config"
}

function scoop {
    Set-Location "$HOME\scoop\shims"
}
# -----------------------------------------------------------------------------
# 快捷函数：立即重载
# -----------------------------------------------------------------------------

function reload {
    . $PROFILE
    Write-Host "PowerShell profile reloaded." -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# 常用小工具
# -----------------------------------------------------------------------------

function ll {
    Get-ChildItem -Force
}

function la {
    Get-ChildItem -Force -Hidden
}

function touch {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path | Out-Null
    }
}

function mkcd {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location $Path
}

function which {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )
    Get-Command $Name -ErrorAction SilentlyContinue
}

# -----------------------------------------------------------------------------
# 搜索增强：有 rg / fd 就用，没有就跳过
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# Git 小助手
# -----------------------------------------------------------------------------

function gs { git status }
function ga { git add . }
function gcmsg {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message
    )
    git commit -m $Message
}
function gpush { git push }
function gl { git log --oneline --graph --decorate -20 }

# -----------------------------------------------------------------------------
# CMake / Ninja 小助手
# -----------------------------------------------------------------------------

function bld {
    if (Test-Path ".\build") {
        cmake --build .\build
    } else {
        Write-Host "build directory not found." -ForegroundColor Yellow
    }
}

function cfg-ninja {
    cmake -S . -B build -G Ninja
}

# -----------------------------------------------------------------------------
# PSReadLine：命令行体验增强
# -----------------------------------------------------------------------------

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -BellStyle None

    # 上下方向键搜历史里“当前已输入前缀”的命令
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Ctrl+d 删除字符；列表为空时退出 shell
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
}

# -----------------------------------------------------------------------------
# Prompt：别太花，路径尽量短一点
# -----------------------------------------------------------------------------

function prompt {
    $path = (Get-Location).Path

    if ($path.StartsWith($HOME)) {
        $path = $path.Replace($HOME, "~")
    }

    if ($path.StartsWith($env:WORKROOT)) {
        $path = $path.Replace($env:WORKROOT, "work:")
    }


    if ($path.StartsWith($env:NOTEROOT)) {
        $path = $path.Replace($env:NOTEROOT, "note:")
    }
    "PS $path> "
}
