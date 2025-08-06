@echo off

setlocal

set "os="

# Linux, Windows, or macOS
if not "%RUNNER_OS%"=="" (
  set "os=%RUNNER_OS%"
) else (
  if "%OS%"=="Windows_NT" (
    set "os=Windows"
  ) else if "%OS%"=="Linux" (
    set "os=Linux"
  ) else if "%OS%"=="Darwin" (
    set "os=macOS"
  )
)

if "%os%"=="" (
  echo Unknown OS type >&2
  exit /b 1
)

echo %os%

endlocal
