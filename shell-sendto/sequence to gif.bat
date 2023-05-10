@echo OFF
:: edit this to point to your ImageMagick installation
IF EXIST %userprofile%\Desktop\other\apps-programs\ImageMagick (
	SET "PATH=%PATH%;%userprofile%\Desktop\other\apps-programs\ImageMagick\"
) else (
  echo ImageMagick not found, press any key to exit.
  pause > NUL
  exit
)
SETLOCAL enableextensions disabledelayedexpansion
cd /d %~dp1
echo %~dp1
echo.
echo delay 10, resize 25%%

set newfile=%~n1
:: edit resize percentage here if you want to
magick.exe %* -delay 10 -resize 25%% -auto-orient %newfile:~0,-4%-anim.gif
ENDLOCAL
timeout 10
goto :eof