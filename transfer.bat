@echo off
setlocal EnableDelayedExpansion EnableExtensions
goto main
:usage
  echo No arguments specified. >&2
  echo Usage: >&2
  echo   transfer ^<file^|directory^> >&2        
  echo   ... ^| transfer ^<file_name^> >&2       
  goto :exit
:main
  if "%~1" == "" goto usage
  timeout.exe /t 0 >nul 2>nul || goto not_tty
  set "file=%~1"
  for %%A in ("%file%") do set "file_name=%%~nxA"
  if exist "%file_name%" goto file_exists
    echo %file%: No such file or directory >&2
  goto :exit
:file_exists
  if not exist "%file%\" goto not_a_directory
  set "file_name=%file_name%.zip"
  pushd "%file%" || goto :exit
  set "full_name=%temp%\%file_name%"
  powershell.exe -Command "Get-ChildItem -Path . -Recurse | Compress-Archive -DestinationPath ""%full_name%"""
  curl.exe --progress-bar --upload-file "%full_name%" "https://transfer.sh/%file_name%"
  popd
  goto :eof
:not_a_directory
  curl.exe --progress-bar --upload-file "%file%" "https://transfer.sh/%file_name%"
  goto :exit
:not_tty
  set "file_name=%~1"
  curl.exe --progress-bar --upload-file - "https://transfer.sh/%file_name%"
  goto :exit

:exit
echo.
echo.
for /f %%a in ('copy /Z "%~f0" nul') do set "Newline=%%a"
set /p "=Process finished. Press almost any key 3 times to exit!Newline!" <NUL
REM Do some stuff...
pause >NUL
set /p "=Process finished. Press almost any key 2 times to exit!Newline!" <NUL
pause >NUL
set /p "=Process finished. Press almost any key 1 time  to exit!Newline!" <NUL
pause >NUL
exit 0