@echo off

setlocal

set "dir=%~dp0"

set "archiveName=%~1"
set "outputDir=%dir%\pack"

set "os=%RUNNER_OS%"
if "%os%"=="" (
  set "os=Windows"
)

if "%archiveName%"=="" (
  set "archive=v8_%os%_amd64.7z"
) else (
  set "archive=%archiveName%.7z"
)

if not exist "%outputDir%" (
  mkdir "%outputDir%"
)

xcopy /E /I /Y "%dir%\v8\include" "%outputDir%"
xcopy /E /I /Y "%dir%\v8\out\release\obj\v8_monolith.lib" "%outputDir%"
xcopy /E /I /Y "%dir%\gn-args_%os%.txt" "%outputDir%"

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

for %%F in ("%dir%\%archive%") do (
  set /A "sizeMB=%%~zF/1024/1024"
  echo Name: %%~nxF Size^(MB^): %SizeMB%
)

endlocal
