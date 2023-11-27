@echo off

setlocal

set "dir=%~dp0"

if not exist "%dir%\v8" (
    echo V8 not found
    exit /b 1
)

set "Path=%dir%\depot_tools;%Path%"
set "DEPOT_TOOLS_WIN_TOOLCHAIN=0"

set "os=%RUNNER_OS%"
if "%os%"=="" (
  set "os=Windows"
)

setlocal EnableDelayedExpansion

set "gnArgs="

for /F "usebackq delims=" %%i in ("%dir%\args\%os%.gn") do (
  set "line=%%i"

  if not "!line!"=="" if not "!line:~0,1!"=="#" (
    set "line=!line:"=""!"
    set "gnArgs=!gnArgs!!line! "
  )
)

endlocal & set "gnArgs=%gnArgs%"

set "ccWrapper="

where sccache >nul 2>nul
if not errorlevel 1 (
  set "ccWrapper=sccache"
)

set "gnArgs=%gnArgs%cc_wrapper=""%ccWrapper%"""

pushd "%dir%\v8"

call gn gen ".\out\release" --args="%gnArgs%"
if errorlevel 1 (
  echo Failed to generate build files.
  exit /b %errorlevel%
)

echo ==================== Build args start ====================
call gn args ".\out\release" --list > "%dir%\gn-args_%os%.txt"
type "%dir%\gn-args_%os%.txt"
echo ==================== Build args end ====================

call ninja -C ".\out\release" -j %NUMBER_OF_PROCESSORS% v8_monolith
if errorlevel 1 (
  echo Build failed.
  exit /b %errorlevel%
)

dir ".\out\release\obj\v8_*.lib"

popd

endlocal
