@echo off

setlocal

set "dir=%~dp0"
set "branch=%~1"

set "Path=%dir%\depot_tools;%Path%"
set "DEPOT_TOOLS_UPDATE=0"
set "DEPOT_TOOLS_WIN_TOOLCHAIN=0"

if "%branch%"=="" (
  for /F "usebackq delims=" %%i in ("%dir%\VERSION") do (
    for /F "delims=-" %%b in ("%%i") do (
      set "branch=%%b"
      goto next
    )
  )
)

:next

if "%branch%"=="" (
  echo Failed to get branch.
  exit /b 1
)

call gclient sync --no-history --reset -r "%branch%"
if errorlevel 1 (
  echo Failed to sync branch.
  exit /b %errorlevel%
)

endlocal
