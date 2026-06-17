# =============================================================================
# prompt.ps1
# Minimal prompt
# =============================================================================

function prompt {
    $path = (Get-Location).Path

    if ($path.StartsWith($HOME)) {
        $path = $path.Replace($HOME, "~")
    }

    if ($env:WORKROOT -and $path.StartsWith($env:WORKROOT)) {
        $path = $path.Replace($env:WORKROOT, "work:")
    }

    if ($env:NOTEROOT -and $path.StartsWith($env:NOTEROOT)) {
        $path = $path.Replace($env:NOTEROOT, "note:")
    }

    "PS $path> "
}
