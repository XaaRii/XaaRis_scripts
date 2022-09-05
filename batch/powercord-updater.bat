@echo off
set version=9.5
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
  IF %version% NEQ %versionPowercordUpdater% call :update
  title  
  goto :main
:update
echo Current version: %version%               Available version: %versionPowercordUpdater%
echo Latest update comment: %commentPowercordUpdater%
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
title Replugged External Updater [by Pawele]
SETLOCAL EnableExtensions EnableDelayedExpansion
goto settings

:mainF
echo Before we start, i need to make sure where the powercord/replugged folder is located.
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
call :dcversion
cls
goto A

:dcversion
echo Do you use Discord Stable version or Canary version^? (S / C)
set /p stablecanary="> "
if /i "%stablecanary%"== "S" goto :EOF
if /i "%stablecanary%"== "C" goto :EOF
echo Wrong choice. Try again:
echo.
goto dcversion

:Qdef
echo Would you like to save this path as default one? (yes/no)
set Qdefalt=
set /p Qdefalt="> "
if "%Qdefalt%"== "yes" goto QdefY
if "%Qdefalt%"== "no" goto A
echo Wrong choice. Try again:
echo.
goto Qdef

:QdefY
echo ------------- Powercord Updater config [by Pawele] ------------- > %localappdata%\PaweleConf\PowercordUpdate.cfg && echo powercordPath=%i0% >> %localappdata%\PaweleConf\PowercordUpdate.cfg
echo Default folder updated. Current folder: %i0%
call :dcversion
goto A

:A
cls
:Aclearless
echo Current folder: %i0%
if /i "%stablecanary%"== "S" echo Chosen discord version: Stable
if /i "%stablecanary%"== "C" echo Chosen discord version: Canary
set i7=nah
title Replugged External Updater [by Pawele]
echo ________________________
echo Choose what to update:
echo   1 - Replugged
echo   2 - plugins
echo   3 - themes
echo   4 - all
echo.
echo Other:
echo   6 - plug replugged
echo   7 - unplug replugged
echo   8 - force update
echo.
echo   0 - exit
echo ________________________
set i1=
set /p i1="> "
if "%i1%"== "1" goto pullpower
if "%i1%"== "2" goto pullplugin
if "%i1%"== "3" goto pulltheme
if "%i1%"== "4" goto pullall
if "%i1%"== "6" ( call :plugonoff plug && goto :ppN )
if "%i1%"== "7" ( call :plugonoff unplug && goto :ppN )
if "%i1%"== "8" ( call :forceupdate && goto :ppN )
if "%i1%"== "0" goto EXIT
cls
echo Wrong choice. Try again:
echo.
goto Aclearless
:pullall
set i7=yes
goto pullpower

:pullpower
title Replugged Update Module
cd /d %i0%
echo.
echo Checking for updates...
git pull
echo.
echo ________________________
echo If there was an update, i will have to temporarily close your discord.
echo Was there an update? ^(yes/no^)
:TWO
set i2=
set /p i2="> " 
if "%i2%"== "yes" goto ppY
if "%i2%"== "no" goto ppN
echo Wrong choice. Try again:
goto TWO

:forceupdate
git reset --hard HEAD && git pull
echo Force update completed. You should restart discord for changes to apply.
echo Do you wish to restart it now? ^(yes/no^)
goto pnres

:plugonoff
echo Are you sure you want to %~1^? If so, press any key.
pause > NUL
if /i "%stablecanary%"== "C" call npm run %~1 canary
if /i "%stablecanary%"== "S" call npm run %~1 stable
echo.
echo To finish, discord must be restarted for changes to take effect.
echo Would you like me to restart it now? ^(yes/no^)
:pnres
set pnloop=
set /p pnloop="> " 
if "%pnloop%"== "yes" goto resyes
if "%pnloop%"== "no" goto :EOF
echo Wrong choice. Try again:
goto pnres

:resyes
if /i "%stablecanary%"== "C" (for /f "skip=1 tokens=* delims=" %%# in ('wmic process where "name='DiscordCanary.exe'" get ExecutablePath') do (
  set "pcpath=%%#"
  goto resyesnext
)
)
if /i "%stablecanary%"== "S" (for /f "skip=1 tokens=* delims=" %%# in ('wmic process where "name='Discord.exe'" get ExecutablePath') do (
  set "pcpath=%%#"
  goto resyesnext
)
)
:resyesnext
if "%pcpath%"== "" echo Discord isn't running, thus i cannot start it. && timeout 3 >NUL && goto :EOF
  echo Killing Discord...
  if /i "%stablecanary%"== "S" taskkill /F /IM Discord.exe
  if /i "%stablecanary%"== "C" taskkill /F /IM DiscordCanary.exe
  timeout 2 >NUL
  CALL :powercordStartagain
goto :EOF

:ppY
echo.
if /i "%stablecanary%"== "C" (for /f "skip=1 tokens=* delims=" %%# in ('wmic process where "name='DiscordCanary.exe'" get ExecutablePath') do (
  set "pcpath=%%#"
  goto rest
)
)
if /i "%stablecanary%"== "S" (for /f "skip=1 tokens=* delims=" %%# in ('wmic process where "name='Discord.exe'" get ExecutablePath') do (
  set "pcpath=%%#"
  goto rest
)
)
:rest
set "runs=1"
if "%pcpath%"== "" set "runs=0"
:: if running pc, else skip 
if /i "%stablecanary%"== "C" (if "%runs%"=="1" echo Killing Discord Canary... && taskkill /F /IM DiscordCanary.exe)
if /i "%stablecanary%"== "S" (if "%runs%"=="1" echo Killing Discord... && taskkill /F /IM Discord.exe)
if /i "%stablecanary%"== "C" call npm run unplug canary
if /i "%stablecanary%"== "S" call npm run unplug stable
call npm install
echo Running npm audit fix now...
call npm audit fix
if /i "%stablecanary%"== "C" call npm run plug canary
if /i "%stablecanary%"== "S" call npm run plug stable
echo Actually, that was already done automatically
echo.
echo.
break
if /i "%stablecanary%"== "C" echo Replugged successfully injected into Discord Canary.
if /i "%stablecanary%"== "S" echo Replugged successfully injected into Discord Stable.
if "%i7%"=="yes" goto pullplugin
if "%runs%"=="0" echo Discord wasn't running before, so i can't start it up now.
if "%runs%"=="1" CALL :powercordStartagain
echo Press any key to continue to main screen.
title Finished.
pause > nul
cls
goto A

:pullplugin
title Plugins Update Module
cd /d %i0%
cd /d plugins && (
  REM alright
) || (
  echo Seems like you are using the old structure. Searching on the old location for plugins...
  cd /d src
  cd /d Powercord
  cd /d plugins
)
set counterP=0
FOR /D %%i IN (*) DO ( echo ------------------------------------- && cd %%i && echo %%i: && git pull && cd .. && set /a counterP=counterP+1 )
echo ------------------------------------- && echo. && echo ________________________
if "%i7%"=="yes" echo Successfully updated all %counterP% plugins. && goto pulltheme
echo Successfully updated all %counterP% plugins. Press any key to continue to main screen.
title Finished.
pause > nul
cls
goto A

:pulltheme
title Themes Update Module
cd /d %i0%
cd /d themes && (
  REM alright
) || (
  echo Seems like you are using the old structure. Searching on the old location for themes...
  cd /d src
  cd /d Powercord
  cd /d themes
)
set counterT=0
FOR /D %%i IN (*) DO ( echo ------------------------------------- && cd %%i && echo %%i: && git pull && cd .. && set /a counterT=counterT+1 )
echo ------------------------------------- && echo. && echo ________________________
if "%i7%"=="yes" (
  echo Successfully updated all %counterT% themes.
  if "%runs%"=="0" echo Discord wasn't running before, so no need to start it up now.
  if "%runs%"=="1" CALL :powercordStartagain
  goto EXIT
)
echo Successfully updated all %counterT% themes. Press any key to continue to main screen.
title Finished.
pause > nul
cls
goto A

:ppN
if "%i7%"=="yes" goto pullplugin
echo.
echo Returning to main menu...
title Finished.
timeout 4 > nul
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
    echo ------------- Replugged Updater config [by Pawele] ------------- > %localappdata%\PaweleConf\PowercordUpdate.cfg && echo powercordPath=%userprofile%\replugged\ >> %localappdata%\PaweleConf\PowercordUpdate.cfg
    for /f "eol=- delims=" %%a in (PowercordUpdate.cfg) do set "%%a"
)
IF DEFINED powercordPath (echo powercordPath exists > NUL) ELSE (
  echo Config file seems to be corrupted. Autorepairing... && echo. && echo powercordPath=%userprofile%\replugged\ >> PowercordUpdate.cfg
  for /f "eol=- delims=" %%a in (PowercordUpdate.cfg) do set "%%a"
)
goto mainF

:EXIT
echo.
echo Exiting... ^(press any key to continue^)
title Have a great day^!
pause > nul
exit


:powercordStartagain
del %localappdata%\\PaweleConf\\starter.vbs > NUL
    timeout 1 > NUL
    (
    echo Dim WShell
    echo Set WShell = CreateObject^(^"WScript.Shell^"^)
    echo WShell.Run "%pcpath%", 0
    echo Set WShell = Nothing
    )> "%localappdata%/PaweleConf/starter.vbs"
    timeout 1 > NUL
    wscript %localappdata%/PaweleConf/starter.vbs
    echo Okay, discord should be starting now. ^[You may find it hidden in the right bottom corner^]
goto :EOF


