function New-Snapshot {
    param($ProjectName)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $path = Join-Path $config.projectsPath $ProjectName

    $snapshotPath = "$PSScriptRoot/../data/cache/$ProjectName-snapshot.json"

    $files = Get-ChildItem -Path $path -Recurse -File | Select-Object FullName, LastWriteTime

    $snapshot = @{
        date = Get-Date
        files = $files
    }

    $snapshot | ConvertTo-Json -Depth 5 | Set-Content $snapshotPath

    Write-Host " Snapshot guardado"
}

function Compare-Snapshot {
    param($ProjectName)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $path = Join-Path $config.projectsPath $ProjectName

    $snapshotPath = "$PSScriptRoot/../data/cache/$ProjectName-snapshot.json"

    if (!(Test-Path $snapshotPath)) {
        Write-Host " No hay snapshot"
        return
    }

    $old = Get-Content $snapshotPath -Raw | ConvertFrom-Json
    $current = Get-ChildItem -Path $path -Recurse -File | Select-Object FullName

    $oldFiles = $old.files.FullName

    $newFiles = $current.FullName | Where-Object { $_ -notin $oldFiles }

    Write-Host "`nCambios desde snapshot:`n"

    $newFiles | ForEach-Object { Write-Host " $_" }
}

Export-ModuleMember -Function New-Snapshot, Compare-Snapshot