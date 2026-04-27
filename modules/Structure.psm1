function Show-ProjectStructure {
    param($ProjectName)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $path = Join-Path $config.projectsPath $ProjectName

    if (!(Test-Path $path)) {
        Write-Host " Proyecto no existe"
        return
    }

    Write-Host "`n Estructura de $ProjectName`n"

    Get-ChildItem -Path $path -Recurse | ForEach-Object {
        $depth = ($_.FullName.Replace($path, "") -split "\\").Length - 1
        $indent = "  " * $depth
        Write-Host "$indent- $($_.Name)"
    }
}

Export-ModuleMember -Function Show-ProjectStructure