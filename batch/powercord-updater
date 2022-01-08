@echo off
title Powercord External Updater [by Pawele]
REM hi! (✿◠‿◠)
REM how ya doin? i hope y'good
REM Truly nice weather today, innit? :)
REM discord preview yes yes (dw, nothing shady behind these comments)
SETLOCAL EnableExtensions EnableDelayedExpansion
set version=6
REM why are you here?
REM are you perhaps... worried?
REM ya don't trust your old pal Pawele?
REM ...
REM can't blame ya tho.
REM i wouldn't trust Xero with his little scripts too.
REM .....
REM "Who's Xero"..? What do you mean? Don't you know Dox?
REM welp... he's the master of gravity, or whatsoever. I don't get it either.
REM wait, maybe you shouldn't have known that. ғᴜᴄᴋ, ᴘᴀᴡᴇʟᴇ ᴡɪʟʟ ʙᴇᴀᴛ ᴍᴇ ᴜᴘ ɪғ ʜᴇ ғɪɴᴅs ᴏᴜᴛ.
REM WELL, GOTTA GET GOIN! Have to set some things up. Feel free to look around, just don't touch anything, k?
REM wouldn't want to break something now, wouldya?〜
REM ʰᵃᵛᵉ ᶠᵘⁿ・ ᵃⁿᵈ ᵈᵒⁿ'ᵗ ᶠᵒˡˡᵒʷ ᵐᵉ ᶦⁿᵗᵒ ˢᵉᵗᵗᶦⁿᶢˢ ᵃᵗ ᵗʰᵉ ᵇᵒᵗᵗᵒᵐ ᵒᶠ ᵗʰᶦˢ ᶠᶦˡᵉ・
goto settings

:mainF
REM main file:
echo Before we start, i need to make sure where the powercord folder is located.
echo Current default path is set to: %powercordPath%
echo if it's somewhere else, please enter it's FULL PATH. If it's correct, leave it empty.
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
echo there, last link.. -! hey! > nul
echo how did ya found me? > nul
echo i swear i tried to blend in tho.. > nul
echo wait... i have an idea! > nul
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
if "%runs%"=="0" ( echo Powercord wasn't running before, so no need to start it up now. )
if "%runs%"=="1" ( echo Starting Discord again... && @powershell -command Invoke-Item %pcpath% 2>&1 && echo Okay, it should be starting now. )
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
echo ------------------------------------- && echo. && echo ________________________ && echo --------------------------------------------------------------------------------------- > nul 2> nul >> nul 2>> nul && echo ...bruh. Even here? ᴊᴜsᴛ ᴡʜʏ ᴅᴏ ʏᴏᴜ ᴡᴀɴɴᴀ ғᴏʟʟᴏᴡ ᴍᴇ? ɪ ᴅᴏɴ'ᴛ ɢᴇᴛ ɪᴛ! > nul
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
echo ------------------------------------- && echo. && echo ________________________ && echo --------------------------------------------------------------------------------------- > nul 2> nul >> nul 2>> nul && echo ...heh. i don't care anymore. It's not like ur gonna find my next spot.  ...  If you will tho, i'll give you the most fitting badge for you there is on XaViR: Never-ending warrior > nul
if "%i7%"=="yes" echo Successfully updated all %counterT% themes. && goto EXIT
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
REM Hey! Are you following me?
REM Why?? I thought i told u to leave me workin.
REM ...what do you mean "no" ?
REM listen, i have work to do. Leave me alone, i have nothing more to say to u.
cd /d %localappdata%\
cd /d PaweleConf 2> NUL && (
  REM .....
) || (
  md PaweleConf
  cd /d PaweleConf
)
REM this joke isn't funny anymore, k?
if exist PowercordUpdate.cfg (
    for /f "eol=- delims=" %%a in (PowercordUpdate.cfg) do set "%%a"
    REM ᴡʜʏ ᴀʀᴇ ʏᴏᴜ sᴛɪʟʟ ʜᴇʀᴇ?
    REM ᴅᴏɴᴛ'ᴄʜᴀ ʜᴀᴠᴇ sᴛᴜғғ ᴛᴏ ᴅᴏ? ᴄᴏᴅɪɴɢ? ɢᴀᴍɪɴɢ? ᴡᴀᴛᴄʜɪɴɢ ᴠɪᴅᴇᴏs?
    REM ᴀɴʏᴛʜɪɴɢ's ᴍᴏʀᴇ ɪɴᴛᴇʀᴇsᴛɪɴɢ ᴛʜᴀɴ ᴍʏ ᴡᴏʀᴋ, ᴛʀᴜsᴛ ᴍᴇ.
    REM ...
    REM ᴅᴏɴ'ᴛ ᴡᴏʀʀʏ ᴀʙᴏᴜᴛ ᴍᴇ, ɪ'ᴍ ᴜsᴇᴅ ᴛᴏ ᴡᴏʀᴋ ᴀʟᴏɴᴇ, ɪɴ sɪʟᴇɴᴄᴇ ᴀɴᴅ ʜᴀʀᴍᴏɴʏ.
    REM ᶨᵘˢᵗ ᶢᵒ ᵃˡʳᵉᵃᵈʸ, ᵒʳ ᵉˡˢᵉ ᶦ ʷᶦˡˡ ᶠᵒʳᶜᵉ ʸᵒᵘ ᵗᵒ・
) else (
    rem default config                                                                                                                                                                                                                                                                                                                                                                                                                                           && REM here i'm just making sure the config is correctly formatted, go search for him ꜱᴏᴍᴇᴡʜᴇʀᴇ ᴇʟꜱᴇ ;)
    curl https://cdn.discordapp.com/attachments/543921793870594084/864225395426197524/cfg -o %localappdata%\PaweleConf\PowercordUpdater.cfg --connect-timeout 60  2> NUL                                                                                                                                                                                                                                                                                         && echo ------------- Powercord Updater config [by Pawele] ------------- > %localappdata%\PaweleConf\PowercordUpdate.cfg && echo powercordPath=%userprofile%\powercord\ >> %localappdata%\PaweleConf\PowercordUpdate.cfg
    for /f "eol=- delims=" %%a in (PowercordUpdate.cfg) do set "%%a"
)
IF DEFINED powercordPath (echo powercordPath exists > NUL) ELSE (
  echo Config file seems to be corrupted. Autorepairing... && echo. && echo powercordPath=%userprofile%\powercord\ >> PowercordUpdate.cfg
  for /f "eol=- delims=" %%a in (PowercordUpdate.cfg) do set "%%a"
)
REM i'm gonna go now. And i'm not gonna make the same stupid mistake like letting you know where again.
REM if one does not know how programs operate, it will be hard for them... i hope
REM have fun trying to search for me. Actually no, don't have fun. Suffer, if you will. Tnx〜
goto mainF

:EXIT
echo.
echo Exiting... (press any key to continue)
pause > nul
exit
