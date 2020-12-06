#!/usr/bin/env bash

echo "************************************************************************"
echo "* Minecraft Server launching... ("`date`")"
echo "************************************************************************"

java -version
binary=$1
echo "Binary is '${binary}'"

# Trap management
[[ -p /tmp/FIFO ]] && rm /tmp/FIFO
mkfifo /tmp/FIFO
export TERM=linux

# Stop management
function stop {

  echo -e "\n*************************************************"
  echo "* Send stop to Minecraft server"
  echo "*************************************************"

  # Stoping minecraft server
  tmux send-keys -t minecraft "stop" C-m

  echo -e "\n*************************************************"
  echo "* Minecraft server stopping"
  echo "*************************************************"

  if [[ ${FIRST_LAUNCH} -eq 1 ]]; then
    sleep 90

  else
    sleep 60

  fi

  echo -e "\n*************************************************"
  echo "* Minecraft server stopped"
  echo "*************************************************"

  exit
}

# Init plugins configuration
function init_plugins {

  if [[ ${FIRST_LAUNCH} -eq 1 ]]; then
    echo -e "\n*************************************************"
    echo "* Specific configuration of Minecraft server..."
    echo "*************************************************"
    echo "Waiting for first initialization..."
    sleep 60

    while [[ `cat /minecraft/data/logs/latest.log | grep "Can't keep up!"` == "" ]]; do
      echo "...Waiting more..."
      sleep 10
    done

  else
    echo -e "\n*************************************************"
    echo "* Launching Minecraft server..."
    echo "*************************************************"
    echo "Waiting for initialization..."
    sleep 60

    while [[ `cat /minecraft/data/logs/latest.log | grep "Can't keep up!"` == "" ]]; do
      echo "...Waiting more..."
      sleep 10
    done

  fi
}

# First launch
if [[ ! -f /minecraft/data/eula.txt ]]; then

  # Copy plugins
  mkdir /minecraft/data/plugins
  cp -f /minecraft/downloads/plugins/*.jar /minecraft/data/plugins

  # Init plugins needed
  FIRST_LAUNCH=1

  # Check Minecraft license
  if [[ "$EULA" != "" ]]; then
    echo "# Generated via Docker on $(date)" > /minecraft/data/eula.txt
    echo "eula=$EULA" >> /minecraft/data/eula.txt
  else
    echo ""
    echo "Please accept the Minecraft EULA at"
    echo "  https://account.mojang.com/documents/minecraft_eula"
    echo "by adding the following immediately after 'docker run':"
    echo "  -e EULA=TRUE"
    echo "or editing eula.txt to 'eula=true' in your server's data directory."
    echo ""
    exit 1
  fi
else
  FIRT_LAUNCH=0
fi

# Check server configuration
[[ ! -f /minecraft/data/server.properties ]] || [[ "${FORCE_CONFIG}" = "true" ]] && python /minecraft/bin/configure.py --config

# Minecraft server session creation
tmux new -s minecraft -c /minecraft/data -d

# Launching minecraft server
tmux send-keys -t minecraft "java -jar /minecraft/bin/${binary}.jar nogui" C-m

# Stop server in case of signal INT or TERM
trap stop INT
trap stop TERM
read < /tmp/FIFO &

# Plugins configuration
init_plugins

echo -e "\n*************************************************"
echo "* Minecraft server operational..."
echo "*************************************************"
wait
