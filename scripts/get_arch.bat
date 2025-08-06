@echo off

setlocal

set "arch="

rem X86, X64, ARM, or ARM64
if not "%RUNNER_ARCH%"=="" (
  if "%RUNNER_ARCH%"=="X86" (
    set "arch=x86"
  ) else if "%RUNNER_ARCH%"=="ARM64" (
    set "arch=arm64"
  ) else if "%RUNNER_ARCH%"=="X64" (
    set "arch=x64"
  ) else if "%RUNNER_ARCH%"=="ARM" (
    set "arch=arm"
  )
) else (
  if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "arch=x64"
  ) else if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set "arch=x86"
  ) else if "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set "arch=arm64"
  ) else if "%PROCESSOR_ARCHITECTURE%"=="ARM" (
    set "arch=arm"
  )
)

if "%arch%"=="" (
  echo Unknown architecture type >&2
  exit /b 1
)

echo %arch%

endlocal
