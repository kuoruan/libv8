$Global:$ErrorActionPreference = "Stop"

$outputDir = "$Env:GITHUB_WORKSPACE`/pack"

$archive = "v8_$Env:RUNNER_OS`_amd64.7z"

New-Item -ItemType "directory" -Path "$outputDir"

Copy-Item -Path "$Env:GITHUB_WORKSPACE`\v8\include", `
    "$Env:GITHUB_WORKSPACE`\v8\out\release\obj\v8_monolith.lib", `
    "$Env:GITHUB_WORKSPACE`\gn-args_$Env:RUNNER_OS`.txt" `
  -Destination "$outputDir" -Recurse

Set-Location "$outputDir"

7z a -r "$Env:GITHUB_WORKSPACE`\$archive" .

Get-ChildItem -Path "$Env:GITHUB_WORKSPACE`\$archive" | `
  Where-Object { -not $_.PSIsContainer } | `
  Select-Object -Property Name, CreationTime, @{Name='Size(MB)'; Expression={[math]::round($_.Length / 1MB, 2)}}

"archive=$archive" >> $Env:GITHUB_OUTPUT
