@echo off
set version=8.1
set serverfile=powercord-updater.bat
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
      move /y "%localappdata%\\PaweleConf\\temp" "%updn%" >nul
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
  IF %version% NEQ %versionPowercordUpdater% call :update
  title  
  goto :main
:update
echo Current version: %version%               Available version: %versionPowercordUpdater%
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
title Powercord External Updater [by Pawele]
SETLOCAL EnableExtensions EnableDelayedExpansion
goto settings

:mainF
echo Before we start, i need to make sure where the powercord folder is located.
echo Current default path is set to: %powercordPath%
echo if it's somewhere else, please enter its FULL PATH. If it's correct, leave it empty.
:ZERO
set i0=
set /p i0="> "
echo.
set blankset=nah
if "%i0%"== "" set blankset=yes
if "%i0%"== "" set i0=%powercordPath%
cd /d %i0% && (
  REM alright
) || (
  echo There was a problem accessing that folder. Please try again.
  goto ZERO
)
if "%blankset%"== "nah" goto Qdef
goto A0

:Qdef
echo Would you like to save this path as default one? (yes/no)
set Qdefalt=
set /p Qdefalt="> "
if "%Qdefalt%"== "yes" goto QdefY
if "%Qdefalt%"== "no" goto A0
echo Wrong choice. Try again:
echo.
goto Qdef

:QdefY
echo ------------- Powercord Updater config [by Pawele] ------------- > %localappdata%\PaweleConf\PowercordUpdate.cfg && echo powercordPath=%i0% >> %localappdata%\PaweleConf\PowercordUpdate.cfg
echo Default folder updated. Current folder: %i0%
goto A

:A0
cls
echo Current folder: %i0%
:A
set i7=nah
title Powercord External Updater [by Pawele]
echo ________________________
echo Choose what to update:
echo   1 - Powercord
echo   2 - plugins
echo   3 - themes
echo   4 - all
echo.
echo   0 - exit
echo ________________________
set i1=
set /p i1="> "
if "%i1%"== "1" goto pullpower
if "%i1%"== "2" goto pullplugin
if "%i1%"== "3" goto pulltheme
if "%i1%"== "4" goto pullall
if "%i1%"== "0" goto EXIT
cls
echo Wrong choice. Try again:
goto A
:pullall
set i7=yes
goto pullpower

:pullpower
title Powercord Update Module
cd /d %i0%
echo.
echo Checking for updates...
git pull
echo.
echo ________________________
echo If there was an update, i will close your powercord.
echo Was there an update? (yes/no)
:TWO
set i2=
set /p i2="> " 
if "%i2%"== "yes" goto ppY
if "%i2%"== "no" goto ppN
echo Wrong choice. Try again:
goto TWO

:ppY
echo.

for /f "skip=1 tokens=* delims=" %%# in ('wmic process where "name='DiscordCanary.exe'" get ExecutablePath') do (
  set "pcpath=%%#"
  goto rest
)
:rest
set "runs=1"
if "%pcpath%"== "" set "runs=0"
:: if running pc, else skip 
if "%runs%"=="1" ( echo Killing Discord Canary... && taskkill /F /IM DiscordCanary.exe )
node injectors/index.js uninject --no-exit-codes
call npm install
echo Running npm audit fix now...
call npm audit fix
node injectors/index.js inject --no-exit-codes
echo (Actually, that was already done automatically)
echo.
echo.
break
echo Powercord successfully activated.
if "%i7%"=="yes" goto pullplugin
echo Press any key to continue to main screen.
pause > nul
cls
goto A

:pullplugin
title Plugins Update Module
cd /d %i0%
cd /d src
cd /d Powercord
cd /d plugins
set counterP=0
FOR /D %%i IN (*) DO ( echo ------------------------------------- && cd %%i && echo %%i: && git pull && cd .. && set /a counterP=counterP+1 )
echo ------------------------------------- && echo. && echo ________________________
if "%i7%"=="yes" echo Successfully updated all %counterP% plugins. && goto pulltheme
echo Successfully updated all %counterP% plugins. Press any key to continue to main screen.
pause > nul
cls
goto A

:pulltheme
title Themes Update Module
cd /d %i0%
cd /d src
cd /d Powercord
cd /d themes
set counterT=0
FOR /D %%i IN (*) DO ( echo ------------------------------------- && cd %%i && echo %%i: && git pull && cd .. && set /a counterT=counterT+1 )
echo ------------------------------------- && echo. && echo ________________________
if "%i7%"=="yes" (
  echo Successfully updated all %counterT% themes.
  if "%runs%"=="0" ( echo Powercord wasn't running before, so no need to start it up now. )
  if "%runs%"=="1" ( echo Starting Discord again... && mshta vbscript:Execute("CreateObject(""Wscript.Shell"").Run ""powershell -NoLogo -Command """"& '%pcpath%'"""""", 0 : window.close") && echo Okay, it should be starting now. )
  goto EXIT
)
echo Successfully updated all %counterT% themes. Press any key to continue to main screen.
pause > nul
cls
goto A

:ppN
if "%i7%"=="yes" goto pullplugin
cls
echo ok. Returning to main menu...
timeout 2 > nul
goto A

:settings
cd /d %localappdata%\
cd /d PaweleConf 2> NUL && (
  REM .....
) || (
  md PaweleConf
  cd /d PaweleConf
)
if exist PowercordUpdate.cfg (
    for /f "eol=- delims=" %%a in (PowercordUpdate.cfg) do set "%%a"
) else (
    rem default config
    echo ------------- Powercord Updater config [by Pawele] ------------- > %localappdata%\PaweleConf\PowercordUpdate.cfg && echo powercordPath=%userprofile%\powercord\ >> %localappdata%\PaweleConf\PowercordUpdate.cfg
    for /f "eol=- delims=" %%a in (PowercordUpdate.cfg) do set "%%a"
)
IF DEFINED powercordPath (echo powercordPath exists > NUL) ELSE (
  echo Config file seems to be corrupted. Autorepairing... && echo. && echo powercordPath=%userprofile%\powercord\ >> PowercordUpdate.cfg
  for /f "eol=- delims=" %%a in (PowercordUpdate.cfg) do set "%%a"
)
goto mainF

:EXIT
echo.
echo Exiting... (press any key to continue)
pause > nul
exit
