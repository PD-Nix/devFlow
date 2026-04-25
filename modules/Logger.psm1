function Write-Log {
    param($project, $content)

    $logDir = "./data/logs"

    if (!(Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }

    $date = Get-Date -Format "yyyy-MM-dd"
    $logFile = "$logDir/$project.txt"

    Add-Content -Path $logFile -Value "`n[$date]`n$content"
}

Export-ModuleMember -Function Write-Log