#!/bin/sh

MC_INSTANCE="forge-1.10.2-12.18.3.2422-universal.jar"
#MC_INSTANCE='atmer.jar'
BIND="10.0.0.32"
PORT=30035
MAPPINGS="/home/minecraft/mcp/conf"
SLEEP=4

while true ; do
  WARMROAST_PID=`ps -ef | grep WarmRoast | grep -v grep | awk '{ print $2 }'`
  MC_PID=`ps -ef | grep ${MC_INSTANCE} | grep -v grep | awk '{ print $2 }' | head -1`

  #
  # If Minecraft server is already running and WarmRoast is not, then start WarmRoast
  #
  if [ ! ${WARMROAST_PID} ] && [ ${MC_PID} ] ; then
    java -Djava.library.path=${JAVA_HOME}/bin -cp ${JAVA_HOME}/lib/tools.jar:warmroast-1.0.0-SNAPSHOT.jar com.sk89q.warmroast.WarmRoast --thread "Server thread" \
      --bind ${BIND} \
      --port ${PORT} \
      --mappings ${MAPPINGS} \
      --pid ${MC_PID} &

  #
  # Else, if WarmRoast is running, but Minecraft server is not, i.e. because it has crashed/died,
  # then kill the WarmRoast process since it's running against a process that no longer exists
  #
  else
    if [ ${WARMROAST_PID} ] && [ ! ${MC_PID} ] ; then
      kill -9 ${WARMROAST_PID}
    fi
  fi

  # Go to sleep waiting for next check interval
  sleep ${SLEEP}
done