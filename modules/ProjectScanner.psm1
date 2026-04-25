function Get-Projects {
    $config = Get-Content "$PSScriptRoot/../config/config.json" | ConvertFrom-Json
    Get-ChildItem $config.projectsPath -Directory | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Name
            Path = $_.FullName
            LastModified = $_.LastWriteTime
        }
    }
}
Export-ModuleMember -Function Get-Projects