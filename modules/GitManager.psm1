function Get-GitStatus {
    param($path)
    Push-Location $path
    try {
        $status = git status --porcelain
    } catch {
        throw "Error getting git status: $_"
    }
    Pop-Location
    return $status
}

function Get-GitDiff {
    param($path)
    Push-Location $path
    try {
        $diff = git diff
    } catch {
        throw "Error getting git diff: $_"
    }
    Pop-Location
    return $diff
}

function Get-ChangedFiles {
    param($path)

    Push-Location $path
    try {
        $files = git diff --name-only
    } catch {
        throw "Error getting changed files: $_"
    }
    Pop-Location

    return $files
}

function Sync-Git {
    param($path)

    Push-Location $path
    try {
        git add .
    } catch {
        throw "Error adding files to git: $_"
    }
    try {
        git commit -m "Auto commit DevFlow"
    } catch {
        throw "Error committing to git: $_"
    }
    try {
        git push
    } catch {
        throw "Error pushing to git: $_"
    }
    Pop-Location
}

Export-ModuleMember -Function Get-GitStatus, Get-GitDiff, Get-ChangedFiles, Sync-Git