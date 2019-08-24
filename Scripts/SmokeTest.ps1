Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

function Main {

    # Register user
    Write-Host "Register Users"
    $username = GenerateRandomString + "@" GenerateRandomString + ".ch"
    $registerAnswer = Invoke-WebRequest -Uri "http://localhost:5000/api/users/Register?email=$username" -Method "POST"
    EnsureSuccessfulResponse $registerAnswer

    # Get JWT
    Write-Host "Get JWT"
    $answer = Invoke-WebRequest -Uri "http://localhost:5000/api/users/Login?email=m%40m.ch&password=1234" -Method "POST"
    EnsureSuccessfulResponse $answer
    $parsedAnswer = $answer.Content | ConvertFrom-Json
    $parsedAnswer.token
    $t = "Bearer " + $parsedAnswer.token

    # Generate a bunch of tokens
    Write-Host "Generate Tokens"
    $token1Response = Invoke-WebRequest -Uri "http://localhost:5000/api/tokens?partnerId=ccc14b11-5922-4e3e-bb54-03e71facaeb3" -Headers @{ "Authorization" = $t; }
    $token2Response = Invoke-WebRequest -Uri "http://localhost:5000/api/tokens?partnerId=acc14b11-5922-4e3e-bb54-03e71facaeb3" -Headers @{ "Authorization" = $t; }
    $token3Response = Invoke-WebRequest -Uri "http://localhost:5000/api/tokens?partnerId=bcc14b11-5922-4e3e-bb54-03e71facaeb3" -Headers @{ "Authorization" = $t; }
    $token4Response = Invoke-WebRequest -Uri "http://localhost:5000/api/tokens?partnerId=ccc14b11-5922-4e3e-bb54-03e71facaeb3" -Headers @{ "Authorization" = $t; }
    EnsureSuccessfulResponse $token1Response
    EnsureSuccessfulResponse $token2Response
    EnsureSuccessfulResponse $token3Response
    EnsureSuccessfulResponse $token4Response

    $token1content = $token1Response.Content
    $token2content = $token2Response.Content

    # Use Token
    Write-Host "Use token"
    $useToken1Response = Invoke-WebRequest -Uri "http://localhost:5000/api/tokens?tokenGuid=$token1content" -Method "POST" -Headers @{ "Authorization" = $t; }
    $useToken2Response = Invoke-WebRequest -Uri "http://localhost:5000/api/tokens?tokenGuid=$token2content" -Method "POST" -Headers @{ "Authorization" = $t; }
    EnsureSuccessfulResponse $useToken1Response
    EnsureSuccessfulResponse $useToken2Response

    # Ranking
    Write-Host "Ranking"
    $rankingAnswer = Invoke-WebRequest -Uri "http://localhost:5000/api/rankings/global" -Method "GET" -Headers @{ "Authorization" = $t; }
    EnsureSuccessfulResponse $rankingAnswer
    $rankingAnswer.Content
}


function EnsureSuccessfulResponse ($response) {
    if ($response.StatusCode -gt 299) {
        throw "Request was not successful!"
    }
}

function GenerateRandomString {
    $string = "asdfadfnglkaslkngalkfnk2342419!1342@sadfadsfad?123412341adfafa"
    for ($i = 0; $i -lt 10; $i++ ) {
        $newString += $string[(Get-Random -Minimum 0 -Maximum $string.Length)]
    }
    return $newString
}

Main