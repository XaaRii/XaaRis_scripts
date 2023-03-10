@echo off
set version=10.0
set serverfile=replugged-updater.bat
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
  IF %version% NEQ %versionRepluggedUpdater% call :update
  title  
  goto :main
:update
echo Current version: %version%               Available version: %versionRepluggedUpdater%
echo Latest update comment: %commentRepluggedUpdater% & echo.
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
echo Before we start, i need to make sure where the replugged folder is located.
echo Current default path is set to: %repluggedPath%
echo if it's somewhere else, please enter its FULL PATH. If it's correct, leave it empty.
:ZERO
set i0=
set /p i0="> "
echo.
set blankset=nah
if "%i0%"== "" set blankset=yes
if "%i0%"== "" set i0=%repluggedPath%
cd /d %i0% && (
  REM alright
) || (
  echo This folder doesn't seem to exist. Do you want to install it here? (yes/no)
  set z=
  set /p z="> "
  if /i "%z%"== "yes" call install
  if /i NOT "%z%"== "yes" goto ZERO
)
if "%blankset%"== "nah" goto Qdef
if defined installdecline (
  goto EXIT
)
if NOT defined stablecanary (
  call :dcversion
)
cls
goto A

:install
mkdir %i0% > NUL
cd /d %i0% && (
  REM alright
) || (
  echo Error happened while trying to access the folder.
  goto EXIT
)
git clone https://github.com/replugged-org/replugged . && (
  REM altight
) || (
  echo Error while cloning repository. Do you have git installed^?
  goto EXIT
)
call :dcversion
call npm install -g pnpm > NUL
call pnpm i
call pnpm run bundle
call plugonoff plug
:EOF

:dcversion
echo Discord Stable version or Canary version^? (S / C)
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
echo ------------- Replugged Updater config [by Pawele] ------------- > %localappdata%\PaweleConf\RepluggedUpdate.cfg && echo repluggedPath=%i0% >> %localappdata%\PaweleConf\RepluggedUpdate.cfg
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
echo   5 - install replugged (if you haven't already)
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
echo To %~1^ Replugged, discord must be restarted.
echo Can I restart it now? ^(yes/no^)
:pnres
set pnloop=
set /p pnloop="> " 
if "%pnloop%"== "yes" goto resyes
if "%pnloop%"== "no" goto resno
echo Wrong choice. Try again:
goto pnres

:resno
echo Can't be helped then...
set installdecline=1
goto :EOF

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
if "%pcpath%"== "" (
  echo Discord wasn't running, thus i cannot start it.
) else (
  echo Killing Discord...
  if /i "%stablecanary%"== "S" taskkill /F /IM Discord.exe
  if /i "%stablecanary%"== "C" taskkill /F /IM DiscordCanary.exe
  timeout 2 >NUL
)
  if /i "%stablecanary%"== "C" call pnpm run %~1 --production canary
  if /i "%stablecanary%"== "S" call pnpm run %~1 --production stable
  CALL :repluggedStartagain
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
:: if running rp, else skip 
if /i "%stablecanary%"== "C" (
  if "%runs%"=="1" echo Killing Discord Canary...
  taskkill /F /IM DiscordCanary.exe
  call pnpm run plug --production canary
)
if /i "%stablecanary%"== "S" (
  if "%runs%"=="1" echo Killing Discord...
  taskkill /F /IM Discord.exe
  call pnpm run plug --production stable
)
echo.
echo.
break
if /i "%stablecanary%"== "C" echo Replugged successfully injected into Discord Canary.
if /i "%stablecanary%"== "S" echo Replugged successfully injected into Discord Stable.
if "%i7%"=="yes" goto pullplugin
if "%runs%"=="0" echo Discord wasn't running before, so i can't start it up now.
if "%runs%"=="1" CALL :repluggedStartagain
echo Press any key to continue to main screen.
title Finished.
pause > nul
cls
goto A

:pullplugin
title Plugins Update Module
echo Sorry, this function is currently not supported.
echo Press any key to return...
pause > NUL
goto A

cd /d %i0%
cd /d plugins && (
  REM alright
) || (
  echo Seems like you are using the old structure. Searching on the old location for plugins...
  cd /d "%appdata%"
  cd /d replugged
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
echo Sorry, this function is currently not supported.
echo Press any key to return...
pause > NUL
goto A

cd /d %i0%
cd /d themes && (
  REM alright
) || (
  echo Seems like you are using the old structure. Searching on the old location for themes...
  cd /d "%appdata%"
  cd /d replugged
  cd /d themes
)
set counterT=0
FOR /D %%i IN (*) DO ( echo ------------------------------------- && cd %%i && echo %%i: && git pull && cd .. && set /a counterT=counterT+1 )
echo ------------------------------------- && echo. && echo ________________________
if "%i7%"=="yes" (
  echo Successfully updated all %counterT% themes.
  if "%runs%"=="0" echo Discord wasn't running before, so no need to start it up now.
  if "%runs%"=="1" CALL :repluggedStartagain
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
if exist RepluggedUpdate.cfg (
    for /f "eol=- delims=" %%a in (RepluggedUpdate.cfg) do set "%%a"
) else (
    rem default config
    echo ------------- Replugged Updater config [by Pawele] ------------- > %localappdata%\PaweleConf\RepluggedUpdate.cfg && echo repluggedPath=%userprofile%\replugged\ >> %localappdata%\PaweleConf\RepluggedUpdate.cfg
    for /f "eol=- delims=" %%a in (RepluggedUpdate.cfg) do set "%%a"
)
IF DEFINED repluggedPath (echo repluggedPath exists > NUL) ELSE (
  echo Config file seems to be corrupted. Autorepairing... && echo. && echo repluggedPath=%userprofile%\replugged\ >> RepluggedUpdate.cfg
  for /f "eol=- delims=" %%a in (RepluggedUpdate.cfg) do set "%%a"
)
goto mainF

:EXIT
echo.
echo Exiting... ^(press any key to continue^)
title Have a great day^!
pause > nul
exit


:repluggedStartagain
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


