Param( [string]$branch )

$Env:Path += ";$PSScriptRoot\depot_tools"
$Env:DEPOT_TOOLS_WIN_TOOLCHAIN = 0

if ( [string]::IsNullOrEmpty($branch) ) {
    $branch = Get-Content VERSION -TotalCount 1
}

gclient sync --no-history --reset -r $branch