function ftt {
    param($name)
    $basePath = "C:\dev\$name"
    
    if (Test-Path $basePath) {
        Set-Location $basePath
    } else {
        Write-Error "La carpeta '$name' no existe en C:\dev"
    }
}
export-modulemember -Function ftt     