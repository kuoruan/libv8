if ( -not ( Test-Path -Path "$PSScriptRoot\v8" ) ) {
    Write-Error "v8 not found"
    Exit 1
}

$Env:Path += ";$PSScriptRoot\depot_tools"
$Env:DEPOT_TOOLS_WIN_TOOLCHAIN = 0

$cores = ( Get-CimInstance -ClassName Win32_Processor ).NumberOfLogicalProcessors

$gnArgs = Get-Content "$PSScriptRoot\args.gn" | Where-Object {
    -not ( [String]::IsNullOrEmpty($_.Trim()) -or ( $_ -match "^#" ) )
}

$ccWrapper=""
if ( Get-Command -Name sccache ) {
    $ccWrapper="sccache"
}

$gnArgs +=@'
is_clang=false
cc_wrapper="$ccWrapper"
'@

cd "$PSScriptRoot\v8"

gn gen "out\release" --args="$gnArgs"
gn args "out\release" --list | Tee-Object -FilePath "${dir}\gn_args-$Env:OS.txt"

ninja.exe -C "out\release" -j "$cores" v8_monolith

Get-ChildItem -Path .\out\release\obj\libv8_*.a | Where-Object {
    -not $_.PSIsContainer
} | Select-Object -Property Name, CreationTime, @{Name='Size(MB)'; Expression={[math]::round($_.Length / 1MB, 2)}}

Copy-Item -Path ".\out\release\obj\libv8_monolith.a" -Destination "$PSScriptRoot"
