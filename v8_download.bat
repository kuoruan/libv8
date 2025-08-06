@echo off

setlocal

set "dir=%~dp0"
set "branch=%~1"

set "depotToolsDir=%dir%\depot_tools"

if not exist "%depotToolsDir%" (
  echo Error: depot_tools directory not found at %depotToolsDir%
  exit /b 1
)

set "DEPOT_TOOLS_DIR=%depotToolsDir%"
set "DEPOT_TOOLS_WIN_TOOLCHAIN=0"

set "Path=%DEPOT_TOOLS_DIR%;%Path%"

rem Check if branch is provided as an argument
rem If not, read the branch from VERSION file
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
