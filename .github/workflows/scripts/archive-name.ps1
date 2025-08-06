
param(
  [string]$arch
)

if ([string]::IsNullOrEmpty($arch)) {
  $arch = $Env:RUNNER_ARCH
}

$archiveName = "v8_$Env:RUNNER_OS`_$($arch.ToLower())"

Write-Host "Using Archive Name: $archiveName"

Write-Output "ARCHIVE_NAME=$archiveName" | Out-File -FilePath "$Env:GITHUB_ENV" -Encoding utf8
