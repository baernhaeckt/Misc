Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

function Main {

    # Register user
    Write-Host "Register Users"
    $username = GenerateRandomString + "@" GenerateRandomString + ".ch"
    $registerAnswer = Invoke-WebRequest -Uri "http://localhost:5000/api/users/Register?email=$username" -Method "POST"
    EnsureSuccessfulResponse $registerAnswer

    # Get JWT (use the last registered user)
    Write-Host "Get JWT"
    $answer = Invoke-WebRequest -Uri "http://localhost:5000/api/users/Login?email=$username&password=1234" -Method "POST"
    EnsureSuccessfulResponse $answer
    $parsedAnswer = $answer.Content | ConvertFrom-Json
    $parsedAnswer.token
    $t = "Bearer " + $parsedAnswer.token

    # Generate a bunch of tokens
    Write-Host "Generate Tokens"
    # ccc14b11-5922-4e3e-bb54-03e71facaeb3 = Palette
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
    $token3content = $token3Response.Content
    $token4content = $token4Response.Content

    # Use Token
    Write-Host "Use token"
    $useToken1Response = Invoke-WebRequest -Uri "http://localhost:5000/api/tokens?tokenGuid=$token1content" -Method "POST" -Headers @{ "Authorization" = $t; }
    $useToken2Response = Invoke-WebRequest -Uri "http://localhost:5000/api/tokens?tokenGuid=$token2content" -Method "POST" -Headers @{ "Authorization" = $t; }
    $useToken3Response = Invoke-WebRequest -Uri "http://localhost:5000/api/tokens?tokenGuid=$token3content" -Method "POST" -Headers @{ "Authorization" = $t; }
    $useToken4Response = Invoke-WebRequest -Uri "http://localhost:5000/api/tokens?tokenGuid=$token4content" -Method "POST" -Headers @{ "Authorization" = $t; }
    EnsureSuccessfulResponse $useToken1Response
    EnsureSuccessfulResponse $useToken2Response
    EnsureSuccessfulResponse $useToken3Response
    EnsureSuccessfulResponse $useToken4Response

    # Ranking
    Write-Host "Ranking"
    $rankingAnswer = Invoke-WebRequest -Uri "http://localhost:5000/api/rankings/global" -Method "GET" -Headers @{ "Authorization" = $t; }
    EnsureSuccessfulResponse $rankingAnswer
    $rankingAnswer.Content

    # Has the "Onboarding" and "TrashHero"-award
    Write-Host "Awards"
    $awardAnswer = Invoke-WebRequest -Uri "http://localhost:5000/api/awards" -Method "GET" -Headers @{ "Authorization" = $t; }
    EnsureSuccessfulResponse $awardAnswer
    $awards = ($awardAnswer.Content | ConvertFrom-Json)
    if($awards.Length -ne 2) {
        throw "Not right count of awards"
    }
    
    # SufficientTypes Baseline
    Write-Host "SufficientTypes Baseline"
    $baselineAnswer = Invoke-WebRequest -Uri "http://localhost:5000/api/sufficienttype/baseline" -Method "GET" -Headers @{ "Authorization" = $t; }
    EnsureSuccessfulResponse $baselineAnswer
    $baselineAnswer.Content
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