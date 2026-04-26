function Write-Log {
    param(
        $project,
        $files,
        $summary,
        $ai
    )

    $logDir = "$PSScriptRoot/../data/logs"
    $logFile = "$logDir/$project.json"

    if (!(Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }

    # Crear entrada
    $entry = [PSCustomObject]@{
        date       = (Get-Date).ToString("s")
        project    = $project
        files      = $files
        hasChanges = ($files.Count -gt 0)
        summary    = $summary
        ai         = $ai
    }

    # Si existe, cargar y agregar
    if (Test-Path $logFile) {
        $existing = Get-Content $logFile -Raw | ConvertFrom-Json
        # Forzar array
        if ($existing -isnot [System.Collections.IEnumerable]) {
            $existing = @($existing)
        }
        $existing += $entry
    } else {
        $existing = @($entry)
    }

    $existing | ConvertTo-Json -Depth 5 | Set-Content $logFile
}

function Get-Log {
    param($project)

    $logFile = "$PSScriptRoot/../data/logs/$project.json"

    if (!(Test-Path $logFile)) {
        Write-Host "No hay logs"
        return
    }

    $data = Get-Content $logFile -Raw | ConvertFrom-Json

    $data | Select-Object date, files, summary | Format-Table
}

function Get-LogAI {
    param($project)

    $logFile = "$PSScriptRoot/../data/logs/$project.json"

    if (!(Test-Path $logFile)) {
        Write-Host "No hay logs"
        return
    }

    $data = Get-Content $logFile -Raw

    $apiKey = $env:GEMINI_API_KEY

    $prompt = @"
Historial del proyecto:

$data

Resume:
- progreso
- problemas
- siguiente paso concreto
"@

    $body = @{
        contents = @(
            @{
                parts = @(
                    @{ text = $prompt }
                )
            }
        )
    } | ConvertTo-Json -Depth 10

    $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey"

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
        Write-Host $response.candidates[0].content.parts[0].text
    } catch {
        Write-Host "Error IA"
    }
}

Export-ModuleMember -Function Write-Log, Get-Log, Get-LogAI