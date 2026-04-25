param(
    [string]$command,
    [string]$project
)

Import-Module "$PSScriptRoot\modules\GitManager.psm1"
Import-Module "$PSScriptRoot\modules\Logger.psm1"
Import-Module "$PSScriptRoot\modules\AIClient.psm1"
Import-Module "$PSScriptRoot\modules\ProjectScanner.psm1"
Import-Module "$PSScriptRoot\modules\Analyzer.psm1"


switch ($command) {
    "scan"    { Get-Projects }
    "analyze" { Invoke-ProjectAnalysis -ProjectName $project }
    "sync"    { Sync-Project -ProjectName $project }
    "coach"   { Get-CoachRecommendation }
    default   { Write-Host "Comando no válido" }
}