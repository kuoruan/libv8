
$archiveName = "v8_$Env:RUNNER_OS`_$($Env:RUNNER_ARCH.ToLower())"

Write-Host "Using Archive Name: $archiveName"

Write-Output "ARCHIVE_NAME=$archiveName" | Out-File -FilePath "$Env:GITHUB_ENV" -Encoding utf8
