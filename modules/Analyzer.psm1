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
    $important = $files | Where-Object {
        $_ -match "\.(js|ts|py|ps1|cs|java|cpp)$"
    }

    if (-not $important) {
        Write-Host "No hay archivos relevantes"
        return
    }

    # Construir diff inteligente
    $diffs = ""

    Push-Location $path

    foreach ($file in $important) {
        $fileDiff = git diff $file

        if ($fileDiff.Length -gt 1000) {
            $fileDiff = $fileDiff.Substring(0,1000)
        }

        $diffs += "`n--- $file ---`n$fileDiff"
    }

    Pop-Location

    $ai = Get-AISuggestions -diff $diffs -projectName $ProjectName -files $important

    $log = "Cambios:`n$status`n`nSugerencias IA:`n$ai"

    Write-Log -project $ProjectName -content $log

    Write-Host $log
}

function Sync-Project {
    param($ProjectName)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $path = Join-Path $config.projectsPath $ProjectName

    Sync-Git -path $path
    Write-Host "Proyecto sincronizado"
}

Export-ModuleMember -Function Invoke-ProjectAnalysis, Sync-Project