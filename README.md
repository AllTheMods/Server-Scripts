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

All relevant settings are in the easily accessible "settings.cfg" file; Modpack creators can specify their pack's Minecraft and Forge versions, and server operators can specify JVM args and RAM allocation as desired.


IF THERE ARE ANY ISSUES
Please make a report on the github linked above

Special thanks to all the code Frankensteined from google. There are many sources and references that should have been given credit but were lost in the initial creation. Apologies and thanks all around.


# How To Use

Configure settings.cfg to your needs:

NOTE: The formatting is very important for it to load correctly: 
* `SETTING=VALUE;`
* No spaces around the equal sign
* One setting per line
* Semicolon immediately following value (no spaces)


| Setting | Description                | Example Value | 
| --------|:---------------------------| :------------:|
| MAX_RAM      | How much max RAM your allowing the JVM to allocate to the server  | `5G` |
| JAVA_ARGS      | The defaults provided should be best for most people, but can be edited if desired | *See Below* |
| CRASH_COUNT | The max number of consecutive crashes that each occur withing so many seconds of each other. If max is reaches, the script will exit. This is to stop spamming restarts of a server with a critical issue. | `8` |
| CRASH_TIMER | The number of seconds to consider a crash within to be "consecutive" | `600` |
| RUN_FROM_BAD_FOLDER | The scripts will not run from "temp" folders or "system" folders. If you want to force allow this, change the value to `1` | `0` | 
| IGNORE_OFFLINE | The scripts will not run if a connection to the internet can not be found. If you want to force allow (i.e. to run a server for local/LAN only) then set to `1`. Note, however that it will need internet connection to at least perform initial download/install of the Forge binaries | `0` |
| IGNORE_JAVA_CHECK | By default, the script will stop/error if it can not find 64-bit Java 1.8 or 1.9. Some packs might be able to run with less than 4G or RAM or on older 1.7 java. If you want to use an older version or are limited to a 32-bit OS, setting this to `1` will let the script continue | `0` | 
| USE_SPONGE | Mostly unsupported and experimental. If set to `1` script will attempt to launch SpongeBootstrap but only if the bootstrap is present and SpongeForge is in Mods folder. This will not download/setup the required files either, merely launch the pack using them. **Sponge can cause undocumented errors and conflicts and therefore it's use is rarely supported by modpack developers. USE AT YOUR OWN RISK and only if you know what you're doing** | `0` |
| MODPACK_NAME | Pack name to add flavor/description to script as it's running. Quotes are not needed. Can contain spaces. Technically can be very long, but will work better if short/concise (i.e. "Illumination" would be *much* better to use than "All The Mods Presents: Illumination") | `All The Mods` |
| MCVER | Target Minecraft version. Usually set by pack dev before distributing and not intended to be changed by end-users. Must be complete/exact and matching the version on Forge's website (i.e. `1.10` is not the same as `1.10.2`) | `1.10.2` |
| FORGEVER | Target Forge version. Usually set by pack dev before distributing and not intended to be changed by end-users. Requires the full version and exactly matching Forge's website. (i.e. `2254` will not work, but `12.18.3.2254` will) | `12.18.3.2281` | 
| FORGEURL | Direct url to a Forge "installer" jar. Mostly for debugging purposes, but if a URL is specified, the Forge installer of this link will be downloaded regardless of the previous settings.\*   | `DISABLE` |

\**NOTE: Another debug/bypass options is for modpack creators to package and redistribute the forge installer matching their desired version as long as it's name matches the format: `forge-<MinecraftVersion>-<ForgeVersion>-installer.jar` If included, none will need to be downloaded first.*  

## Optional Java Arguments

Java can be tweaked with launch settings that can sometimes improve the performance of Minecraft over default (no launch options), especially for 1.10+ and larger packs such as All The Mods.

**BASIC**  
These basic settings are recommended for general use for any modpack:
   ```java
   -server -d64 -Xms1G -XX:+ExplicitGCInvokesConcurrent -XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses -XX:+UseConcMarkSweepGC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=50 -XX:UseSSE=3
   ```

**HIGH RAM**  
If you have 10G or more RAM allocated to the Minecraft server, then these settings should make better use of the "extra" RAM: 
   ```java
   -server -d64 -Xms4G -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M
   ```

There are many opinions on what's considered good or not-so-good to use for JVM args that change from person-to-person, and over time. The settings above were based on [this great discussion/explanation](https://www.reddit.com/r/feedthebeast/comments/5jhuk9/modded_mc_and_memory_usage_a_history_with_a/) by CPW, the lead dev of EnderIO and a prominent contributor to the Forge project.


