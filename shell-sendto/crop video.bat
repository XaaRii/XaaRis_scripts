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
    timeout 3
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
if not "%~2"=="" call :morefiles
if not "%single%"=="true" (
  call :paramEdit
)

SETLOCAL enableextensions disabledelayedexpansion
:loopfor
  if "%~1"=="" goto :loopend
  if "%single%"=="true" (
    echo.
    echo.
    echo.
    echo  [1;4mCrop settings for "%~n1%~x1":[0m
    call :paramEdit
  )
  echo.
  echo [1mCreating a "%~n1-crop%~x1" file[0m
  ffmpeg -v quiet -stats -i "%~1" -filter:v "crop=%coords2%:%coords1%" "%~n1-crop%~x1"
  
  SHIFT
  goto :loopfor
:loopend
  ENDLOCAL
  echo Finished! Closing in 10 seconds...
  timeout 10 > NUL
  goto :EOF

:paramEdit
  echo.
  echo [1mSelect starting point of the crop[0m
  echo syntax is  x:y  coordinates of your crop's top left corner ^(in pixels^)
  echo example:   0:0    ^(top left corner of the video^)
  set /P "coords1=> "

  echo [1mNow select video size ^(in pixels^)[0m
  echo syntax is  x:y  how many pixels the video should have
  echo example:   1366:768
  set /P "coords2=> "

  echo The video will be cropped from %coords1% with desired size of %coords2% pixels..
  CHOICE /C yn /N /M "..is that correct?  (press Y/N)"
  if "%errorlevel%"=="2" goto :paramEdit
  goto :EOF

:morefiles
  echo It seems you have selected more files.
  CHOICE /C 12 /N /M "Do you want to crop them individually(1) or all together(2)?  (press 1/2)"
  if "%errorlevel%"=="1" set single=true
  if "%errorlevel%"=="2" set single=false
  goto :EOF


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