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

for /F "delims=" %%i in ('call "%dir%\scripts\get_os.bat"') do (
  set "os=%%i"
)

set "buildDir=%dir%\v8\out.gen\%os%.%targetCpu%.release"

if not exist "%buildDir%" (
  echo Build directory not found: %buildDir%
  exit /b 1
)

set "archFlags="
set "linkFlags="

if /I "%targetCpu%"=="x64" (
  set "archFlags=/favor:AMD64"
  set "linkFlags=/MACHINE:X64"
) else if /I "%targetCpu%"=="x86" (
  set "archFlags=/favor:INTEL64"
  set "linkFlags=/MACHINE:X86"
) else if /I "%targetCpu%"=="arm64" (
  set "archFlags="
  set "linkFlags=/MACHINE:ARM64"
) else if /I "%targetCpu%"=="arm" (
  set "archFlags="
  set "linkFlags=/MACHINE:ARM"
)

echo Building hello world for architecture: %targetCpu%

call cl.exe ^
  /EHsc ^
  /std:c++20 ^
  /Zc:__cplusplus ^
  /O2 ^
  /DNDEBUG ^
  %archFlags% ^
  /DV8_COMPRESS_POINTERS=1 ^
  /DV8_ENABLE_SANDBOX ^
  /I"%dir%\v8" ^
  /I"%dir%\v8\include" ^
  "%dir%\v8\samples\hello-world.cc" ^
  /Fe".\hello_world" ^
  /link ^
  %linkFlags% ^
  "%buildDir%\obj\v8_monolith.lib" ^
  /DEFAULTLIB:Advapi32.lib ^
  /DEFAULTLIB:Dbghelp.lib ^
  /DEFAULTLIB:Winmm.lib ^
  /SUBSYSTEM:CONSOLE

if errorlevel 1 (
  echo Compilation failed
  exit /b %errorlevel%
)

if not "%targetCpu%"=="%currentCpu%" (
  echo Cross-compilation successful for %targetCpu%
  echo Skipping run test for architecture: %targetCpu% ^(current: %currentCpu%^)
  exit /b 0
)

set binPath="%dir%\hello_world.exe"

if exist "%binPath%" (
  echo Compilation successful, running test...
  call "%binPath%"
) else (
  echo hello_world executable not found
  exit /b 1
)

endlocal
