$ErrorActionPreference = "Stop"

if ( -not ( Test-Path -Path "$PSScriptRoot\v8" ) ) {
    Write-Error "v8 not found"
}

g++ -I"$PSScriptRoot`\v8" -I"$PSScriptRoot`\v8\include" `
    "$PSScriptRoot`\v8\samples\hello-world.cc" -o hello_world.exe `
    -lv8_monolith -L"$PSScriptRoot" -L"$PSScriptRoot`\v8\out\release\obj" `
    -pthread -std=c++17 -ldl -DV8_COMPRESS_POINTERS

Invoke-Expression -Command ".\hello_world.exe"
