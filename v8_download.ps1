$Env:Path += ";$PSScriptRoot\depot_tools"
$Env:DEPOT_TOOLS_WIN_TOOLCHAIN = 0

Param (
	[Parameter(Position=1)]
	[string]$branch
)

if ( [string]::IsNullOrEmpty($branch) ) {
    $branch = Get-Content VERSION -TotalCount 1
}

gclient sync --no-history --reset -r $branch
