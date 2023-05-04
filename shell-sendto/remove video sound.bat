@echo OFF
SETLOCAL enableextensions disabledelayedexpansion
cd /d %~dp1
echo %~dp1

:loopfor
  if "%~1"=="" goto :loopend
  echo Creating a '%~n1-nosound%~x1' file
  ffmpeg -i "%~1" -c copy -an "%~n1-nosound%~x1"
  
  SHIFT
  goto :loopfor
:loopend
ENDLOCAL
goto :eof