@ECHO OFF
SETLOCAL
::::
:::: Minecraft-Forge Server install/launcher script
:::: Version 0.1
:::: Created by: "Ordinator" 
::::
:::: Originally created for use in "All The Mods" modpacks
::::
:::: Latest version:
:::: https://github.com/whatthedrunk/allthemods/blob/master/server-scripts/serverstart.bat
:::: 
:::: This script will fetch the appropriate forge installer
:::: and run it to instal forge AND fetch Minecraft (from Mojang)
:::: If Forge and Minecraft are already installed it will skip
:::: download/install and launch server directly (with 
:::: auto-restart-after-crash logic as well)
::::
:::: IF THERE ARE ANY ISSUES
:::: Please make a report on the AllTheMods github:
:::: https://github.com/whatthedrunk/allthemods/issues
:::: With the contents of [serverstart.log] and [installer.log]
::::
:::: or come find us on Discord: https://discord.gg/FdFDVWb
::::
:::: Special thanks to all the code I Frankensteined from google
:::: There are many sources and references I should have kept
:::: record of but was not diligent. Apologies and thanks all around


::::::::::::::::::::::::::::::::::::
:::: SETTINGS FOR SERVER OWNERS ::::
::::::::::::::::::::::::::::::::::::

::Ram to allocate to modpack
SET MC_SERVER_MAX_RAM=5G

::What to rename forge.jar filename to (possibly needed by some server hosts)
SET MC_SERVER_FORGE_JAR=forge.jar

::Java args to use when launching Modpack
SET MC_SERVER_JVM_ARGS=-server -d64 -Xmx%MC_SERVER_MAX_RAM% -XX:+ExplicitGCInvokesConcurrent -XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses -XX:+UseConcMarkSweepGC -XX:MaxGCPauseMillis=80 -XX:TargetSurvivorRatio=90 -XX:+UseCompressedOops -XX:+OptimizeStringConcat -XX:+AggressiveOpts -XX:+UseCodeCacheFlushing -XX:UseSSE=3

::Number of times the server should crash in a row before it stops auto-restarting.
SET MC_SERVER_MAX_CRASH=10

::Num of seconds since last crash/restart to count towards max-crash total
::If more than this many seconds has passed since last crash, counter will reset.
SET MC_SERVER_CRASH_TIMER=600

::By default this script will stop if running from SYSTEM, PROGRAM FILES or TEMP folders
::If you want to allow this anyway (not recommended) set this value to 1 (default 0)
SET MC_SERVER_RUN_FROM_BAD_FOLDER=0

::This script will check for basic internet connectivity 
::If you want to be able to start server while offline, set this to 1 (default 0)
SET MC_SERVER_IGNORE_OFFLINE=0



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::               MODPACK SETTINGS                   ::::
:::: (defined by pack dev, not intended to be edited) ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET MC_SERVER_MCVER=1.11.2
SET MC_SERVER_FORGEVER=13.20.0.2226

:: Manual link to forge installer to bypass url lookup
:: Mostly just available for troubleshooting/debug purposes
:: set to DISABLE for auto link parse (default: DISABLE)
SET MC_SERVER_FORGEURL=DISABLE

:: It's also possible for modpack devs to distribute the forge installer
:: of the intended forge version by distributing it alongside this script 
:: named "forge-installer.jar" -- If included, downloading  of forge
:: files will be bypassed










:::::::::::::::::::::::::::::::::::::::::::::
:::: There be dragons from here on       ::::
:::: Don't modify unless you pwn dragons ::::
:::::::::::::::::::::::::::::::::::::::::::::

REM Internal Scripty stuff
REM default an error code in case error block is ran without this var being defined first
SET MC_SERVER_ERROR_REASON=Unspecified
REM this is a temp variable to use for intermidiate calculations and such
SET MC_SERVER_TMP_FLAG=0
REM this is the var to keep track of sequential crashes
SET MC_SERVER_CRASH_COUNTER=0
REM set "crash time" to initial script start 
SET MC_SERVER_CRASH_YYYYMMDD=%date:~10,4%%date:~4,2%%date:~7,2%
SET MC_SERVER_CRASH_HHMMSS=%time:~0,2%%time:~3,2%%time:~6,2%


:BEGIN
REM delete log if already exists to start a fresh one
IF EXIST serverstart.log DEL /F /Q serverstart.log
ECHO. 1>> serverstart.log 2>&1
ECHO. 1>> serverstart.log 2>&1
ECHO. 1>> serverstart.log 2>&1
ECHO ----------------------------------------------------------------- 1>> serverstart.log 2>&1
ECHO INFO: Starting batch at %MC_SERVER_CRASH_YYYYMMDD%:%MC_SERVER_CRASH_HHMMSS% 1>> serverstart.log 2>&1
ECHO ----------------------------------------------------------------- 1>> serverstart.log 2>&1

ECHO DEBUG: Starting variable definitions: 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_MAX_RAM=%MC_SERVER_MAX_RAM% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_FORGE_JAR=%MC_SERVER_FORGE_JAR% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_JVM_ARGS=%MC_SERVER_JVM_ARGS% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_MAX_CRASH=%MC_SERVER_MAX_CRASH% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_CRASH_TIMER=%MC_SERVER_CRASH_TIMER% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_IGNORE_OFFLINE=%MC_SERVER_IGNORE_OFFLINE% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_RUN_FROM_BAD_FOLDER=%MC_SERVER_RUN_FROM_BAD_FOLDER% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_MCVER=%MC_SERVER_MCVER% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_FORGEVER=%MC_SERVER_FORGEVER% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_FORGEURL=%MC_SERVER_FORGEURL% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_ERROR_REASON=%MC_SERVER_ERROR_REASON% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_TMP_FLAG=%MC_SERVER_TMP_FLAG% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_CRASH_COUNTER=%MC_SERVER_CRASH_COUNTER% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_CRASH_YYYYMMDD=%MC_SERVER_CRASH_YYYYMMDD% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_CRASH_HHMMSS=%MC_SERVER_CRASH_HHMMSS% 1>> serverstart.log 2>&1


:CHECKFOLDER
IF NOT %MC_SERVER_RUN_FROM_BAD_FOLDER% EQU 0 (
	ECHO WARN: Skipping check if server directory is in potentially problematic location...
	ECHO WARN: Skipping check if server directory is in potentially problematic location... 1>> serverstart.log 2>&1
	GOTO CHECKONLINE
)

ECHO Checking if current folder is valid...
ECHO INFO: Checking if current folder is valid... 1>> serverstart.log 2>&1

REM Check if current directory is in ProgramFiles
IF "%CD%"=="%CD%:%ProgramFiles%=%" (
	SET MC_SERVER_ERROR_REASON=BadFolder-ProgramFiles
	ECHO WARN: Running from Program Files can lead to permissions issues and other errors
	ECHO WARN: If you want to do this anyway, you need change script setting MC_SERVER_RUN_FROM_BAD_FOLDER to 1
	ECHO WARN: Running from Program Files can lead to permissions issues and other errors 1>> serverstart.log 2>&1
	ECHO WARN: If you want to do this anyway, you need change script setting MC_SERVER_RUN_FROM_BAD_FOLDER to 1 1>> serverstart.log 2>&1
	GOTO ERROR
) 

REM Check if current directory is in ProgramFiles(x86)
IF "%CD%"=="%CD%:%ProgramFiles(x86)%=%" (
	SET MC_SERVER_ERROR_REASON=BadFolder-ProgramFiles
	ECHO WARN: Running from Program Files can lead to permissions issues and other errors
	ECHO WARN: If you want to do this anyway, you need change script setting MC_SERVER_RUN_FROM_BAD_FOLDER to 1
	ECHO WARN: Running from Program Files can lead to permissions issues and other errors 1>> serverstart.log 2>&1
	ECHO WARN: If you want to do this anyway, you need change script setting MC_SERVER_RUN_FROM_BAD_FOLDER to 1 1>> serverstart.log 2>&1
	GOTO ERROR
) 

REM Check if current directory is in SystemRoot
IF "%CD%"=="%CD%:%SystemRoot%=%" (
	SET MC_SERVER_ERROR_REASON=BadFolder-System
	ECHO WARN: Running from System folders can lead to permissions issues and other errors
	ECHO WARN: If you want to do this anyway, you need change script setting MC_SERVER_RUN_FROM_BAD_FOLDER to 1
	ECHO WARN: Running from System folders can lead to permissions issues and other errors 1>> serverstart.log 2>&1
	ECHO WARN: If you want to do this anyway, you need change script setting MC_SERVER_RUN_FROM_BAD_FOLDER to 1 1>> serverstart.log 2>&1
	GOTO ERROR
) 

REM Check if current directory is in TEMP
IF "%CD%"=="%CD%:%TEMP%=%" (
	SET MC_SERVER_ERROR_REASON=BadFolder-Temp
	ECHO WARN: Running from 'Temporary Files can lead to permissions issues and data loss
	ECHO WARN: If you want to do this anyway, you need change script setting MC_SERVER_RUN_FROM_BAD_FOLDER to 1
	ECHO WARN: Running from 'Temporary Files can lead to permissions issues and data loss 1>> serverstart.log 2>&1
	ECHO WARN: If you want to do this anyway, you need change script setting MC_SERVER_RUN_FROM_BAD_FOLDER to 1 1>> serverstart.log 2>&1
	GOTO ERROR
) 

REM Check if current directory is in TMP
IF "%CD%"=="%CD%:%TMP%=%" (
	SET MC_SERVER_ERROR_REASON=BadFolder-Temp
	ECHO WARN: Running from 'Temporary Files can lead to permissions issues and data loss
	ECHO WARN: If you want to do this anyway, you need change script setting MC_SERVER_RUN_FROM_BAD_FOLDER to 1
	ECHO WARN: Running from 'Temporary Files can lead to permissions issues and data loss 1>> serverstart.log 2>&1
	ECHO WARN: If you want to do this anyway, you need change script setting MC_SERVER_RUN_FROM_BAD_FOLDER to 1 1>> serverstart.log 2>&1
	GOTO ERROR
) 

:CHECKONLINE
IF NOT %MC_SERVER_IGNORE_OFFLINE% EQU 0 (
	ECHO Skipping internet connectivity check...
	ECHO WARN: Skipping internet connectivity check... 1>> serverstart.log 2>&1
	GOTO CHECKFILES
)

ECHO Checking for basic internet connectivity...
ECHO INFO: Checking for basic internet connectivity... 1>> serverstart.log 2>&1

REM Try with Google DNS
PING -n 2 -w 1000 8.8.8.8 | find "bytes="  1>> serverstart.log 2>&1
IF %ERRORLEVEL% EQU 0 (
    SET MC_SERVER_TMP_FLAG=0
	ECHO INFO: Ping of "8.8.8.8" Successfull 1>> serverstart.log 2>&1
) ELSE (
    SET MC_SERVER_TMP_FLAG=1
	ECHO WARN: Ping of "8.8.8.8" Failed 1>> serverstart.log 2>&1
)

REM If Google ping failed try one more time with L3 just in case
IF MC_SERVER_TMP_FLAG EQU 1 (
	PING -n 2 -w 1000 4.2.2.1 | find "bytes="  1>> serverstart.log 2>&1
	IF %ERRORLEVEL% EQU 0 (
		SET MC_SERVER_TMP_FLAG=0
		INFO: Ping of "4.4.2.1" Successfull 1>> serverstart.log 2>&1
	) ELSE (
		SET MC_SERVER_TMP_FLAG=1
		ECHO WARN: Ping of "4.4.2.1" Failed 1>> serverstart.log 2>&1
	)
)

REM Possibly no internet connection...
IF MC_SERVER_TMP_FLAG EQU 1 (
	ECHO ERROR: No internet connectivity found
	ECHO ERROR: No internet connectivity found 1>> serverstart.log 2>&1
	SET MC_SERVER_ERROR_REASON=NoInternetConnectivity
	GOTO ERROR
	)

	
:CHECKFILES
ECHO Checking for forge/minecraft binaries...
ECHO INFO: Checking for forge/minecraft binaries... 1>> serverstart.log 2>&1

REM Check if forge is already installed
IF NOT EXIST "%CD%\%MC_SERVER_FORGE_JAR%" (
	ECHO FORGE not found, re-installing...
	ECHO INFO: FORGE not found, re-installing... 1>> serverstart.log 2>&1
	GOTO INSTALLSTART
)

REM Check if Minecraft JAR is already downloaded
IF NOT EXIST "%CD%\minecraft_server.%MC_SERVER_MCVER%.jar" (
	ECHO Minecraft binary not found, re-installing Forge...
	ECHO INFO: Minecraft binary not found, re-installing Forge...  1>> serverstart.log 2>&1
	GOTO INSTALLSTART
)

REM Check if Libraries are already downloaded
IF NOT EXIST "%CD%\libraries" (
	ECHO Libraries not found, re-installing Forge...
	ECHO INFO: Libraries not found, re-installing Forge... 1>> serverstart.log 2>&1
	GOTO INSTALLSTART
)


:STARTSERVER
ECHO.
ECHO.
ECHO Starting Server...
ECHO INFO: Starting Server... 1>> serverstart.log 2>&1

REM Batch will wait here indefinetly while MC server is running
java %MC_SERVER_JVM_ARGS% -jar %MC_SERVER_FORGE_JAR% nogui

REM If server is exited or crashes, restart...
ECHO WARN: Server was stopped (possibly crashed)...
GOTO RESTARTER


:INSTALLSTART
ECHO Clearing old files and installing forge/minecraft...
ECHO INFO: Clearing and installing forge/minecraft... 1>> serverstart.log 2>&1

REM Just in case there's anything pending or dupe-named before starting...
bitsadmin /reset

REM Check for existing/included forge-installer and run it instead of downloading
IF EXIST forge-installer.jar (
	ECHO Existing forge-installer.jar already found...
	ECHO Default is to use this installer and not re-download
	
	REM Short 5-second choice if user wants to download anyway
	CHOICE /M:"Use Existing Installer JAR (Y) or Download new from forge (N)" /T:5 /D:Y
	IF %ERRORLEVEL% EQU 0 (
		GOTO RUNINSTALLER
	) ELSE (
		DEL /F /Q forge-installer.jar 1>> serverstart.log 2>&1
	)
)

DEL /F /Q "%CD%\forge-index.html" 1>> serverstart.log 2>&1
DEL /F /Q "%CD%\%MC_SERVER_FORGE_JAR%" 1>> serverstart.log 2>&1
DEL /F /Q "%CD%\forge-installer-temp.jar"  1>> serverstart.log 2>&1
RMDIR /S /Q "%CD%\libraries"  1>> serverstart.log 2>&1

REM Check if direct forge URL is specified in config
IF NOT %MC_SERVER_FORGEURL%==DISABLE GOTO DOWNLOADINSTALLER

REM Download Forge Download Index HTML to parse the URL for the direct download
bitsadmin /rawreturn /nowrap /transfer dlforgehtml /download /priority normal "https://files.minecraftforge.net/maven/net/minecraftforge/forge/index_%MC_SERVER_MCVER%.html" "%CD%\forge-%MC_SERVER_MCVER%.html"  1>> serverstart.log 2>&1

IF NOT EXIST forge-%MC_SERVER_MCVER%.html (
	SET MC_SERVER_ERROR_REASON=ForgeIndexNotFound
	GOTO ERROR
)

REM Simple search for matching text to make sure we got the correct webpage/html (and not a 404, for example)
ECHO DEBUG: Simple pattern match for forge ver errorlevel: %ERRORLEVEL% 1>> serverstart.log 2>&1
FIND /c:"%MC_SERVER_FORGEVER%" "%CD%\forge-%MC_SERVER_MCVER%.html" 1>> serverstart.log 2>&1
IF %ERRORLEVEL% EQU 0 (
	SET MC_SERVER_ERROR_REASON=ForgeDownloadURLNotFound
	GOTO ERROR
)

REM More complex wannabe-regex (aka magic)
FOR /f tokens^=^5^ delims^=^=^<^>^" %%G in ('findstr /ir "http:\/\/files.*%MC_SERVER_FORGEVER%.*installer.jar" "%CD%\forge-%MC_SERVER_MCVER%.html"') DO SET MC_SERVER_FORGEURL=%%G

if "%MC_SERVER_FORGEURL%"=="%MC_SERVER_FORGEURL:installer.jar=%" (
	SET MC_SERVER_ERROR_REASON=ForgeDownloadURLNotFound
	GOTO ERROR
) 


:DOWNLOADINSTALLER
ECHO Attempting to download "%MC_SERVER_FORGEURL%... this can take a moment, please wait." 
ECHO DEBUG: Attempting to download "%MC_SERVER_FORGEURL%" 1>> serverstart.log 2>&1

REM Attempt to download installer to a temp download
bitsadmin /rawreturn /nowrap /transfer dlforgeinstaller /download /priority normal "%MC_SERVER_FORGEURL%" "%CD%\forge-installer-temp.jar"  1>> serverstart.log 2>&1

REM Check that temp-download installer was downloaded
IF NOT EXIST "%CD%\forge-installer-temp.jar" (
	SET MC_SERVER_ERROR_REASON=ForgeInstallerDownloadFailed
	GOTO ERROR
)

REM Rename temp installer to proper installer, replacing one that was there already
DEL /F /Q forge-installer.jar  1>> serverstart.log 2>&1
REN forge-installer-temp.jar forge-installer.jar  1>> serverstart.log 2>&1


:RUNINSTALLER
ECHO.
ECHO Installing Forge now, please wait...
ECHO INFO: Starting Forge install now, details below: 1>> serverstart.log 2>&1
java -jar forge-installer.jar --installServer 1>> serverstart.log 2>&1

REM I'm not sure how to check if the forge-install failed or not...
ECHO DEBUG: ERRORLEVEL after running forge installer: %ERRORLEVEL% 1>> serverstart.log 2>&1
IF NOT %errorlevel% equ 0 (
	SET MC_SERVER_ERROR_REASON=ForgeInstallFailed
	GOTO ERROR
)

REM File cleanup
REN forge*universal.jar %MC_SERVER_FORGE_JAR%  1>> serverstart.log 2>&1
DEL /F /Q forge-installer.jar  1>> serverstart.log 2>&1
DEL /F /Q forge-%MC_SERVER_MCVER%.html  1>> serverstart.log 2>&1

REM Todo... maybe add check for libraries, minecraft and forge jar confirming install success?

ECHO.
ECHO.
ECHO.
ECHO.
ECHO Forge and Minecraft Download/Install complete!
ECHO INFO: Download/Install complete... 1>> serverstart.log 2>&1
ECHO.
TIMEOUT 5

GOTO STARTSERVER


:ERROR
ECHO There was an Error...
ECHO Error returned was "%MC_SERVER_ERROR_REASON%"
ECHO ERROR: Error flagged, reason is: "%MC_SERVER_ERROR_REASON%" 1>> serverstart.log 2>&1
ECHO.
GOTO CLEANUP


:RESTARTER
ECHO ERROR: At %MC_SERVER_CRASH_YYYYMMDD%:%MC_SERVER_CRASH_HHMMSS% Server has stopped. 1>> serverstart.log 2>&1
ECHO At %MC_SERVER_CRASH_YYYYMMDD%:%MC_SERVER_CRASH_HHMMSS% Server has stopped.
ECHO Server has %MC_SERVER_CRASH_COUNTER% consecutive stops, each within %MC_SERVER_CRASH_TIMER% seconds of eachother...
ECHO DEBUG: Server has %MC_SERVER_CRASH_COUNTER% consecutive stops, each within %MC_SERVER_CRASH_TIMER% seconds of eachother... 1>> serverstart.log 2>&1
ECHO.

REM Arithmetic to check DAYS since last crash
REM Testing working in USA region. Hoping other regional formats don't mess it up
SET /a MC_SERVER_TMP_FLAG="%date:~10,4%%date:~4,2%%date:~7,2%-%MC_SERVER_CRASH_YYYYMMDD%"

REM If more than one calendar day, reset timer/counter.
REM Yes, this means over midnight it's not accurate.
REM Nobody's perfect.
IF %MC_SERVER_TMP_FLAG% GTR 0 (
	ECHO More than one day since last crash/restart... resetting counter/timer
	ECHO INFO: More than one day since last crash/restart... resetting counter/timer 1>> serverstart.log 2>&1
	SET MC_SERVER_CRASH_YYYYMMDD=%date:~10,4%%date:~4,2%%date:~7,2%
	SET MC_SERVER_CRASH_HHMMSS=%time:~0,2%%time:~3,2%%time:~6,2%
	SET MC_SERVER_CRASH_COUNTER=0
	GOTO STARTSERVER
)

REM Arithmetic to check SECONDS since last crash
SET /a MC_SERVER_TMP_FLAG="%time:~0,2%%time:~3,2%%time:~6,2%-%MC_SERVER_CRASH_HHMMSS%"

REM If more than specified seconds (from config variable), reset timer/counter.	
IF %MC_SERVER_TMP_FLAG% GTR %MC_SERVER_CRASH_TIMER% (
	ECHO Last crash/startup was %MC_SERVER_TMP_FLAG%+ seconds ago
	ECHO INFO: Last crash/startup was %MC_SERVER_TMP_FLAG%+ seconds ago 1>> serverstart.log 2>&1
	ECHO More than %MC_SERVER_CRASH_TIMER% seconds since last crash/restart... resetting counter/timer
	ECHO INFO: More than %MC_SERVER_CRASH_TIMER% seconds since last crash/restart... resetting counter/timer 1>> serverstart.log 2>&1
	SET MC_SERVER_CRASH_YYYYMMDD=%date:~10,4%%date:~4,2%%date:~7,2%
	SET MC_SERVER_CRASH_HHMMSS=%time:~0,2%%time:~3,2%%time:~6,2%
	SET MC_SERVER_CRASH_COUNTER=0
	GOTO STARTSERVER
)

REM If we are still here, time difference is within threshold to increment counter
REM Check if already max failures:
IF %MC_SERVER_CRASH_COUNTER% GEQ %MC_SERVER_MAX_CRASH% (
	ECHO INFO: Last crash/startup was %MC_SERVER_TMP_FLAG%+ seconds ago 1>> serverstart.log 2>&1
	ECHO ERROR: Server has stopped/crashed too many times!
	ECHO ERROR: Server has stopped/crashed too many times! 1>> serverstart.log 2>&1
	ECHO Stopping script...
	TIMEOUT 5
	GOTO CLEANUP
	)

REM Still under threshold so lets increment and restart
ECHO INFO: Last crash/startup was %MC_SERVER_TMP_FLAG%+ seconds ago 1>> serverstart.log 2>&1
SET /a "MC_SERVER_CRASH_COUNTER=%MC_SERVER_CRASH_COUNTER%+1"
SET MC_SERVER_CRASH_YYYYMMDD=%date:~10,4%%date:~4,2%%date:~7,2%
SET MC_SERVER_CRASH_HHMMSS=%time:~0,2%%time:~3,2%%time:~6,2%

REM ECHO Total consecutive crash/stops within time threshold: %MC_SERVER_CRASH_COUNTER%
REM ECHO DEBUG: Total consecutive crash/stops within time threshold: %MC_SERVER_CRASH_COUNTER% 1>> serverstart.log 2>&1
ECHO.
ECHO.
ECHO.
ECHO.
ECHO Server will re-start *automatically* in less than 30 seconds...
CHOICE /M:"Restart now (Y) or Exit (N)" /T:30 /D:Y
IF %ERRORLEVEL% GEQ 2 (
	ECHO INFO: Server manually stopped before auto-restart 1>> serverstart.log 2>&1
	GOTO CLEANUP
) ELSE ( 
	GOTO STARTSERVER
)


:CLEANUP
ECHO WARN: Server startup script is exiting. Dumping current vars: 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_MAX_RAM=%MC_SERVER_MAX_RAM% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_FORGE_JAR=%MC_SERVER_FORGE_JAR% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_JVM_ARGS=%MC_SERVER_JVM_ARGS% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_MAX_CRASH=%MC_SERVER_MAX_CRASH% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_CRASH_TIMER=%MC_SERVER_CRASH_TIMER% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_IGNORE_OFFLINE=%MC_SERVER_IGNORE_OFFLINE% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_RUN_FROM_BAD_FOLDER=%MC_SERVER_RUN_FROM_BAD_FOLDER% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_MCVER=%MC_SERVER_MCVER% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_FORGEVER=%MC_SERVER_FORGEVER% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_FORGEURL=%MC_SERVER_FORGEURL% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_ERROR_REASON=%MC_SERVER_ERROR_REASON% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_TMP_FLAG=%MC_SERVER_TMP_FLAG% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_CRASH_COUNTER=%MC_SERVER_CRASH_COUNTER% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_CRASH_YYYYMMDD=%MC_SERVER_CRASH_YYYYMMDD% 1>> serverstart.log 2>&1
ECHO DEBUG: MC_SERVER_CRASH_HHMMSS=%MC_SERVER_CRASH_HHMMSS% 1>> serverstart.log 2>&1
ECHO DEBUG: Current directory file listing: 1>> serverstart.log 2>&1
DIR 1>> serverstart.log 2>&1
ECHO DEBUG: JAVA version output (java -d64 -version): 1>> serverstart.log 2>&1
java -d64 -version 1>> serverstart.log 2>&1

REM Clear variables -- probably not necessary since we SETLOCAL but doesn't hurt either
SET MC_SERVER_MAX_RAM=
SET MC_SERVER_FORGE_JAR=
SET MC_SERVER_JVM_ARGS=
SET MC_SERVER_MAX_CRASH=
SET MC_SERVER_CRASH_TIMER=
SET MC_SERVER_IGNORE_OFFLINE=
SET MC_SERVER_RUN_FROM_BAD_FOLDER=
SET MC_SERVER_MCVER=
SET MC_SERVER_FORGEVER=
SET MC_SERVER_FORGEURL=
SET MC_SERVER_ERROR_REASON=
SET MC_SERVER_TMP_FLAG=
SET MC_SERVER_CRASH_COUNTER=
SET MC_SERVER_CRASH_YYYYMMDD=
SET MC_SERVER_CRASH_HHMMSS=

REM Reset bitsadmin in case things got hung or errored
bitsadmin /reset


TIMEOUT 3
:EOF
