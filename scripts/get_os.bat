@echo off

setlocal

set "os="

rem Linux, Windows, or macOS
if not "%RUNNER_OS%"=="" (
  set "os=%RUNNER_OS%"
) else (
  rem Default to Windows since this is a .bat file
  set "os=Windows"
)

if "%os%"=="" (
  echo Unknown OS type >&2
  exit /b 1
)

echo %os%

endlocal
