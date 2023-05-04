@echo OFF
SETLOCAL enableextensions disabledelayedexpansion
cd /d %~dp1
echo %~dp1
echo This script expects you to have working ffmpeg in PATH.
echo.

if defined %~2 (
  echo It seems you have selected more files.
  echo 
  CHOICE /C yn /N /M "Do you want to crop them individually or all at once? (press 1 or 2)"
  if "%errorlevel%"=="1" set individual=true
)

if not defined individual (
  call :paramEdit
)

:loopfor
  echo.
  echo.
  if "%~1"=="" goto :loopend
  if defined individual (
    Crop settings for %~n1%~x1:
    call :paramEdit
  )
  echo Creating a '%~n1-crop%~x1' file
  ffmpeg -i "%~1" -filter:v "crop=%coords1%:%coords2%" "%~n1-crop%~x1"
  
  SHIFT
  goto :loopfor
:loopend
  ENDLOCAL
  echo Finished! Closing in 10 seconds...
  timeout 10 > NUL
  goto :EOF

:paramEdit
  echo.
  echo Select starting point of the crop
  echo syntax is  x:y  coordinates of your crop's top left corner ^(in pixels^)
  echo example:   0:0    ^(top left corner of the video^)
  set /P "coords1=> "

  echo Now select end point of the crop
  echo syntax is  x:y  coordinates of your crop's bottom right corner ^(in pixels^)
  echo example:   1366:768    ^(top left corner of the video^)
  set /P "coords2=> "

  echo The final crop will be from %coords1% to %coords2%
  echo 
  CHOICE /C yn /N /M "is that correct? (Y/N)"
  if "%errorlevel%"=="2" goto :paramEdit
  goto :EOF
