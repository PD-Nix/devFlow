function Show-ProjectStructure {
    param($ProjectName)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $path = Join-Path $config.projectsPath $ProjectName

    if (!(Test-Path $path)) {
        Write-Host "❌ Proyecto no existe"
        return
    }

    # 🔥 carpetas a ignorar (puedes ampliar esto)
    $ignore = @(
        ".git",
        "node_modules",
        ".next",
        "dist",
        "build",
        "__pycache__",
        ".venv"
    )

    Write-Host "`n📂 Estructura de $ProjectName`n"

    Get-ChildItem -Path $path -Recurse -Force |
    Where-Object {
        $full = $_.FullName

        foreach ($i in $ignore) {
            if ($full -match "\\$i(\\|$)") {
                return $false
            }
        }
        return $true
    } |
    ForEach-Object {
        $relative = $_.FullName.Replace($path, "")
        $depth = ($relative -split "\\").Length - 1
        $indent = "  " * $depth
        Write-Host "$indent- $($_.Name)"
    }
}

Export-ModuleMember -Function Show-ProjectStructure