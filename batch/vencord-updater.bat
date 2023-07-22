@if (@a==@b) @end /*
:: Batch sector
@echo off
set version=2.1
set serverfile=vencord-updater.bat
if "%1"=="finalize" goto :finalize
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
curl -L https://raw.githubusercontent.com/XaaRii/XaaRis_scripts/main/versions.ini -o "%localappdata%/PaweleConf/versions.ini" 2> NUL
for /f "delims=" %%x in (%localappdata%/PaweleConf/versions.ini) do %%x 2>NUL
cls
IF %version% NEQ %versionVencordUpdater% call :update
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
  echo Vencord folder: %vencordPath%
  echo _____________________________
  echo  What do you want to do?:
  echo    1 - update Vencord
  echo    2 - force update
  echo    3 - open injector window
  echo    4 - 3rd party plugin menu
  echo.
  echo    5 - build
  echo    6 - autobuild on changes
  echo.
  echo    0 - exit
  echo _____________________________
  set i1=
  set /p i1="> "
  if "%i1%"== "1" goto :update
  if "%i1%"== "2" goto :forceUpdate
  if "%i1%"== "3" goto :injector
  if "%i1%"== "4" ( cls && goto :3rdPartyMenu )
  if "%i1%"== "5" goto :build
  if "%i1%"== "6" goto :watch
  if "%i1%"== "0" goto :exit
  cls
  echo Wrong choice. Try again:
  goto :menu

:3rdPartyMenu
  title Vencord External Updater [by Pawele]: Third party plugin menu
  echo ____________________________________
  echo  3rd party plugin menu:
  echo    1 - install/update Global badges
  echo    2 - install/update Spotimbed (Spotify embed fix)
  echo    3 - install/update Gif Collection
  echo.
  echo.
  echo    9 - install/update all
  echo    0 - go back
  echo ____________________________________
  set i1=
  set /p i1="> "
  if "%i1%"== "1" goto :gloBad
  if "%i1%"== "2" goto :spoEmb
  if "%i1%"== "3" goto :gifCol
  if "%i1%"== "9" call :gloBad "everything"
  if "%i1%"== "0" ( cls && goto :menu )
  cls
  echo Wrong choice. Try again:
  goto :3rdPartyMenu

:gloBad <everything>
  echo downloading Global badges...
  curl -s https://raw.githubusercontent.com/HypedDomi/Vencord-Plugins/main/GlobalBadges/globalBadges.tsx > .\\src\\userplugins\\globalBadges.tsx
  if not "%~1"== "everything" (
    echo rebuilding Vencord...
    call pnpm build > NUL
    echo.
    echo All that's left now is to restart Discord ^(Ctrl + R^).
    echo Don't forget to turn it on in Plugins tab^! ^(Press any key to return.^)
    pause > NUL
    cls
    goto :3rdPartyMenu
  )

:spoEmb
  echo downloading Spotimbed (Spotify embed fix)
  mkdir .\\src\\userplugins\\spotimbed 2> NUL || (
    rmdir .\\src\\userplugins\\spotimbed /s /q 2>NUL
    mkdir .\\src\\userplugins\\spotimbed
  )
  git clone https://codeberg.org/vap/vc-spotimbed ./src/userplugins/spotimbed/ || (
    echo [93mERROR:[0m Failed while cloning repository. Report this to Pawele, he'll look into it.
    goto :EXIT
  )

  if not "%~1"== "everything" (
    echo rebuilding Vencord...
    call pnpm build > NUL
    echo.
    echo All that's left now is to restart Discord ^(Ctrl + R^).
    echo Don't forget to turn it on in Plugins tab^! ^(Press any key to return.^)
    pause > NUL
    cls
    goto :3rdPartyMenu
  )

:gifCol
  echo downloading Gif Collection plugin
  mkdir .\\src\\userplugins\\vc-gif-collections 2> NUL || (
    rmdir .\\src\\userplugins\\vc-gif-collections /s /q 2>NUL
    mkdir .\\src\\userplugins\\vc-gif-collections
  )
  git clone https://github.com/Syncxv/vc-gif-collections ./src/userplugins/vc-gif-collections/ || (
    echo [93mERROR:[0m Failed while cloning repository. Report this to Pawele, he'll look into it.
    goto :EXIT
  )

  :: This last one is built different - everything switch
  echo rebuilding Vencord...
  call pnpm build > NUL
  echo.
  echo All that's left now is to restart Discord ^(Ctrl + R^).
  echo Don't forget to turn it on in Plugins tab^! ^(Press any key to return.^)
  pause > NUL
  cls
  if not "%~1"== "everything" goto :3rdPartyMenu
  :EOF

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
  
  call git reset --hard
  call git pull

  robocopy "%localappdata%\\PaweleConf\\backup\\src\\userplugins" ".\\src\\userplugins" /MOVE /E > NUL
  echo.
  echo Done^! ^(Press any key to return to the main menu.^)
  pause > NUL
  cls
  goto :menu

:injector
  title Vencord External Updater [by Pawele] - Open Injector
  start /b cmd /C "pnpm inject"
  timeout 6 > NUL
  cls
  goto :menu

:build
  title Vencord External Updater [by Pawele]: Build
  call pnpm build 2>NUL || (
    call pnpm install --frozen-lockfile
    call pnpm build
  )
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


:winget <package>
  winget --version 2>NUL >NUL || (
    echo [96mINFO:[0m It seems you don't have winget installed. Installing...
    powershell -Command " Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'; $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $releases = Invoke-RestMethod -uri $releases_url; $latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith('msixbundle') } | Select -First 1; Add-AppxPackage -Path $latestRelease.browser_download_url "
  )
  winget --version 2>NUL >NUL || (
    echo [93mERROR:[0m Installation of winget failed^! Aborting...
    echo [96mI cannot install dependencies automagically.
    echo To continue with installation, you need to manually install these tools:[0m
    echo   - Git               ^( https://git-scm.com/downloads ^)
    echo   - Node.js           ^( https://nodejs.org/ ^)
    echo   - pnpm              ^( npm install -g pnpm@latest ^)
    echo.
    echo Press any key to exit.
    pause >NUL
    exit 0
  )
  powershell.exe -Command "& {winget install %~1 --accept-source-agreements --accept-package-agreements | ForEach-Object { if ($_ -notmatch '^\s\s\s[-|\\/]|^\s\s\s$') { $_ } if ($_ -match 'Failed when opening source') { exit 258 } }}"
  if "%errorlevel%"=="258" (
    :: source fail
    call :sourceFix %~1
    goto :EOF
  )
  if "%errorlevel%"=="-1978335189" (
    :: already installed
    echo [96;1;4mINFO: It seems you have this already installed, but it is not in the PATH.
    echo In most cases, this can be fixed by restarting your computer.[0m
        echo.
        echo Press any key to exit.
        pause >NUL
        exit 0
  )
  if not "%errorlevel%"=="0" (
        echo [93mERROR:[0m winget install failed!
        echo ...Did you abort it? or maybe it's a problem with internet connection. Or smth else, idk.
        echo Usually reboot helps, go try that i guess.
        echo.
        echo Press any key to exit.
        pause >NUL
        exit 0
  )
  echo.
  goto :EOF

  :sourceFix
    choice /C yn /N /M "Failure of loading sources detected. Would you like me to try and fix it? (Y/N)"
    if "%errorlevel%"=="1" (
      powershell -Command "Start-Process -FilePath 'winget' -ArgumentList 'source reset \-\-force' -Verb RunAs -WorkingDirectory 'C:\' "
      timeout 3 >NUL
      winget install %~1 || (
        echo [93mERROR:[0m winget install failed and I'm not able to repair it myself!
        echo ...maybe you have some extra aggressive firewall settings? Or no internet connection. Or smth else, idk.
        echo Anyways, go fix your stuff and then come back.
        echo.
        echo Press any key to exit.
        pause >NUL
        exit 0
      )
    )
    goto :EOF


:install
title Vencord Installation
  echo.
  echo  Notice: To install Vencord, you need the following tools:
  echo  - git
  echo  - node.js
  echo  - pnpm
  echo.
  echo  [96mI'll try to install everything that is missing automatically.[0m
  echo  Are you okay with that? (press any key to continue)
  pause >NUL
  echo.

set postInstall="false"
  :: NODE.JS check
  call node --version 2>NUL >NUL || (
    IF EXIST %systemdrive%\Program Files\nodejs (
      SET "PATH=%PATH%;%systemdrive%\Program Files\nodejs"
    )
  )
  call node --version 2>NUL >NUL || (
    echo [93mWARN:[0m It seems you don't have node.js installed.
    title Installing Node.JS
    echo Installing node.js LTS version...
    call :winget OpenJS.NodeJS.LTS
    SET "PATH=%PATH%;%systemdrive%\Program Files\nodejs"
    set postInstall="true"
  )
  FOR /F "tokens=*" %%g IN ('call node --version') do ( set nodeVer=%%g )
  set nodeVer=%nodeVer:~1,3%
  set /a nodeVer=%nodeVer:.=%
  if not %nodeVer% geq 18 (
    echo [93mWARN:[0m It seems you don't have the minimal required version of node.js installed.
    title Updating Node.JS
    echo Updating node.js LTS version...
    call :winget OpenJS.NodeJS.LTS
    set postInstall="true"
  )

  :: PNPM check
  call pnpm --version 2>NUL >NUL || (
    IF EXIST %APPDATA%\npm\node_modules\pnpm\bin (
      SET "PATH=%PATH%;%APPDATA%\npm\node_modules\pnpm\bin"
      SET "PATH=%PATH%;%APPDATA%\npm\"
    )
  )
  call pnpm --version 2>NUL >NUL || (
    title Installing pnpm
    echo [96mINFO:[0m It seems you don't have pnpm installed. Installing now...
    ::call :winget pnpm
    call npm i -g pnpm@latest
    SET "PATH=%PATH%;%APPDATA%\npm\node_modules\pnpm\bin"
    SET "PATH=%PATH%;%APPDATA%\npm\"
    set postInstall="true"
  )
  FOR /F "tokens=*" %%g IN ('call pnpm --version') do ( set pnpmVer=%%g )
  set pnpmVer=%pnpmVer:~0,2%
  set /a pnpmVer=%pnpmVer:.=%
  if not %pnpmVer% geq 8 (
    title Updating pnpm
    echo [93mERROR:[0m It seems you don't have the minimal required version of pnpm installed. Updating now...
    call npm i -g pnpm@latest
    set postInstall="true"
  )

  :: Git check
  call git --version 2>NUL >NUL || (
    IF EXIST %systemdrive%\Program Files\Git\cmd (
      SET "PATH=%PATH%;%systemdrive%\Program Files\Git\cmd"
    )
  )
  call git --version 2>NUL >NUL || (
    title Installing Git
    echo [96mINFO:[0m It seems you don't have git installed. Installing now...
    call :winget Git.Git
    SET "PATH=%PATH%;%systemdrive%\Program Files\Git\cmd"
    set postInstall="true"
  )

  if %postInstall%=="false" goto :installVen

  :reloadInstall
    title Applying new changes...
    call node --version 2>NUL >NUL && call pnpm --version 2>NUL >NUL && call git --version 2>NUL >NUL || (
      echo [96;1;4mINFO: It seems computer restart is required for changes to apply.[0m
      echo Press any key to exit.
      pause >NUL
      exit 0
    )

  :installVen
    :: Install process
    title Installing Vencord
    git clone https://github.com/Vendicated/Vencord ./gitclon/ && (
      cd gitclon
      robocopy . .. /MOVE /E > NUL
      cd ..
      timeout 1 > NUL
      rmdir gitclon /s /q
    ) || (
      echo [93mERROR:[0m Failed while cloning Vencord repository.
      echo Press any key to exit.
      pause >NUL
      goto :EXIT
    )
    mkdir .\\src\\userplugins
    echo.
    title Installing optional 3rd party plugins
    echo [3rd party plugins]
    CHOICE /C yn /N /M "Do you want to install Global badges plugin as well? (Y/N)"
    if "%errorlevel%"=="1" (
      curl -s https://raw.githubusercontent.com/HypedDomi/Vencord-Plugins/main/GlobalBadges/globalBadges.tsx > .\\src\\userplugins\\globalBadges.tsx
    )
    echo Global badges installed, don't forget to turn it on in Plugins tab^!
    timeout 2 > NUL

    echo.
    CHOICE /C yn /N /M "Do you want to install Spotify embed fix plugin as well? (Y/N)"
    if "%errorlevel%"=="1" (
      mkdir .\\src\\userplugins\\spotimbed\\ 2> NUL || (
        rmdir .\\src\\userplugins\\spotimbed /s /q
        mkdir .\\src\\userplugins\\spotimbed
      )
      git clone https://codeberg.org/vap/vc-spotimbed ./src/userplugins/spotimbed/ || (
        echo [93mERROR:[0m Failed while cloning repository. Skipping...
      )
    )
    echo Spotimbed installed, don't forget to turn it on in Plugins tab^!
    timeout 2 > NUL

    echo.
    CHOICE /C yn /N /M "Do you want to install Gif Collection plugin as well? (Y/N)"
    if "%errorlevel%"=="1" (
      mkdir .\\src\\userplugins\\vc-gif-collections\\ 2> NUL || (
        rmdir .\\src\\userplugins\\vc-gif-collections /s /q
        mkdir .\\src\\userplugins\\vc-gif-collections
      )
      git clone https://github.com/Syncxv/vc-gif-collections ./src/userplugins/vc-gif-collections/ || (
        echo [93mERROR:[0m Failed while cloning repository. Skipping...
      )
    )
    echo Gif Collection plugin installed, don't forget to turn it on in Plugins tab^!
    timeout 2 > NUL

    :finalize
      title Final setup
      echo.
      call pnpm install --frozen-lockfile 2>NUL || (
        echo [93mERROR:[0m Failed while installing node_modules. Retrying...
        call "%~dpnx0" finalize
        exit 0
      )

      call pnpm build
      echo Done^! Now pick the Discord you use and inject it.
      timeout 1 >NUL

      start /b cmd /C "pnpm inject"
      timeout 6 >NUL
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