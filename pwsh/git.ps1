# =============================================================================
# git.ps1
# Git helpers
# =============================================================================

function gs {
    git status
}

function ga {
    git add @args
}

function gaa {
    git add -A
}

function gcmsg {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message
    )

    git commit -m $Message
}

function gpush {
    git push @args
}

function gpull {
    git pull @args
}

function gl {
    git log --oneline --graph --decorate -20
}

function glog {
    git log --oneline --graph --decorate --all
}

function gd {
    git diff @args
}

function gds {
    git diff --staged @args
}

function gb {
    git branch @args
}

function gsw {
    git switch @args
}

function gco {
    git checkout @args
}

function grs {
    git restore @args
}

function grst {
    git restore --staged @args
}

function grm {
    git rm -r -- @args
}

function gclean {
    git clean -fdx
}

function gfetch {
    git fetch @args
}

function grv {
    git remote -v
}
