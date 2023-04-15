@if (@a==@b) @end /*
:: Batch sector
@echo off
set version=1.1
set serverfile=vencord-updater.bat
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
  IF %version% NEQ %versionVencordUpdater% call :update
  title  
  goto :main
:update
echo Current version: %version%               Available version: %versionVencordUpdater%
echo Latest update comment: %commentVencordUpdater% & echo.
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
ENDLOCAL
:main
  REM ------------------ PROGRAM HERE ------------------------
  goto :settings

:start
  if defined vencordPath (
    cd /d "%vencordPath%" || (
      call :noPath
    )
  ) else (
    call :noPath
  )

  FOR /F "tokens=* USEBACKQ" %%g IN (`dir /b %vencordPath%`) do (SET "output=%%g")
  if not "%output%" == "" (
    :: Folder is NOT empty
    IF EXIST "package.json" (
      FOR /F "tokens=*" %%g IN ('powershell -Nop -C "(Get-Content .\package.json|ConvertFrom-Json).name"') do (
          if %%g == vencord ( goto :menu ) else ( goto :mismatch )
        )
    ) ELSE (
      goto :mismatch
    )
  ) else (
    goto :emptyF
  )
  goto :EOF

:emptyF
  :: Folder empty
  echo Selected folder ^(%vencordPath%^) is empty.
  choice /C yn /N /M "Would you like to install Vencord here? (press Y or N)"
  if "%errorlevel%"=="1" goto :install
  if "%errorlevel%"=="2" (
    echo Alright.
    del %localappdata%\\PaweleConf\\VencordUpdater.cfg
    goto :exit
  )

:noPath
  echo Before we start, i need to know where your Vencord folder is located.
  echo If you don't have one yet, create a new one instead.
  for /f "delims=" %%I in ('cscript /nologo /e:jscript "%~f0"') do (
    set vencordPath=%%I
    echo vencordPath=%%I >> VencordUpdater.cfg
    cd /d "%%I" || ( echo [93mERROR:[0m I've couldn't access the folder. && goto :exit )
    goto :EOF
  )
  if not defined vencordPath (
    echo [93mERROR:[0m It seems you didn't pick a folder.
    exit 0
  )


:mismatch
  echo [93mERROR:[0m The folder doesn't seem to be a Vencord folder.
  echo   Please double check it and try it again.
  echo   You can also delete the folder completely and create it again.
  echo   Although that will remove QuickCss and settings, so make sure you have those backed up ^(you can find them in the 'settings' folder^)
  del %localappdata%\\PaweleConf\\VencordUpdater.cfg
  goto :exit


:menu
  title Vencord External Updater [by Pawele]
  echo ___________________________
  echo  What do you want to do?:
  echo    1 - update Vencord
  echo    2 - force update
  echo    3 - open injector window
  echo.
  echo    5 - build
  echo    6 - autobuild on changes
  echo.
  echo    0 - exit
  echo ___________________________
  set i1=
  set /p i1="> "
  if "%i1%"== "1" goto :update
  if "%i1%"== "2" goto :forceUpdate
  if "%i1%"== "3" goto :injector
  if "%i1%"== "5" goto :build
  if "%i1%"== "6" goto :watch
  if "%i1%"== "0" goto :exit
  cls
  echo Wrong choice. Try again:
  goto :menu


:update
  call git pull
  echo.
  echo Done^! ^(Press any key to return to the main menu.^)
  pause > NUL
  cls
  goto :menu

:forceUpdate
  :: Userfiles backup
  robocopy ".\\src\\userplugins" "%localappdata%\\PaweleConf\\backup\\src\\userplugins" /MIR /E > NUL
  robocopy ".\\settings" "%localappdata%\\PaweleConf\\backup\\settings" /MIR /E > NUL
  
  call git reset --hard
  call git pull

  robocopy "%localappdata%\\PaweleConf\\backup\\src\\userplugins" ".\\src\\userplugins" /MOVE /E > NUL
  robocopy "%localappdata%\\PaweleConf\\backup\\settings" ".\\settings" /MOVE /E > NUL
  echo.
  echo Done^! ^(Press any key to return to the main menu.^)
  pause > NUL
  cls
  goto :menu

:injector
  start /b cmd /C "pnpm inject"
  timeout 6 > NUL
  cls
  goto :menu

:build
  call pnpm build
  echo.
  echo All that's left now is to restart Discord ^(Ctrl + R^).
  echo Done^! ^(Press any key to return to the main menu.^)
  pause > NUL
  cls
  goto :menu

:watch
  call pnpm watch
  echo.
  echo Done^! ^(Press any key to return to the main menu.^)
  pause > NUL
  cls
  goto :menu


:install
  :: NODE.JS check
  call node --version > NUL || (
    echo [93mERROR:[0m It seems you don't have node.js installed.
    echo You can download latest LTS version here: https://nodejs.org/
    goto :exit
  )
  FOR /F "tokens=*" %%g IN ('call node --version') do ( set nodeVer=%%g )
  set nodeVer=%nodeVer:~1,3%
  set /a nodeVer=%nodeVer:.=%
  if not %nodeVer% geq 18 (
    echo [93mERROR:[0m It seems you don't have the minimal required version of node.js ^(18^) installed.
    echo You can download latest LTS version here: https://nodejs.org/
    goto :exit
  )
  :: PNPM check
  call pnpm --version > NUL || (
    echo [93mWARN:[0m It seems you don't have pnpm installed. Installing now...
    call npm i -g pnpm
    echo Done. For changes to apply, you need to start this script again.
    goto :exit
  )
  FOR /F "tokens=*" %%g IN ('call pnpm --version') do ( set pnpmVer=%%g )
  set pnpmVer=%pnpmVer:~0,2%
  set /a pnpmVer=%pnpmVer:.=%
  if not %pnpmVer% geq 8 (
    echo [93mERROR:[0m It seems you don't have the minimal required version of pnpm ^(8^) installed. Installing now...
    call npm i -g pnpm
    echo Done. For changes to apply, you need to start this script again.
    goto :exit
  )
  :: Install process
  git clone https://github.com/Vendicated/Vencord ./gitclon/ && (
    cd gitclon
    robocopy . .. /MOVE /E > NUL
    cd ..
    timeout 1 > NUL
    rmdir gitclon /s /q
  ) || (
    echo [93mERROR:[0m Failed while cloning repository. Do you have git installed^?
    goto :EXIT
  )
  mkdir .\\src\\userplugins
  echo.
  CHOICE /C yn /N /M "Do you want to install Global badges plugin as well? (Y/N)"
  if "%errorlevel%"=="1" (
    curl -s https://raw.githubusercontent.com/HypedDomi/Vencord-Plugins/main/GlobalBadges/globalBadges.tsx > .\\src\\userplugins\\globalBadges.tsx
  )
  echo Global badges installed, don't forget to turn it on^!
  timeout 2 > NUL
  call pnpm install --frozen-lockfile || (
    echo [93mWARN:[0m Failed while installing node_modules. Check the error to understand more.
    goto :EXIT
  )

  call pnpm build
  start /b cmd /C "pnpm inject"
  timeout 6 > NUL
  cls
  goto :menu


:settings
  title Vencord External Updater [by Pawele]
  cd /d %localappdata%\
  cd /d PaweleConf 2> NUL || (
    md PaweleConf
    cd /d PaweleConf
  )
  if exist VencordUpdater.cfg (
    for /f "eol=- delims=" %%a in (VencordUpdater.cfg) do set "%%a"
  ) else (
    echo ------------- Vencord Updater config ------------- > %localappdata%\PaweleConf\VencordUpdater.cfg
  )
  goto :start


:exit
  echo.
  echo Exiting... ^(press any key to close^)
  title Have a great day^!
  pause > nul
  exit 0


:: JScript sector */
var shl = new ActiveXObject("Shell.Application");
var folder = shl.BrowseForFolder(0, "Please choose a folder where you have or want to have Vencord installed.", 0, 0x00);
WSH.Echo(folder ? folder.self.path : '');