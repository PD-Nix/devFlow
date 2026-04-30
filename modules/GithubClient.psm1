function New-GitHubRepo {
    param(
        [string]$repoName
    )

    $token = $env:GITHUBTOKEN

    if (-not $token) {
        throw "No hay GITHUB_TOKEN configurado"
    }

    $body = @{
        name = $repoName
        private = $false
    } | ConvertTo-Json

    $headers = @{
        Authorization = "Bearer $token"
        Accept        = "application/vnd.github+json"
    }

    $response = Invoke-RestMethod `
        -Uri "https://api.github.com/user/repos" `
        -Method Post `
        -Headers $headers `
        -Body $body `
        -ContentType "application/json"

    return $response.clone_url
}

Export-ModuleMember -Function New-GitHubRepo