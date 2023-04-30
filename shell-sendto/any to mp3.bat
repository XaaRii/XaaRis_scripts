@echo OFF
SETLOCAL enableextensions disabledelayedexpansion
cd /d %~dp1
echo %~dp1

:loopfor
  if "%~1"=="" goto :loopend
  echo Creating a '%~n1-sound.mp3' file
  ffmpeg -i "%~1" -q:a 0 -map a "%~n1-sound.mp3"
  SHIFT
  goto :loopfor
:loopend
ENDLOCAL
goto :eof