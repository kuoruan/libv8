@echo off

setlocal

set "dir=%~dp0"
set "targetCpu=%~1"

if not exist "%dir%\v8" (
  echo V8 not found
  exit /b 1
)

for /F "delims=" %%i in ('call "%dir%\scripts\get_arch.bat"') do (
  set "currentCpu=%%i"
)

if "%targetCpu%"=="" (
  set "targetCpu=%currentCpu%"
)

if not "%targetCpu%"=="%currentCpu%" (
  echo Skipping test for architecture: %targetCpu% ^(current: %currentCpu%^)
  exit /b 0
)

for /F "delims=" %%i in ('call "%dir%\scripts\get_os.bat"') do (
  set "os=%%i"
)

set "buildDir=%dir%\v8\out.gen\%os%.%targetCpu%.release"

if not exist "%buildDir%" (
  echo Build directory not found: %buildDir%
  exit /b 1
)

echo Testing V8 for architecture: %targetCpu%

call cl.exe ^
  /EHsc ^
  /std:c++20 ^
  /Zc:__cplusplus ^
  /DV8_COMPRESS_POINTERS=1 ^
  /DV8_ENABLE_SANDBOX ^
  /I"%dir%\v8" ^
  /I"%dir%\v8\include" ^
  "%dir%\v8\samples\hello-world.cc" ^
  /Fe".\hello-world" ^
  /link ^
  "%buildDir%\obj\v8_monolith.lib" ^
  /DEFAULTLIB:Advapi32.lib ^
  /DEFAULTLIB:Dbghelp.lib ^
  /DEFAULTLIB:Winmm.lib

if errorlevel 1 (
  echo Compilation failed
  exit /b %errorlevel%
)

set binPath="%dir%\hello-world.exe"

if exist "%binPath%" (
  echo Compilation successful, running test...
  call "%binPath%"
) else (
  echo hello-world executable not found
  exit /b 1
)

endlocal
