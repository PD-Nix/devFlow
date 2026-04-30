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
Import-Module "$PSScriptRoot/modules/TestRunner.psm1"
Import-Module "$PSScriptRoot/modules/Structure.psm1"
Import-Module "$PSScriptRoot/modules/Stale.psm1"
Import-Module "$PSScriptRoot/modules/Snapshot.psm1"
Import-Module "$PSScriptRoot/modules/Scaffold.psm1"
Import-Module "$PSScriptRoot/modules/FastTravel.psm1"
function Show-Menu {
    Write-Host "`n=== DEVFLOW ==="
    Write-Host "df scan             -> listar proyectos"
    Write-Host "df analyze <name>   -> analizar cambios"
    Write-Host "df sync <name>      -> commit + push"
    Write-Host "df init <name>      -> crear repo GitHub"
    Write-Host "df log <name>       -> ver historial"
    Write-Host "df logai <name>     -> resumen con IA"
    Write-Host "df test <name>      -> ejecutar tests relacionados"
    Write-Host "df menu             -> mostrar este menú"
    Write-Host "df snapshot <name>  -> crear snapshot"
    Write-Host "df diffsnap <name>   -> comparar con snapshot"
    Write-Host "df structure <name>  -> mostrar estructura de proyecto"
    Write-Host "df stale            -> proyectos sin cambios recientes"
    Write-Host "df scaffold <name> <file>  -> crear proyecto desde estructura"
    Write-Host "df ftt <name>  -> ir rápido a proyecto"
    Write-Host "=================`n"
    Write-Host ""
}

switch ($command) {
    "scan"    { Get-Projects }
    "analyze" { Invoke-ProjectAnalysis -ProjectName $project }
    "sync"    { Sync-Project -ProjectName $project }
    "init"    { Initialize-Project -ProjectName $project }
    "log"   { Get-Log -project $project }
    "logai" { Get-LogAI -project $project }
    "test" { Invoke-SmartTestRunner -ProjectName $project }
    "structure" { Show-ProjectStructure -ProjectName $project }
    "stale"     { Get-StaleProjects }
    "snapshot"  { New-Snapshot -ProjectName $project }
    "diffsnap"  { Compare-Snapshot -ProjectName $project }
    "scaffold"  { New-ProjectFromStructure -ProjectName $project -FilePath $args[0] }
    "ftt" { ftt -name $project }
    "menu" { Show-Menu }
    default   { Write-Host "Comando no válido";Show-Menu }
}