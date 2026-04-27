function Get-StaleProjects {
    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $base = $config.projectsPath

    $projects = Get-ChildItem -Path $base -Directory

    Write-Host "`n Estado de proyectos:`n"

    foreach ($proj in $projects) {

        $last = Get-ChildItem -Path $proj.FullName -Recurse -File |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First 1

        if ($last) {
            $days = (New-TimeSpan -Start $last.LastWriteTime -End (Get-Date)).Days

            if ($days -gt 7) {
                Write-Host "$($proj.Name) → $days días sin cambios"
            } else {
                Write-Host " $($proj.Name) → activo"
            }
        }
    }
}

Export-ModuleMember -Function Get-StaleProjects