param(
    [string]$command,
    [string]$project
)

Import-Module "$PSScriptRoot\modules\GitManager.psm1" -Force
Import-Module "$PSScriptRoot\modules\Logger.psm1" -Force
Import-Module "$PSScriptRoot\modules\AIClient.psm1" -Force
Import-Module "$PSScriptRoot\modules\ProjectScanner.psm1" -Force
Import-Module "$PSScriptRoot\modules\Analyzer.psm1" -Force
Import-Module "$PSScriptRoot\modules\Init.psm1" -Force

function Show-Menu {
    Write-Host "`n=== DEVFLOW ==="
    Write-Host "df scan             -> listar proyectos"
    Write-Host "df analyze <name>   -> analizar cambios"
    Write-Host "df sync <name>      -> commit + push"
    Write-Host "df init <name>      -> crear repo GitHub"
    Write-Host "df log <name>       -> ver historial"
    Write-Host "df logai <name>     -> resumen con IA"
    Write-Host ""
}

switch ($command) {
    "scan"    { Get-Projects }
    "analyze" { Invoke-ProjectAnalysis -ProjectName $project }
    "sync"    { Sync-Project -ProjectName $project }
    "coach"   { Get-CoachRecommendation }
    "init"    { Initialize-Project -ProjectName $project }
    "log"   { Get-Log -project $project }
    "logai" { Get-LogAI -project $project }
    "menu" { Show-Menu }
    default   { Write-Host "Comando no válido";Show-Menu }
}