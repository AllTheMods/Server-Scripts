#!/bin/bash

#### Minecraft-Forge Server install/launcher script
#### Linux Version
####
#### Created by: Dijkstra
#### Mascot: Ordinator
####
#### Originally created for use in "All The Mods" modpacks
#### NO OFFICIAL AFFILIATION WITH MOJANG OR FORGE
####
#### This script will fetch the appropriate forge installer
#### and run it to install forge AND fetch Minecraft (from Mojang)
#### If Forge and Minecraft are already installed it will skip
#### download/install and launch server directly (with
#### auto-restart-after-crash logic as well)
####
#### Make sure this is running as BASH
#### You might need to chmod +x before executing
####
#### IF THERE ARE ANY ISSUES
#### Please make a report on the AllTheMods github:
#### https://github.com/AllTheMods/Server-Scripts
#### with the contents of [logs/serverstart.log] and [installer.log]
####
#### or come find us on Discord: https://discord.gg/FdFDVWb
####

eula_gen(){
    echo "By typing Yes you are indicating your agreement to the Minecraft EULA (https://account.mojang.com/documents/minecraft_eula)."
    echo "Please read the EULA linked above"
    
    export answer="No"
    echo ""
    read -r -p "Type Yes is agree otherwise type No? " answer
    if [[ "$answer" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        echo "INFO: EULA accepted" >>logs/serverstart.log 2>&1
        echo "#Minecraft EULA (https://account.mojang.com/documents/minecraft_eula)." > eula.txt
        echo "eula=true" >> eula.txt
    else
        echo "INFO: EULA rejected" >>logs/serverstart.log 2>&1
        echo "#Minecraft EULA (https://account.mojang.com/documents/minecraft_eula)." > eula.txt
        echo "eula=false" >> eula.txt
        exit 0
    fi
}

install_server(){
    echo "Starting install of Forge/Minecraft server binaries"
    echo "DEBUG: Starting install of Forge/Minecraft server binaries" >>logs/serverstart.log
    
    
    installers=$(ls forge*"$MC_SERVER_MCVER"*"$MC_SERVER_FORGEVER"*installer.jar 2>>logs/serverstart.log)
    if [[ $? == 0 ]]; then
        installer=${installers[0]}
        echo "DEBUG: Found forge jar: $installer" >>logs/serverstart.log
        export answer="y"
        if [[ $MC_SERVER_AUTO_RESPOND == 0 ]]; then
            read -r -t 8 -p "Installer found. Use it (y) or download again (n)?  " answer
        fi
        if [[ "$answer" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
            echo "INFO: Skipping download. Using existing installer.jar" >>logs/serverstart.log 2>&1
            echo "Skipping download. Using existing installer.jar"
        else
            echo "Moving current installer to ./DELETEME"
            mkdir -p DELETEME
            mv -f "./$installer" ./DELETEME >>logs/serverstart.log 2>&1
            installer=0
        fi
    else
        installer=0
    fi
    
    if [[ $installer == 0 ]]; then
        echo "DEBUG: no forge installer for MCVER: $MC_SERVER_MCVER and FORGEVER: $MC_SERVER_FORGEVER found"  >>logs/serverstart.log
        echo "No installer found will try to download it"
        
        if [ "${MC_SERVER_FORGEURL}" = "DISABLE" ]; then
            export MC_SERVER_URL="https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MC_SERVER_MCVER}-${MC_SERVER_FORGEVER}/forge-${MC_SERVER_MCVER}-${MC_SERVER_FORGEVER}-installer.jar"
        else
            export MC_SERVER_URL="${MC_SERVER_FORGEURL}"
        fi
        
        command - v curl >> /dev/null 2>&1
        if [[ $? == 0 ]]; then
            echo "DEBUG: (curl) Downloading ${MC_SERVER_URL}" >>logs/serverstart.log 2>&1
            curl -OJL "${MC_SERVER_URL}" >>logs/serverstart.log 2>&1
        else
            command -v wget >> /dev/null 2>&1
            if [[ $? == 0 ]]; then
                echo "DEBUG: (wget) Downloading ${MC_SERVER_URL}" >>logs/serverstart.log 2>&1
                wget -O "forge.$MC_SERVER_MCVER-$MC_SERVER_FORGEVER-installer.jar" "${MC_SERVER_URL}" >>logs/serverstart.log 2>&1
            else
                echo "Neither wget or curl were found on your system. Please install one and try again"
                echo "ERROR: Neither wget or curl were found" >>logs/serverstart.log 2>&1
                exit 1
            fi
        fi
    fi
    
    installers=$(ls forge*"$MC_SERVER_MCVER"*"$MC_SERVER_FORGEVER"*installer.jar 2>>logs/serverstart.log)
    if [[ $? -eq 0 ]] ; then
        installer=${installers[0]}
        export MC_SERVER_INSTALLER=$installer
        echo "Moving unneeded files/folders to ./DELETEME"
        {
            echo "INFO: Moving unneeded files/folders to ./DELETEME"
            rm -rf ./DELETEME
            mv -f ./asm ./DELETEME
            mv -f ./libraries ./DELETEME
            mv -f ./library ./DELETEME
            mv -f ./minecraft_server*.jar ./DELETEME
            mv -f ./forge*universal.jar ./DELETEME
            mv -f ./OpenComputersMod*lua* ./DELETEME
        } >>logs/serverstart.log 2>&1
        echo "Installing Forge Server, please wait..."
        echo "INFO: Installing Forge Server" >>logs/serverstart.log 2>&1
        "$MC_SERVER_JAVA" -jar "$installer" --installServer   >>logs/serverstart.log 2>&1
        
    else
        echo "Forge installer did not download"
        echo "ERROR: Forge installer did not download" >>logs/serverstart.log 2>&1
        exit 1
    fi
}

# Make sure users aren't trying to run script via sh directly (won't work)
if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0). Use bash instead (or execute it directly)" 1>&2
    exit 1
fi

#Checks what system the script is being run under
case "$(uname -s)" in
    Linux*)     MC_SERVER_environment=Linux;;
    Darwin*)    MC_SERVER_environment=Mac;;
    CYGWIN*)    MC_SERVER_environment=Cygwin;;
    MINGW*)     MC_SERVER_environment=MinGw;;
    *)          MC_SERVER_environment="UNKNOWN:$(uname -s)"
esac

#Makes sure that the script is being ran from the server directory
cd "${0%/*}" || exit
mkdir -p logs

echo "INFO: Starting script at $(date -u +%Y-%m-%d_%H:%M:%S)" >logs/serverstart.log

#Loading settings

#Default Settings
export MC_SERVER_MAX_RAM=5G
export MC_SERVER_GAME_ARGS=nogui
export MC_SERVER_JAVA_ARGS='-server -XX:+AggressiveOpts -XX:ParallelGCThreads=3 -XX:+UseConcMarkSweepGC -XX:+UnlockExperimentalVMOptions -XX:+UseParNewGC -XX:+ExplicitGCInvokesConcurrent -XX:MaxGCPauseMillis=10 -XX:GCPauseIntervalMillis=50 -XX:+UseFastAccessorMethods -XX:+OptimizeStringConcat -XX:NewSize=84m -XX:+UseAdaptiveGCBoundary -XX:NewRatio=3'
export MC_SERVER_CRASH_COUNT=5
export MC_SERVER_CRASH_TIMER=600
export MC_SERVER_JAVA_PATH=DISABLE
export MC_SERVER_RUN_FROM_BAD_FOLDER=0
export MC_SERVER_IGNORE_OFFLINE=0
export MC_SERVER_IGNORE_JAVA_CHECK=0
export MC_SERVER_USE_SPONGE=0
export MC_SERVER_HIGH_CPU_PRIORITY=0
export MC_SERVER_JMX_ENABLE=0
export MC_SERVER_JMX_PORT=9010
export MC_SERVER_JMX_HOST=127.0.0.1
export MC_SERVER_MODPACK_NAME=PACK NAME
export MC_SERVER_DEFAULT_WORLD_TYPE=BIOMESOP
export MC_SERVER_MCVER=1.12.2
export MC_SERVER_FORGEVER=14.23.5.2811
export MC_SERVER_FORGEURL=DISABLE
export MC_SERVER_AUTO_RESPOND=0
export MC_SERVER_INSTALL_ONLY=0

#Loading setting.cfg
if [ -f ./settings.cfg ]; then
    #Read the config file line by line
    while IFS=$'\n\r' read -r line || [[ -n "$line" ]]; do
        #Fliters out comments and empty lines
        if [[ ${line:0:1} != ';' ]] && [[ $line = *[!\ ]* ]]; then
            var="MC_SERVER_"$(echo "$line" | cut -d '=' -f 1)
            value=$(echo "$line" | cut -d '=' -f 2-)
            export "$var"="$value"
        fi
    done < ./settings.cfg
else
    echo "Failed to find settings file default settings will be used may cause issues"
    echo "WARN: Failed to find settings.cfg" >>logs/serverstart.log
fi

while :; do
    case $1 in
        -a|--auto) export MC_SERVER_AUTO_RESPOND=1
        ;;
        -i|--install|install) export MC_SERVER_INSTALL_ONLY=1
        ;;
        *) break
    esac
    shift
done

export MC_SERVER_FORGESHORT=${MC_SERVER_FORGEVER: - 4}

if [[ "$MC_SERVER_JAVA_PATH" == "DISABLE" ]]; then
    export MC_SERVER_JAVA=java
else
    command -v $MC_SERVER_JAVA_PATH/java >/dev/null
    if [[ $? == "0" ]]; then
        export MC_SERVER_JAVA=$MC_SERVER_JAVA_PATH/java
    else
        echo "Could not find java if path in given in settings using the deflut option"
        echo "WARN: Could not find java if path in given in settings" >>logs/serverstart.log
        export MC_SERVER_JAVA=java
    fi
fi
{
    echo "DEBUG: Dumping starting variables: "
    echo "DEBUG: MC_SERVER_MAX_RAM=$MC_SERVER_MAX_RAM"
    echo "DEBUG: MC_SERVER_GAME_ARGS=$MC_SERVER_GAME_ARGS"
    echo "DEBUG: MC_SERVER_JAVA_ARGS=$MC_SERVER_JAVA_ARGS"
    echo "DEBUG: MC_SERVER_CRASH_COUNT=$MC_SERVER_CRASH_COUNT"
    echo "DEBUG: MC_SERVER_CRASH_TIMER=$MC_SERVER_CRASH_TIMER"
    echo "DEBUG: MC_SERVER_JAVA_PATH=$MC_SERVER_JAVA_PATH"
    echo "DEBUG: MC_SERVER_RUN_FROM_BAD_FOLDER=$MC_SERVER_RUN_FROM_BAD_FOLDER"
    echo "DEBUG: MC_SERVER_IGNORE_OFFLINE=$MC_SERVER_IGNORE_OFFLINE"
    echo "DEBUG: MC_SERVER_IGNORE_JAVA_CHECK=$MC_SERVER_IGNORE_JAVA_CHECK"
    echo "DEBUG: MC_SERVER_USE_SPONGE=$MC_SERVER_USE_SPONGE"
    echo "DEBUG: MC_SERVER_HIGH_CPU_PRIORITY=$MC_SERVER_HIGH_CPU_PRIORITY"
    echo "DEBUG: MC_SERVER_JMX_ENABLE=$MC_SERVER_JMX_ENABLE"
    echo "DEBUG: MC_SERVER_JMX_PORT=$MC_SERVER_JMX_PORT"
    echo "DEBUG: MC_SERVER_JMX_HOST=$MC_SERVER_JMX_HOST"
    echo "DEBUG: MC_SERVER_MODPACK_NAME=$MC_SERVER_MODPACK_NAME"
    echo "DEBUG: MC_SERVER_DEFAULT_WORLD_TYPE=$MC_SERVER_DEFAULT_WORLD_TYPE"
    echo "DEBUG: MC_SERVER_MCVER=$MC_SERVER_MCVER"
    echo "DEBUG: MC_SERVER_FORGEVER=$MC_SERVER_FORGEVER"
    echo "DEBUG: MC_SERVER_FORGESHORT=$MC_SERVER_FORGESHORT"
    echo "DEBUG: MC_SERVER_FORGEURL=$MC_SERVER_FORGEURL"
    echo "DEBUG: MC_SERVER_AUTO_RESPOND=$MC_SERVER_AUTO_RESPOND"
    echo "DEBUG: MC_SERVER_INSTALL_ONLY=$MC_SERVER_INSTALL_ONLY"
    echo "DEBUG: Basic System Info:  $(uname -a)"
    
    if [[ $MC_SERVER_environment == "Mac" ]]; then
        echo "DEBUG: Total RAM estimate: $(sysctl hw.memsize | awk 'BEGIN {total = 1} {if (NR == 1 || NR == 3) total *=$NF} END {print total / 1024 / 1024" MB"}')"
    else
        echo "DEBUG: Total RAM estimate: $(getconf -a | grep PAGES | awk 'BEGIN {total = 1} {if (NR == 1 || NR == 3) total *=$NF} END {print total / 1024 / 1024" MB"}')"
    fi
    
    echo "DEBUG: Java Version info: "
    echo "DEBUG: Java path: $MC_SERVER_JAVA"
    $MC_SERVER_JAVA -version
    echo "DEBUG: Dumping current directory listing"
    ls -s1h
}>>logs/serverstart.log 2>&1
if [[ $MC_SERVER_INSTALL_ONLY == 1 ]]; then
    install_server
    exit 0
fi

#Asks the user if the want to force an install of the server
if [[ $MC_SERVER_AUTO_RESPOND == 0 ]]; then
    export answer="n"
    read -r -t 6 -p "About to start server. Force re-install (y/n)?  " answer
    if [[ "$answer" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        echo "INFO: User chose to manually re-install server files"  >>logs/serverstart.log 2>&1
        echo "User chose to manually re-install server files"
        install_server
    fi
fi

# loop to restart server and check crash frequency
a=0
last_crash=$((SECONDS))

if [[ ${MC_SERVER_JMX_ENABLE} == 1 ]]; then
    echo "INFO: JMX Enabled on port ${MC_SERVER_JMX_PORT}" >>logs/serverstart.log 2>&1
    export MC_SERVER_ARGS="${MC_SERVER_JAVA_ARGS} -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=${MC_SERVER_JMX_PORT} -Dcom.sun.management.jmxremote.rmi.port=${MC_SERVER_JMX_PORT} -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=$MC_SERVER_JMX_HOST"
else
    export MC_SERVER_ARGS=${MC_SERVER_JAVA_ARGS}
fi

run=true
while $run ; do
    
    #Testing some stuff before the server starts
    
    #Checks if script is running in temp
    echo "DEBUG: Current directory is $(pwd)" >>logs/serverstart.log
    
    if [ "$(pwd)" = "/tmp" ] || [ "$(pwd)" = "/var/tmp" ]; then
        echo "Current directory appears to be TMP"
        echo "WARN: Current DIR is TEMP"  >>logs/serverstart.log
        if [ ${MC_SERVER_RUN_FROM_BAD_FOLDER} -eq 0 ]; then
            echo "ERROR: Stopping due to bad folder (TMP)" >>logs/serverstart.log
            echo "RUN_FROM_BAD_FOLDER setting is off, exiting script"
            exit 0
        else
            echo "WARN: Bad folder (TMP) but continuing anyway" >>logs/serverstart.log
            echo "Bypassing cd=temp halt per script settings"
        fi
    fi
    
    #Checks if users has full read/write access to the server dir
    if [ ! -r . ] || [ ! -w . ]; then
        echo "WARN: Not full R/W access on current directory"
        echo "You do not have full R/W access to current directory"
        if [ ${MC_SERVER_RUN_FROM_BAD_FOLDER} -eq 0 ]; then
            echo "ERROR: Stopping due to bad folder (R/W access)" >>logs/serverstart.log
            echo "RUN_FROM_BAD_FOLDER setting is off, exiting script"
            exit 0
        else
            echo "WARN: Bad folder (R/W) cut continuing anyway" >>logs/serverstart.log
            echo "Bypassing no R/W halt (per script settings)"
        fi
    fi
    
    #Checks java version
    if [[ ${MC_SERVER_IGNORE_JAVA_CHECK} == 1 ]]; then
        echo "WARN: Skipping validation of proper Java install/version..".
        echo "IF Java is not installed, too old, or not 64-bit, the server probably won't start/run correctly"
        echo "WARN: Skipping validation of Java install..." >>logs/serverstart.log
    else
        command -v $MC_SERVER_JAVA >> /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "DEBUG: Java found" >>logs/serverstart.log
            if [[ "$(${MC_SERVER_JAVA} -version 2>&1 | awk -F ' ' '/Bit/ {print $2}')"  == "64-Bit" ]] || [[ "$(${MC_SERVER_JAVA} -version 2>&1 | awk -F ' ' '/Bit/ {print $3}')"  == "64-Bit" ]]; then
                echo "DEBUG: 64-bit Java found" >>logs/serverstart.log
            else
                echo "ERROR: 64-bit Java not found"
                echo "ERROR: 64-bit Java not found" >>logs/serverstart.log
                exit 1
            fi
            if [ "$(${MC_SERVER_JAVA} -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -c1-3)" = "1.8" ]; then
                echo "DEBUG: Java 8 Found" >>logs/serverstart.log
            else
                echo "ERROR: Java 8 not found"
                echo "ERROR: Java 8 not found" >>logs/serverstart.log
                exit 1
            fi
        else
            echo "ERROR: Java is not installed install Java before continuing"
            echo "ERROR: No Java detected" >>logs/serverstart.log
            exit 1
        fi
    fi
    
    #Check internet connection
    if [ ${MC_SERVER_IGNORE_OFFLINE} -eq 1 ]; then
        echo "WARN: Internet connectivity checking is disabled" >>logs/serverstart.log
        echo "Skipping internet connectivity check"
    else
        command -v ping >> /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "DEBUG: Ping found on system" >>logs/serverstart.log
            if ping -c 1 8.8.8.8 >> /dev/null 2>&1; then
                echo "INFO: Ping to Google DNS successful" >>logs/serverstart.log
                echo "Ping to Google DNS successful"
            else
                echo "ERROR: Ping to Google DNS failed. No internet access?" >>logs/serverstart.log
                echo "Ping to Google DNS failed. No internet access?"
                
                if ping -c 1 4.2.2.1 >> /dev/null 2>&1; then
                    echo "INFO: Ping to L4 successful" >>logs/serverstart.log
                    echo "Ping to L4 successful"
                else
                    echo "ERROR: Ping to L4 failed. No internet access?"  >>logs/serverstart.log
                    echo "Ping to L4 failed. No internet access?"
                    echo "IGNORE_OFFLINE is set to off exiting"
                    exit 1
                fi
            fi
        else
            echo "WARN: Ping not install can not check network connection" >>logs/serverstart.log
            echo "Ping is not install can not assure internet connection"
        fi
    fi
    
    #Checking minecraft has the files its needs to run
    if [ ! -d ./libraries ] ; then
        echo "WARN: library directory not found" >>logs/serverstart.log
        echo "Required files not found, need to install Forge"
        install_server
    fi
    forge=$(ls forge*"$MC_SERVER_MCVER"*"$MC_SERVER_FORGEVER"*universal.jar 2>>logs/serverstart.log)
    if [[ $? != 0 ]] ; then
        echo "WARN: no forge jar for MCVER: $MC_SERVER_MCVER and FORGEVER: $MC_SERVER_FORGEVER found"  >>logs/serverstart.log
        echo "Required files not found, need to install Forge"
        install_server
    else
        export MC_SERVER_FORGE_JAR="${forge[0]}"
        echo "DEBUG: Found forge jar: $MC_SERVER_FORGE_JAR" >>logs/serverstart.log
    fi
    
    if [ ! -f ./minecraft_server.${MC_SERVER_MCVER}.jar ] ; then
        echo "WARN: minecraft_server.${MC_SERVER_MCVER}.jar not found" >>logs/serverstart.log
        echo "Required files not found, need to install Forge"
        install_server
    fi
    
    #Checks if the EULA exists if not generates it
    if [ ! -f eula.txt ]; then
        echo "Could not find eula.txt going to generate it"
        eula_gen
    else
        if grep -Fxq "eula=true" eula.txt; then
            echo "INFO: Found 'eula=true' in 'eula.txt'" >>logs/serverstart.log
        else
            echo "Could not find 'eula=true' in 'eula.txt'"
            eula_gen
        fi
    fi
    
    #Checks if settings.properties exists and if not adds some default values
    if [ ! -f server.properties ]; then
        echo "Could not find server.properties, creating initial copy..."
        echo "INFO: server.properties not found... populating default" >>logs/serverstart.log
        {
            echo "view-distance=8"
            echo "allow-flight=true"
            echo "level-type=$MC_SERVER_DEFAULT_WORLD_TYPE"
            echo "snooper-enabled=false"
            echo "max-tick-time=90000"
            echo "motd=$MC_SERVER_MODPACK_NAME"
        }>> server.properties
    fi
    
    clear
    echo "Starting server"
    if [[ $MC_SERVER_JMX_ENABLE == 1 ]]; then
        echo "JMX Enabled on port ${MC_SERVER_JMX_PORT}"
    fi
    echo "INFO: Starting Server at $(date -u +%Y-%m-%d_%H:%M:%S)" >>logs/serverstart.log 2>&1
    "$MC_SERVER_JAVA" -Xmx"$MC_SERVER_MAX_RAM" "$MC_SERVER_ARGS" -jar "$MC_SERVER_FORGE_JAR" "$MC_SERVER_GAME_ARGS"
    b=$?
    b=1
    if [[ $b == 0 ]]; then
        echo "DEBUG: Server ended with code 0" >>logs/serverstart.log
        a=0
    else
        now=$((SECONDS))
        diff=$now-$last_crash
        if [[ $diff -gt $MC_SERVER_CRASH_TIMER ]]; then
            a=1
        else
            a=$((a+1))
        fi
        last_crash=$((SECONDS))
    fi
    if [[ "$a" == "$MC_SERVER_CRASH_COUNT" ]]; then
        echo "The server has crashed too many times"
        echo "ERROR: Server has failed to start too many times in a row." >>logs/serverstart.log
        exit 1
    fi
    
    export answer="y"
    if [[ $MC_SERVER_AUTO_RESPOND == 0 ]]; then
        echo "Server will restart in ~10 seconds. No input needed..."
        read -r -t 12 -p "Restart now (y) or exit to shell (n)?  " answer
    fi
    if [[ "$answer" =~ ^([nN][oO]|[nN])+$ ]]; then
        echo "INFO: User cancelled restart; exiting to shell" >>logs/serverstart.log
        echo ""
        exit 0
    fi
    echo ""
    echo "INFO: Server-auto-restart commencing"  >>logs/serverstart.log
    echo "Rebooting now!"
done
