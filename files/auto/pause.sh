#!/bin/bash

. /start-utils
if isTrue "${DEBUG_AUTOPAUSE}"; then
  set -x
fi

if [[ $( ps -ax -o stat,comm | grep 'java' | awk '{ print $1 }') =~ ^S.*$ ]] ; then
  # save world
  logAutopauseAction "Saving world"
  rcon-cli save-all flush >/dev/null
  rcon-cli sync >/dev/null
  # commit any cached data to disk
  sync

  # wait until mc-monitor is no longer connected to the server
  while :
  do
    if [[ -z "$(netstat -nt | grep "127.0.0.1:$SERVER_PORT" | grep 'ESTABLISHED')" ]]; then
      break
    fi
    sleep 0.1
  done

  # finally pause the process
  logAutopauseAction "Pausing Java process"
  pkill -STOP java

  # create .paused file in data directory
  touch /data/.paused
fi
