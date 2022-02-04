@echo off
mode 101,18
setlocal EnableDelayedExpansion EnableExtensions
goto main
:usage
  echo Drag and drop a file/folder you want to upload on this %~nx0 file. >&2
  echo Don't worry, even if it looks like it's doing nothing, it works. >&2
  echo. >&2
  echo You can also use it from cmd. If you did so, then specify some arguments please: >&2
  echo Usage: >&2
  echo   transfer ^<file^|directory^> >&2        
  echo   ... ^| transfer ^<file_name^> >&2       
  if exist %localappdata%\PaweleConf\lasttransfer.txt SET /p lastlink= < %localappdata%\PaweleConf\lasttransfer.txt >NUL
  if defined lastlink (
  echo.
  echo Your last transfer.sh link was:  %lastlink%
)
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
  curl.exe --progress-bar --upload-file "%full_name%" "https://transfer.sh/%file_name%" -o %localappdata%\PaweleConf\transfer.txt
  type %localappdata%\PaweleConf\transfer.txt
  move /Y %localappdata%\PaweleConf\transfer.txt %localappdata%\PaweleConf\lasttransfer.txt >NUL
  del %full_name%
  popd
  goto :exit2
:not_a_directory
  curl.exe --progress-bar --upload-file "%file%" "https://transfer.sh/%file_name%" -o %localappdata%\PaweleConf\transfer.txt
  type %localappdata%\PaweleConf\transfer.txt
  move /Y %localappdata%\PaweleConf\transfer.txt %localappdata%\PaweleConf\lasttransfer.txt >NUL
  goto :exit2
:not_tty
  set "file_name=%~1"
  curl.exe --progress-bar --upload-file - "https://transfer.sh/%file_name%" -o %localappdata%\PaweleConf\transfer.txt
  type %localappdata%\PaweleConf\transfer.txt
  move /Y %localappdata%\PaweleConf\transfer.txt %localappdata%\PaweleConf\lasttransfer.txt >NUL
  goto :exit2

:exit
  echo.
  echo Press almost any key to close this window.
  pause > NUL
  exit /B 0

:exit2
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
