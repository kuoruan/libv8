Param( [string]$branch )

$Global:ErrorActionPreference = "Stop"

$Env:Path += ";$PSScriptRoot`\depot_tools"
$Env:DEPOT_TOOLS_WIN_TOOLCHAIN = 0

if ( [string]::IsNullOrEmpty($branch) ) {
    $branch = ((Get-Content VERSION -TotalCount 1) -split '-')[0]
}

gclient sync --no-history --reset -r "$branch"
