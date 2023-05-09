@echo OFF
cd /d %~dp1 || (
  echo.
  echo   This script is not supposed to be run like this.
  echo   Either drag and drop another file on this batch file
  echo   or run this script from the 'Send to' menu.
  timeout 5 > NUL
  goto :loopend
)

:wait
IF EXIST %temp%\wait-ffmpeg (
  timeout 3
  goto :wait
)

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

echo %~dp1

SETLOCAL enableextensions disabledelayedexpansion

:loopfor
  if "%~1"=="" goto :loopend
  echo Creating a '%~n1-sound.mp3' file
  ffmpeg -i "%~1" -q:a 0 -map a "%~n1-sound.mp3"
  SHIFT
  goto :loopfor

:loopend
  ENDLOCAL
  echo.
  echo.
  echo Finished! Closing in 5 seconds...
  timeout 5 > NUL
  exit 0

:noffmpeg
  echo ffmpeg.exe not found. Downloading it now...
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
  echo ...I couldn't download ffmpeg. That can happen if this script is outdated.
  echo Please check if there is a new version of this script:
  echo https://github.com/XaaRii/XaaRis_scripts/tree/main/shell-sendto
  echo.
  echo If there isn't, consider contacting XaaRi and he'll look into it.
  timeout 5 > NUL
  goto loopend