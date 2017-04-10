# Modpack ServerStart Scripts

Minecraft-Forge Server install/launcher script

Created by:   
    "Ordinator" (mostly Windows version)       
    "Dijkstra" (mostly Linux version)       

GitHub: https://github.com/AllTheMods/Server-Scripts          
AllTheMods Discord: https://discord.gg/FdFDVWb      

Originally created for use in "All The Mods" modpacks, but free for anyone to use/modify as long as they credit back to the originals with a link to the github project.

# Description

These scripts will fetch the appropriate Forge installer and install it. This will also install Mojang's distribution-restricted Minecraft binary and the required libraries.

After Forge/Minecraft are installed, the same script will act as a launcher to start the server, with an auto-restart-after-crash feature as well.

All relevant settings are in the easily accessable "settings.cfg" file; Modpack creators can specify their pack's minecraft and forge versions, and server operators can specify JVM args and RAM allocation as desired.


IF THERE ARE ANY ISSUES
Please make a report on the github linked above

Special thanks to all the code Frankensteined from google. There are many sources and references that should have been given credit but were lost in the initial creation. Apologies and thanks all around.


# How To Use

Configure settings.cfg to your needs:

NOTE: Is is important to keep the format as SETTING=VALUE (with no spaces around the equal sign) and one setting per line.

## Settings for server-owners:

`MAX_RAM=5G`  
    How much max RAM your allowing the JVM to allocate to the server 
    
`FORGE_JAR=forge.jar`       
    What the forge binary will be renamed to. Some server/hosts require a specific name  

`JAVA_ARGS=-server -d64 -Xms1G -XX:+ExplicitGCInvokesConcurrent -XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses -XX:+UseConcMarkSweepGC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=50 -XX:UseSSE=3`   
    The defaults provided should be best for most people, but can be edited if desired

`CRASH_COUNT=10`  
    The max number of consecutive crashes that each occurr withing so many seconds of eachother. If max is reaches, the script will exit. This is to stop spamming restarts of a server with a critical issue.

`CRASH_TIMER=600`  
    The number of seconds to consider a crash within to be "consecutive"

`RUN_FROM_BAD_FOLDER=0`  
    The scripts will not run from "temp" folders or "system" folders. If you want to force allow this, change the value to 1

`IGNORE_OFFLINE=0`  
    The scripts will not run if a connection to the internet can not be found. If you want to force allow (i.e. to run a server for local/LAN only) then set to 1. Note, however that it will need internet connection to at least perform initial download/install of the forge binaries


## Settings for modpack creators:
	

`MCVER=1.10.2`  
    Target minecraft version. Must be complete/exact and matching the version on Forge's website (i.e. "1.10" is not the same as "1.10.2")

`FORGEVER=12.18.3.2254`  
    Target Forge version. Requires the full version and exactly matching Forge's website. (i.e. "2254" will not work, but "12.18.3.2254" will)

`FORGEURL=DISABLE`  
    Direct url to a forge "installer" jar. Mostly for debugging purposes, but if a URL is specified, the Forge installer of this link will be downloded regardless of the previous settings.  
    NOTE: Another debug/bypass options is for modpack creators to package and redistribute the forge installer matching their desired version as long as it's named "forge-installer.jar" If included, none will need to be downloaded first.   


