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
  echo Skipping test for architecture: %targetCpu% (current: %currentCpu%)
  exit /b 0
)

call cl.exe /EHsc /std:c++20 /Zc:__cplusplus ^
  /I"%dir%\v8" /I"%dir%\v8\include" ^
  /Fe".\hello-world" "%dir%\v8\samples\hello-world.cc" ^
  /link "%dir%\v8\out\release\obj\v8_monolith.lib" ^
  /DEFAULTLIB:Advapi32.lib /DEFAULTLIB:Dbghelp.lib /DEFAULTLIB:Winmm.lib ^
  /DV8_COMPRESS_POINTERS /DV8_ENABLE_SANDBOX

if errorlevel 1 (
  echo Compilation failed
  exit /b %errorlevel%
)

call .\hello-world.exe

endlocal
