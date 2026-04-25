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

    git add .

    # evitar commit vacío
    $status = git status --porcelain
    if (-not $status) {
        Write-Host "No hay cambios para commit"
        Pop-Location
        return
    }

    git commit -m "Auto commit DevFlow"

    # verificar si existe remoto
    $remote = git remote

    if (-not $remote) {
        Write-Host "No hay remoto configurado"
        Write-Host "Configura uno con:"
        Write-Host "git remote add origin https://github.com/USUARIO/$((Split-Path -Leaf $path)).git"
    }
    else {
        try {
            git push
        } catch {
            git push -u origin main
        }
    }

    Pop-Location
}
Export-ModuleMember -Function Get-GitStatus, Get-GitDiff, Get-ChangedFiles, Sync-Git