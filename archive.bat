@echo off

setlocal

set "dir=%~dp0"
set "arch=%~1"

set "outputDir=%dir%\pack"

for /F "delims=" %%i in ('call "%dir%\scripts\get_os.bat"') do (
  set "os=%%i"
)

if "%arch%"=="" (
  for /F "delims=" %%i in ('call "%dir%\scripts\get_arch.bat"') do (
    set "arch=%%i"
  )
)

set "buildDir=%dir%\v8\out.gn\%os%.%arch%.release"

if not exist "%buildDir%" (
  echo Build directory not found: %buildDir%
  exit /b 1
)

set "archiveName=v8_%os%_%arch%"
set "archive=%archiveName%.7z"

if not defined GITHUB_ENV (
  echo GITHUB_ENV is not set, skipping environment variable export.
) else (
  echo Using Archive Name: %archiveName%
  echo ARCHIVE_NAME=%archiveName% >> "%GITHUB_ENV%"
)

if not exist "%outputDir%" (
  mkdir "%outputDir%"
)

xcopy /E /I /Q /Y "%dir%\v8\include" "%outputDir%"
copy /Y "%buildDir%\obj\v8_monolith.lib" "%outputDir%"
copy /Y "%dir%\gn-args_%os%.txt" "%outputDir%"

where 7z >nul 2>nul
if errorlevel 1 (
  echo 7z not found
  exit /b %errorlevel%
)

pushd "%outputDir%"

call 7z a -r "%dir%\%archive%" .
if errorlevel 1 (
  echo Failed to archive.
  exit /b %errorlevel%
)

popd

dir "%dir%\%archive%"

endlocal
