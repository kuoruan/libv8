@echo off

setlocal

set "dir=%~dp0"
rem Remove trailing backslash
set "dir=%dir:~0,-1%"

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

set "buildDir=%dir%\v8\out.gn\%os%.%targetCpu%.release"

if not exist "%buildDir%" (
  echo Build directory not found: %buildDir%
  exit /b 1
)

if /I "%targetCpu%"=="x64" (
  set "defFlags=/DV8_COMPRESS_POINTERS /DV8_ENABLE_SANDBOX"
  set "linkFlags=/MACHINE:X64"
) else if /I "%targetCpu%"=="x86" (
  set "defFlags="
  set "linkFlags=/MACHINE:X86"
) else if /I "%targetCpu%"=="arm64" (
  set "defFlags=/DV8_COMPRESS_POINTERS /DV8_ENABLE_SANDBOX"
  set "linkFlags=/MACHINE:ARM64"
) else if /I "%targetCpu%"=="arm" (
  set "defFlags="
  set "linkFlags=/MACHINE:ARM"
)

echo Building hello world for architecture: %targetCpu%

@echo on

call cl.exe ^
  /EHsc ^
  /std:c++20 ^
  /Zc:__cplusplus ^
  /O2 ^
  /DNDEBUG ^
  %defFlags% ^
  /I"%dir%\v8" ^
  /I"%dir%\v8\include" ^
  /Fe".\hello_world" ^
  "%dir%\v8\samples\hello-world.cc" ^
  /link ^
  %linkFlags% ^
  "%buildDir%\obj\v8_monolith.lib" ^
  /DEFAULTLIB:Advapi32.lib ^
  /DEFAULTLIB:Dbghelp.lib ^
  /DEFAULTLIB:Winmm.lib ^
  /SUBSYSTEM:CONSOLE

@echo off

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
