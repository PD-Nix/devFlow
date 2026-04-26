function Get-ChangedFiles {
    param($path)

    Push-Location $path

    $files = git diff --name-only

    Pop-Location

    return $files
}

function Watch-TestFramework {
    param($path)

    if (Test-Path "$path/package.json") {
        return "node"
    }
    elseif (Test-Path "$path/pom.xml" -or Test-Path "$path/build.gradle") {
        return "java"
    }
    elseif (Test-Path "$path/requirements.txt") {
        return "python"
    }

    return $null
}

function Find-RelatedTests {
    param($path, $changedFiles)

    $tests = @()

    foreach ($file in $changedFiles) {

        $name = [System.IO.Path]::GetFileNameWithoutExtension($file)

        # patrones comunes
        $patterns = @(
            "*$name*.test.*",
            "*$name*.spec.*",
            "*$name*Test.*"
        )

        foreach ($pattern in $patterns) {
            $found = Get-ChildItem -Path $path -Recurse -Include $pattern -File -ErrorAction SilentlyContinue

            if ($found) {
                $tests += $found.FullName
            }
        }
    }

    return $tests | Select-Object -Unique
}

function Build-TestCommand {
    param($framework, $tests)

    if (-not $tests -or $tests.Count -eq 0) {
        # fallback
        switch ($framework) {
            "node"   { return "npm test" }
            "java"   { return "mvn test" }
            "python" { return "pytest" }
        }
    }

    $testList = ($tests -join " ")

    switch ($framework) {
        "node"   { return "npx jest $testList" }
        "java"   { return "mvn -Dtest=$($tests -join ',') test" }
        "python" { return "pytest $testList" }
    }
}

function Use-Tests {
    param($path, $command)

    Push-Location $path

    Write-Host "`n🚀 Ejecutando:`n$command`n"

    try {
        $output = Invoke-Expression $command 2>&1
    } catch {
        $output = $_
    }

    Pop-Location

    return $output
}

function Get-TestErrors {
    param($output)

    $errors = $output | Where-Object {
        $_ -match "fail|error|exception|FAILED|Error"
    }

    return ($errors | Select-Object -First 50) -join "`n"
}

function Read-TestOutput {
    param($errors, $project)

    if (-not $errors) {
        return "✔ No se detectaron errores relevantes"
    }

    $apiKey = $env:GEMINI_API_KEY

    $prompt = @"
Proyecto: $project

Errores de tests:

$errors

Responde:
- Qué falló
- Causa probable
- Cómo arreglarlo

Sé directo.
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
        return $response.candidates[0].content.parts[0].text
    } catch {
        return "Error IA"
    }
}

function Invoke-SmartTestRunner {
    param($ProjectName)

    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    $path = Join-Path $config.projectsPath $ProjectName

    if (!(Test-Path $path)) {
        Write-Host "❌ Proyecto no existe"
        return
    }

    $framework = Watch-TestFramework -path $path

    if (-not $framework) {
        Write-Host "⚠ No se detectó framework"
        return
    }

    $changed = Get-ChangedFiles -path $path

    if (-not $changed) {
        Write-Host "⚠ No hay archivos modificados"
        return
    }

    Write-Host "`n📂 Archivos cambiados:`n"
    $changed | ForEach-Object { Write-Host $_ }

    $tests = Find-RelatedTests -path $path -changedFiles $changed

    if ($tests.Count -gt 0) {
        Write-Host "`n🎯 Tests relacionados:`n"
        $tests | ForEach-Object { Write-Host $_ }
    }
    else {
        Write-Host "`n⚠ No se encontraron tests relacionados → ejecutando todos"
    }

    $command = Build-TestCommand -framework $framework -tests $tests

    $output = Use-Tests -path $path -command $command

    Write-Host "`n📄 Output (parcial):`n"
    $output | Select-Object -First 20

    $errors = Get-TestErrors -output $output

    Write-Host "`n🧠 IA analizando...`n"

    $analysis = Read-TestOutput -errors $errors -project $ProjectName

    Write-Host $analysis
}

Export-ModuleMember -Function Invoke-SmartTestRunner