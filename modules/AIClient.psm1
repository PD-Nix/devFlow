function Get-AISuggestions {
    param($diff, $projectName, $files)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    if (-not $config.aiEnabled) { return "IA desactivada" }

    $apiKey = $env:Gemini_Api_Key

    if (-not $apiKey) {
        return "ERROR: No hay API KEY en variable de entorno DEVFLOW_API_KEY"
    }

    # Limitar tamaño
    if ($diff.Length -gt 3000) {
        $diff = $diff.Substring(0,3000)
    }

    $prompt = @"
Proyecto: $projectName

Archivos modificados:
$($files -join "`n")

Cambios relevantes:
$diff

Analiza y responde:
1. Qué se hizo
2. Problemas posibles
3. Mejores prácticas faltantes
4. Próximo paso concreto
"@

    $body = @{
        contents = @(
            @{
                parts = @(
                    @{
                        text = $prompt
                    }
                )
            }
        )
    } | ConvertTo-Json -Depth 10

    $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey"

    try {
        $response = Invoke-RestMethod `
            -Uri $url `
            -Method Post `
            -Body $body `
            -ContentType "application/json"

        return $response.candidates[0].content.parts[0].text
    }
    catch {
        return "Error IA: $_"
    }
}

Export-ModuleMember -Function Get-AISuggestions