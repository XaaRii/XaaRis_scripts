@echo off
:: 3, 4, 27, 30
set version=1.7
set serverfile=genericUpdater.bat
IF /i "%~dp0"=="%localappdata%\PaweleConf\" (
  if "%1" == "update" (
    if defined updn (
      title Downloading update...
      curl -L https://raw.githubusercontent.com/XaaRii/XaaRis_scripts/main/batch/%serverfile% -o "%localappdata%/PaweleConf/temp" 2> NUL
      FOR /F "tokens=*" %%g IN ('@powershell Get-Content %localappdata%\\PaweleConf\\temp -Head 1') do (
        if "%%g" EQU "404: Not Found" (
          echo "404: Not Found" > %localappdata%\\PaweleConf\\lasterror
          del %localappdata%\\PaweleConf\\temp
          exit /B 1
        )
      )
      type "%localappdata%\\PaweleConf\\temp" > "%updn%"
      if exist %localappdata%\\PaweleConf\\lasterror del %localappdata%\\PaweleConf\\lasterror
      cls
      "%updn%"
      goto :EOF
    ) else echo Something's broken. Cannot find variable. Exiting... & exit /B 1
  ) else exit 0
)
title Update check && echo Checking for updates...
if NOT exist %localappdata%\\PaweleConf\\ mkdir %localappdata%\\PaweleConf\\
if exist %localappdata%\\PaweleConf\\"%~nx0" del %localappdata%\\PaweleConf\\"%~nx0"
@powershell Invoke-WebRequest -Uri https://raw.githubusercontent.com/XaaRii/XaaRis_scripts/main/versions.ini -OutFile "%localappdata%/PaweleConf/versions.ini"
  for /f "delims=" %%x in (%localappdata%/PaweleConf/versions.ini) do %%x 2>NUL
  cls
  IF %version% NEQ %versionGenericUpdater% call :update
  title  
  goto :main
:update
echo Current version: %version%               Available version: %versionGenericUpdater%
if exist %localappdata%/PaweleConf/lasterror (
  echo. & echo Warning! Last update failed with following error code: & @powershell Get-Content %localappdata%\\PaweleConf\\lasterror -Head 1 & echo.
)
CHOICE /C yn /N /M "Do you want to update? (press Y or N)"
if "%errorlevel%"=="1" echo Updating...
if "%errorlevel%"=="2" cls & goto :EOF
SETLOCAL
IF /i NOT "%~dp0"=="%localappdata%/PaweleConf/" (
  set updn=%~dpnx0
  COPY /y "%~dpnx0" "%localappdata%/PaweleConf/%~nx0" >nul
  %localappdata%/PaweleConf/"%~nx0" update
  goto :EOF
)
:main
REM ------------------ PROGRAM HERE ------------------------
