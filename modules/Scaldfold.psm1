function New-ProjectFromStructure {
    param($ProjectName, $FilePath)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $base = Join-Path $config.projectsPath $ProjectName

    if (!(Test-Path $base)) {
        New-Item -ItemType Directory -Path $base | Out-Null
    }

    $lines = Get-Content $FilePath

    $stack = @($base)

    foreach ($line in $lines) {

        if ($line.Trim() -eq "") { continue }

        $indent = ($line -replace "[^\s]").Length
        $level = [int]($indent / 2)

        $name = $line.Trim()

        $stack = $stack[0..$level]

        $parent = $stack[-1]

        $fullPath = Join-Path $parent $name

        if ($name.EndsWith("/")) {

            $dir = $fullPath.TrimEnd("/")

            if (!(Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir | Out-Null
                Write-Host "📁 Creado: $dir"
            } else {
                Write-Host "✔ Existe: $dir"
            }

            $stack += $dir
        }
        else {

            if (!(Test-Path $fullPath)) {
                New-Item -ItemType File -Path $fullPath | Out-Null
                Write-Host "📄 Creado: $fullPath"
            } else {
                Write-Host "✔ Existe: $fullPath"
            }
        }
    }
}

Export-ModuleMember -Function New-ProjectFromStructure