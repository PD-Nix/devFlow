Import-Module "$PSScriptRoot\GitManager.psm1"
Import-Module "$PSScriptRoot\Logger.psm1"
Import-Module "$PSScriptRoot\AIClient.psm1"

function Invoke-ProjectAnalysis {
    param($ProjectName)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $path = Join-Path $config.projectsPath $ProjectName

    if (!(Test-Path $path)) {
        Write-Host "Proyecto no encontrado"
        return
    }

    $status = Get-GitStatus -path $path

    if (-not $status) {
        Write-Host "No hay cambios"
        return
    }

    $files = Get-ChangedFiles -path $path

    # Filtrar archivos importantes
    $important = ($files -split "`n") | Where-Object {
        $_ -match "\.(js|ts|py|ps1|cs|java|cpp)$"
    } | Where-Object { $_ }

    if (-not $important) {
        Write-Host "No hay archivos relevantes"
        return
    }

    # Construir diff inteligente
    $diffs = New-Object System.Collections.ArrayList

    Push-Location $path

    foreach ($file in $important) {
        $fileDiff = git diff $file

        if ($fileDiff.Length -gt 1000) {
            $fileDiff = $fileDiff.Substring(0,1000)
        }

        [void]$diffs.Add("`n--- $file ---`n$fileDiff")
    }

    Pop-Location

    $diffs = $diffs -join ""
    Write-Host "Llamando IA..."

    $ai = Get-AISuggestions -diff $diffs -projectName $ProjectName -files $important

    Write-Host "Respuesta IA recibida:"
    Write-Host $ai
    

    Write-Host "Type of important: $($important.GetType().FullName)"
    Write-Host "Important: $important"
    $summary = "Cambios en: " + ($important -join ", ")
    Write-Host "$summary`n`nSugerencias IA:`n$ai"
    Write-Log `
        -project $ProjectName `
        -files $important `
        -summary $summary `
        -ai $ai

    
}

function Sync-Project {
    param($ProjectName)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $path = Join-Path $config.projectsPath $ProjectName

    Sync-Git -path $path
    Write-Host "Proyecto sincronizado"
}

Export-ModuleMember -Function Invoke-ProjectAnalysis, Sync-Project