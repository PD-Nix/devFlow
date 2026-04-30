Import-Module "$PSScriptRoot/GitHubClient.psm1"

function Initialize-Project {
    param($ProjectName)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $path = Join-Path $config.projectsPath $ProjectName

    if (!(Test-Path $path)) {
        Write-Host "Proyecto no existe"
        return
    }

    Push-Location $path

    # 1. Git init
    if (!(Test-Path ".git")) {
        git init
        Write-Host "Git inicializado"
    } else {
        Write-Host "Git ya existe"
    }

    # 2. Verificar remoto
    $remote = git remote

    if ($remote) {
        Write-Host "Ya existe un remoto:"
        git remote -v
        Pop-Location
        return
    }

    $repoName = Split-Path -Leaf $path

    Write-Host "`nSe creará repo en GitHub:"
    Write-Host "Nombre: $repoName"
    Write-Host ""

    $confirm = Read-Host "¿Continuar? (y/n)"

    if ($confirm -ne "y") {
        Write-Host "Cancelado"
        Pop-Location
        return
    }

    # 3. Crear repo
    try {
        $repoUrl = New-GitHubRepo -repoName $repoName
        Write-Host "Repo creado: $repoUrl"
    }
    catch {
        Write-Host "`n❌ Error creando repo en GitHub`n"

        # Status code
        if ($_.Exception.Response) {
            $status = $_.Exception.Response.StatusCode.value__
            Write-Host "Código HTTP: $status"

            # Leer body real
            if ($_.Exception.Response -and $_.Exception.Response.Content) {
            $body = $_.Exception.Response.Content.ReadAsStringAsync().Result
            Write-Host "`nDetalle:"
            Write-Host $body
}

            Write-Host "`nDetalle:"
            Write-Host $body
        }
        else {
            Write-Host $_
        }

        Pop-Location
        return
    }

    # 4. Conectar remoto
    git remote add origin $repoUrl

    # 5. Commit inicial
    $status = git status --porcelain

    if ($status) {
        git add .
        git commit -m "Initial commit DevFlow"
        Write-Host "Commit inicial creado"
    } else {
        Write-Host "No hay cambios para commit"
    }

    # 6. Push
    try {
        git branch -M main
        git push -u origin main
        if($LASTEXITCODE -eq 0){
            Write-host "✅ Proyecto inicializado y subido a GitHub"
        }else {
            Write-host "⚠️ Fallo el push"
        }
        Write-Host " Proyecto subido a GitHub"
    }
    catch {
        Write-Host " Error en push"
    }

    Pop-Location
}

Export-ModuleMember -Function Initialize-Project