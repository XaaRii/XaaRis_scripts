@echo OFF
cd /d %~dp1 2>NUL || (
  echo.
  echo   This script is not supposed to be run like this.
  echo   Either drag and drop another file^(s^) on this batch file
  echo   or run this script from the 'Send to' menu.
  timeout 5 > NUL
  goto :loopend
)
:wait
  IF EXIST %temp%\wait-ffmpeg (
    timeout 3 > NUL
    goto :wait
  )

call ffmpeg -version 2> NUL > NUL || (
  goto :ffcheck
)
goto :main

:ffcheck
  IF EXIST %userprofile%\Downloads\ffmpeg.exe (
  	SET "PATH=%PATH%;%userprofile%\Downloads"
  ) else IF EXIST %~dp0\ffmpeg.exe (
  	SET "PATH=%PATH%;%~dp0"
  ) else IF EXIST %~dp1\ffmpeg.exe (
  	SET "PATH=%PATH%;%~dp1"
  ) else IF EXIST %temp%\ffmpeg.exe (
  	SET "PATH=%PATH%;%temp%"
  ) else (
    call :noffmpeg
  )

:main
SETLOCAL enableextensions disabledelayedexpansion
echo %~dp1

:loopfor
  if "%~1"=="" goto :loopend
  echo [1mCreating a "%~n1-nosound%~x1" file[0m
  ffmpeg -v quiet -stats -i "%~1" -c copy -an "%~n1-nosound%~x1"
  echo.
  SHIFT
  goto :loopfor
:loopend
  ENDLOCAL
  echo Finished! Closing in 5 seconds...
  timeout 5 > NUL
  exit 0

:noffmpeg
  echo [33mffmpeg.exe not found. Downloading it now...[0m
  echo.
  cd /d %temp%
  echo Wait > wait-ffmpeg
  curl -s -f -L "https://raw.githubusercontent.com/XaaRii/XaaRis_scripts/main/other/ffmpeg.exe" > ffmpeg.exe
  for %%A in ("ffmpeg.exe") do (
    if %%~zA==0 goto :failffmpeg
  )
  del wait-ffmpeg
  SET "PATH=%PATH%;%temp%"
  cd /d %~dp1
  echo.
  timeout 1 > NUL
  goto :EOF

:failffmpeg
  del wait-ffmpeg
  echo [31m...I couldn't download ffmpeg. That can happen if this script is outdated.[0m
  echo Please check if there is a new version of this script:
  echo https://github.com/XaaRii/XaaRis_scripts/tree/main/shell-sendto
  echo.
  echo If there isn't, consider contacting XaaRi and he'll look into it.
  timeout 5 > NUL
  goto loopend