@echo off

setlocal

set "dir=%~dp0"
set "v8Dir=%dir%\v8"

if not exist "%v8Dir%" (
  echo V8 not found at %v8Dir%
  exit /b 1
)

set "depotToolsDir=%v8Dir%\third_party\depot_tools"

if not exist "%depotToolsDir%" (
  set "depotToolsDir=%dir%\depot_tools"
)

set "Path=%depotToolsDir%;%Path%"
set "DEPOT_TOOLS_WIN_TOOLCHAIN=0"

set "os=%RUNNER_OS%"
if "%os%"=="" (
  set "os=Windows"
)

if "%RUNNER_ARCH%"=="X86" (
  set "targetCpu=x86"
) else if "%RUNNER_ARCH%"=="ARM64" (
  set "targetCpu=arm64"
) else if "%RUNNER_ARCH%"=="X64" (
  set "targetCpu=x64"
) else if "%RUNNER_ARCH%"=="ARM" (
  set "targetCpu=arm"
) else (
  if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set "targetCpu=x86"
  ) else if "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set "targetCpu=arm64"
  ) else (
    set "targetCpu=x64"
  )
)

echo Building V8 for %os% %targetCpu%

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

set "gnArgs=%gnArgs%cc_wrapper=""%ccWrapper%"" target_cpu=""%targetCpu%"" v8_target_cpu=""%targetCpu%"""

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
