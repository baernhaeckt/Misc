
$answer = Invoke-WebRequest -Uri "http://localhost:5000/api/users/Login?email=m%40m.ch&password=1234" -Method "POST"
$parsedAnswer = $answer.Content | ConvertFrom-Json
$parsedAnswer.token
$t = $parsedAnswer.token
Set-Clipboard "bearer $t"