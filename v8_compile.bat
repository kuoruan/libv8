@echo off

setlocal

set "dir=%~dp0"
rem Remove trailing backslash
set "dir=%dir:~0,-1%"

set "targetCpu=%~1"

set "v8Dir=%dir%\v8"

if not exist "%v8Dir%" (
  echo V8 not found at %v8Dir%
  exit /b 1
)

set "depotToolsDir=%dir%\depot_tools"

if not exist "%depotToolsDir%" (
  echo Error: depot_tools directory not found at %depotToolsDir%
  exit /b 1
)

set "DEPOT_TOOLS_DIR=%depotToolsDir%"
set "DEPOT_TOOLS_WIN_TOOLCHAIN=0"

set "Path=%DEPOT_TOOLS_DIR%;%Path%"

for /F "delims=" %%i in ('call "%dir%\scripts\get_os.bat"') do (
  set "os=%%i"
)

if "%targetCpu%"=="" (
  for /F "delims=" %%i in ('call "%dir%\scripts\get_arch.bat"') do (
    set "targetCpu=%%i"
  )
)

echo Building V8 for %os% %targetCpu%

set "ccWrapper="

where sccache >nul 2>nul
if not errorlevel 1 (
  set "ccWrapper=sccache"
)

setlocal EnableDelayedExpansion

set "args="

rem Ignore comments and empty lines, split key=value pairs
for /F "usebackq eol=# tokens=1,* delims==" %%a in ("%dir%\args\%os%.gn") do (
  set "key=%%a"
  set "value=%%b"

  rem Remove trailing spaces and tabs
  for /L %%x in (1,1,10) do (
    if "!key:~-1!"==" " (
      set "key=!key:~0,-1!"
    )

    if "!key:~-1!"=="	" (
      set "key=!key:~0,-1!"
    )
  )

  if "!value!"=="" (
    set "args=!args!!key! "
  ) else (
    rem Remove leading spaces and tabs
    for /L %%x in (1,1,10) do (
      if "!value:~0,1!"==" " (
        set "value=!value:~1!"
      )

      if "!value:~0,1!"=="	" (
        set "value=!value:~1!"
      )
    )

    set "args=!args!!key!=!value! "
  )
)

endlocal & set "gnArgs=%args%"

set "gnArgs=%gnArgs%cc_wrapper=""%ccWrapper%"""
set "gnArgs=%gnArgs% target_cpu=""%targetCpu%"""
set "gnArgs=%gnArgs% v8_target_cpu=""%targetCpu%"""

pushd "%dir%\v8"

set "buildDir=.\out.gn\%os%.%targetCpu%.release"

if exist "%buildDir%" (
  if "%CI%"=="true" (
    echo CI environment detected - cleaning previous build directory
    rmdir /s /q "%buildDir%"
  )
)

call gn gen "%buildDir%" --args="%gnArgs%"
if errorlevel 1 (
  echo Failed to generate build files.
  exit /b %errorlevel%
)

echo ==================== Build args start ====================
call gn args "%buildDir%" --list > "%dir%\args_%os%.txt"
type "%dir%\args_%os%.txt"
echo ==================== Build args end ====================

call ninja -C "%buildDir%" -j %NUMBER_OF_PROCESSORS% v8_monolith
if errorlevel 1 (
  echo Build failed.
  exit /b %errorlevel%
)

dir "%buildDir%\obj\v8_*.lib"

popd

endlocal
