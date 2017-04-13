@ECHO ON
SETLOCAL
::::
:::: Minecraft-Forge Server install/launcher script
:::: Created by the "All The Mods" pack team
::::
:::: This script will setup and start the minecraft server
::::
:::: THIS FILE NOT INTENDED TO BE EDITED, USE "settings.cfg" INSTEAD
::::
:::: FOR HELP (or more details);
::::    Github:   https://github.com/AllTheMods/Server-Scripts
::::    Discord:  https://discord.gg/FdFDVWb
::::


::::::::::::::::::::::::::::::::::::::::::::::::
:::: There be dragons from here onward !!!  ::::
:::: Don't modify unless you pwn dragons... ::::
::::::::::::::::::::::::::::::::::::::::::::::::


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

REM delete log if already exists to start a fresh one
IF EXIST serverstart.log DEL /F /Q serverstart.log
ECHO. 1>> serverstart.log 2>&1
ECHO. 1>> serverstart.log 2>&1
ECHO. 1>> serverstart.log 2>&1
ECHO ----------------------------------------------------------------- 1>> serverstart.log 2>&1
ECHO INFO: Starting batch at %MC_SERVER_CRASH_YYYYMMDD%:%MC_SERVER_CRASH_HHMMSS% 1>> serverstart.log 2>&1
ECHO ----------------------------------------------------------------- 1>> serverstart.log 2>&1

:BEGIN
REM Check for config file
ECHO INFO: Checking that settings.cfg exists 1>> serverstart.log 2>&1
IF NOT EXIST "%CD%\settings.cfg" (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Not_Found
	GOTO ERROR
)

ECHO DEBUG: settings.cfg Found. Logging full contents below: 1>> serverstart.log 2>&1
REM >>serverstart.log TYPE settings.cfg
>nul COPY serverstart.log+settings.cfg serverstart.log
ECHO. 1>> serverstart.log 2>&1

>nul FIND /I "MAX_RAM=" settings.cfg || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error
	GOTO ERROR
	)

>nul FIND /I "JAVA_ARGS=" settings.cfg || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error
	GOTO ERROR
	)

>nul FIND /I "CRASH_COUNT=" settings.cfg || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error
	GOTO ERROR
	)

>nul FIND /I "CRASH_TIMER=" settings.cfg || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error
	GOTO ERROR
	)
	
>nul FIND /I "RUN_FROM_BAD_FOLDER=" settings.cfg || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error
	GOTO ERROR
	)
	
>nul FIND /I "IGNORE_OFFLINE=" settings.cfg || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error
	GOTO ERROR
	)	

>nul FIND /I "MCVER=" settings.cfg || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error
	GOTO ERROR
	)	

>nul FIND /I "FORGEVER=" settings.cfg || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error
	GOTO ERROR
	)	

>nul FIND /I "FORGEURL=" settings.cfg || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error
	GOTO ERROR
	)		
	
REM  LOAD Settings from config
ECHO INFO: Loading variables from settings.cfg 1>> serverstart.log 2>&1
for /f "delims==; tokens=1,2" %%G in (settings.cfg) do set %%G=%%H

REM Re-map imported vars
SET MC_SERVER_MAX_RAM=%MAX_RAM%
REM SET MC_SERVER_FORGE_JAR=%FORGE_JAR%
SET MC_SERVER_JVM_ARGS=-Xmx%MC_SERVER_MAX_RAM% %JAVA_ARGS%
SET MC_SERVER_MAX_CRASH=%CRASH_COUNT%
SET MC_SERVER_CRASH_TIMER=%CRASH_TIMER%
SET MC_SERVER_RUN_FROM_BAD_FOLDER=%RUN_FROM_BAD_FOLDER%
SET MC_SERVER_IGNORE_OFFLINE=%IGNORE_OFFLINE%
SET MC_SERVER_MCVER=%MCVER%
SET MC_SERVER_FORGEVER=%FORGEVER%
SET MC_SERVER_FORGEURL=%FORGEURL%

REM Cleanup imported vars after being remapped
SET MAX_RAM=
SET FORGE_JAR=
SET JAVA_ARGS=
SET CRASH_COUNT=
SET CRASH_TIMER=
SET RUN_FROM_BAD_FOLDER=
SET IGNORE_OFFLINE=
SET MCVER=
SET FORGEVER=
SET FORGEURL=

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

:CHECKJAVA
ECHO INFO: Checking java installation...
ECHO INFO: Checking java installation: 1>> serverstart.log 2>&1

java -d64 -version 2>&1 | FIND "1.8" 1>> serverstart.log 2>&1
IF %ERRORLEVEL% EQU 0 (
	ECHO INFO: Found 64-bit Java 1.8 1>> serverstart.log 2>&1
) ELSE (
    java -d64 -version 2>&1 | FIND "1.9" 1>> serverstart.log 2>&1
	IF %ERRORLEVEL% EQU 0 (
		ECHO INFO: Found 64-bit Java 1.9 1>> serverstart.log 2>&1
	) ELSE (
		ECHO ERROR: Could not find 64-bit Java 1.8 or 1.9 installed or in PATH 1>> serverstart.log 2>&1
		CLS
		ECHO.
		ECHO ERROR: Could not find valid java version installed. 
		ECHO 64-bit Java ver 1.8+ is required. Check here for latest downloads:
		ECHO https://java.com/en/download/manual.jsp
		ECHO.
		SET MC_SERVER_ERROR_REASON="JavaVersionOrPathError"
		GOTO ERROR
	)

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
IF NOT EXIST "%CD%\*forge*%MC_SERVER_FORGEVER%*universal*.jar" (
	ECHO FORGE %MC_SERVER_FORGEVER% binary not found, re-installing...
	ECHO INFO: FORGE %MC_SERVER_FORGEVER% not found, re-installing... 1>> serverstart.log 2>&1
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
	ECHO Libraries folder not found, re-installing Forge...
	ECHO INFO: Libraries folder not found, re-installing Forge... 1>> serverstart.log 2>&1
	GOTO INSTALLSTART
)

FOR /f %%x in ('dir *forge*%MC_SERVER_FORGEVER%*universal*.jar /B /O:-D') DO SET MC_SERVER_FORGE_JAR=%%x & GOTO STARTSERVER

:STARTSERVER
ECHO.
ECHO.
ECHO Starting Server...
ECHO INFO: Starting Server... 1>> serverstart.log 2>&1

REM Batch will wait here indefinetly while MC server is running
java %MC_SERVER_JVM_ARGS% -jar %MC_SERVER_FORGE_JAR% nogui

REM If server is exited or crashes, restart...
REM CLS
ECHO.
ECHO WARN: Server was stopped (possibly crashed)...

:CHECKEULA
>nul FIND /I "eula=true" eula.txt && (
	ECHO.
	GOTO RESTARTER
) || (
	ECHO.
	ECHO Could not find "eula=true" in eula.txt file
	ECHO Please edit and save the EULA file before continuing.
	ECHO.
	PAUSE
	GOTO CHECKEULA
	)

:INSTALLSTART
ECHO Clearing old files and installing forge/minecraft...
ECHO INFO: Clearing and installing forge/minecraft... 1>> serverstart.log 2>&1

REM Just in case there's anything pending or dupe-named before starting...
bitsadmin /reset 1>> serverstart.log 2>&1

REM Check for existing/included forge-installer and run it instead of downloading
IF EXIST forge-%MC_SERVER_MCVER%-%MC_SERVER_FORGEVER%-installer.jar (
	ECHO.
	ECHO.
	ECHO Existing forge installer already found...
	ECHO Default is to use this installer and not re-download
	GOTO RUNINSTALLER
)

REM Ping minecraftforge before attempting download
PING -n 2 -w 1000 minecraftforge.net | find "bytes="  1>> serverstart.log 2>&1
IF %ERRORLEVEL% EQU 0 (
	ECHO INFO: Ping of "minecraftforge.net" Successfull 1>> serverstart.log 2>&1
) ELSE (
	ECHO ERROR: Could not reach minecraftforge.net! Possible firewall or internet issue?
	ECHO ERROR: Could not reach minecraftforge.net 1>> serverstart.log 2>&1
	SET MC_SERVER_ERROR_REASON=NoInternetConnectivityMinecraftForgeNet
	GOTO ERROR

DEL /F /Q "%CD%\forge-index.html" 1>> serverstart.log 2>&1
DEL /F /Q "%CD%\*forge*%MC_SERVER_FORGEVER%*universal*" 1>> serverstart.log 2>&1
DEL /F /Q "%CD%\tmp-forgeinstaller.jar"  1>> serverstart.log 2>&1
RMDIR /S /Q "%CD%\libraries"  1>> serverstart.log 2>&1

ECHO.
ECHO.
ECHO Downloading FORGE (step 1 of 2). This can take several minutes, please be patient...

REM Check if direct forge URL is specified in config
IF NOT %MC_SERVER_FORGEURL%==DISABLE (
	ECHO Attempting to download "%MC_SERVER_FORGEURL%... this can take a moment, please wait." 
	GOTO DOWNLOADINSTALLER
)

REM Download Forge Download Index HTML to parse the URL for the direct download
ECHO INFO: Fetching index html from forge 1>> serverstart.log 2>&1
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

ECHO Downloading FORGE (step 2 of 2). This can take several minutes, please be patient...

:DOWNLOADINSTALLER
ECHO DEBUG: Attempting to download "%MC_SERVER_FORGEURL%" 1>> serverstart.log 2>&1

REM Attempt to download installer to a temp download
bitsadmin /rawreturn /nowrap /transfer dlforgeinstaller /download /priority normal "%MC_SERVER_FORGEURL%" "%CD%\tmp-forgeinstaller.jar"  1>> serverstart.log 2>&1

REM Check that temp-download installer was downloaded
IF NOT EXIST "%CD%\tmp-forgeinstaller.jar" (
	SET MC_SERVER_ERROR_REASON=ForgeInstallerDownloadFailed
	GOTO ERROR
)

REM Rename temp installer to proper installer, replacing one that was there already
DEL /F /Q forge-%MC_SERVER_MCVER%-%MC_SERVER_FORGEVER%-installer.jar  1>> serverstart.log 2>&1
REN tmp-forgeinstaller.jar forge-%MC_SERVER_MCVER%-%MC_SERVER_FORGEVER%-installer.jar  1>> serverstart.log 2>&1
ECHO Download complete.

:RUNINSTALLER
ECHO.
ECHO Installing Forge now, please wait...
ECHO INFO: Starting Forge install now, details below: 1>> serverstart.log 2>&1
java -jar forge-%MC_SERVER_MCVER%-%MC_SERVER_FORGEVER%-installer.jar --installServer 1>> serverstart.log 2>&1

REM TODO: CHECKS TO VALIDATE SUCCESSFUL INSTALL

REM File cleanup
DEL /F /Q tmp-forgeinstaller.jar  1>> serverstart.log 2>&1
DEL /F /Q forge-%MC_SERVER_MCVER%.html  1>> serverstart.log 2>&1

CLS
ECHO.
ECHO Forge and Minecraft Download/Install complete!
ECHO INFO: Download/Install complete... 1>> serverstart.log 2>&1
ECHO.
TIMEOUT 3

GOTO BEGIN

:ERROR
ECHO There was an Error, Code: "%MC_SERVER_ERROR_REASON%"
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
	GOTO BEGIN
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
	REM GOTO BEGIN
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
	GOTO BEGIN
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
bitsadmin /reset 1>> serverstart.log 2>&1

:EOF
