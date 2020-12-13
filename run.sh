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

  # Stopping minecraft server
  tmux send-keys -t minecraft "stop" C-m

  if [[ ${WEREWOLF_MODE} -eq 1 ]]; then
    echo -e "\n*************************************************"
    echo "* Minecraft server with Werewolf Squeezie stopping"
    echo "*************************************************"
    sleep 10

  else
    echo -e "\n*************************************************"
    echo "* Minecraft server with Werewolf UHC stopping"
    echo "*************************************************"

    if [[ ${FIRST_LAUNCH} -eq 1 ]]; then
      sleep 90

    else
      sleep 60

    fi

  fi

  echo -e "\n*************************************************"
  echo "* Minecraft server stopped"
  echo "*************************************************"

  exit
}

# Init plugins configuration
function init_plugins {

  # Copy plugins if selected mod active and not already copied
  if [[ ${WEREWOLF_MODE} -eq 1 ]]; then
    echo -e "\n*************************************************"
    echo "* Werewolf Squeezie management..."
    echo "*************************************************"

    if ! [[ ${FIRST_LAUNCH} -eq 1 || -f /minecraft/data/plugin_installed ]]; then
      echo "Copy plugins..."
      cp -f /minecraft/downloads/plugins/werewolf/*.jar /minecraft/data/plugins
      touch /minecraft/data/plugin_installed

    else
      echo "Nothing to do!"

    fi

  else
    echo -e "\n*************************************************"
    echo "* Werewolf UHC management..."
    echo "*************************************************"

    if ! [[ -f /minecraft/data/plugin_installed ]]; then
      echo "Copy plugins..."
      mkdir /minecraft/data/plugins
      cp -f /minecraft/downloads/plugins/werewolf_uhc/*.jar /minecraft/data/plugins
      touch /minecraft/data/plugin_installed

    else
      echo "Nothing to do!"

    fi

  fi

}

# Waiting procedure
function waiting_available_server {

  if [[ ${WEREWOLF_MODE} -eq 1 ]]; then
    echo -e "\n*************************************************"
    echo "* Launching Minecraft server with Werewolf Squeezie..."
    echo "*************************************************"

    if [[ ${FIRST_LAUNCH} -eq 1 ]]; then
      echo "Waiting for first initialization..."
      sleep 40

      while [[ `cat /minecraft/data/logs/latest.log | grep "For help, type \"help\""` == "" ]]; do
        echo "...Waiting more..."
        sleep 10
      done

    else
      echo "Waiting for initialization..."
      sleep 40

      while [[ `cat /minecraft/data/logs/latest.log | grep "For help, type \"help\""` == "" ]]; do
        echo "...Waiting more..."
        sleep 10
      done

    fi

  else
    echo -e "\n*************************************************"
    echo "* Launching Minecraft server with Werewolf UHC..."
    echo "*************************************************"

    if [[ ${FIRST_LAUNCH} -eq 1 ]]; then
      echo "Waiting for first initialization..."
      sleep 60

      while [[ `cat /minecraft/data/logs/latest.log | grep "Can't keep up!"` == "" ]]; do
        echo "...Waiting more..."
        sleep 10
      done

    else
      echo "Waiting for initialization..."
      sleep 60

      while [[ `cat /minecraft/data/logs/latest.log | grep "Can't keep up!"` == "" ]]; do
        echo "...Waiting more..."
        sleep 10
      done

    fi

  fi

}

# First launch
if [[ ! -f /minecraft/data/eula.txt ]]; then

  # Copy minecraft binaries
  echo -e "\n************************************************************************"
  echo "* Copy specific Minecraft binaries..."
  echo "************************************************************************"
  if [[ ${WEREWOLF_MODE} -eq 1 ]]; then
    echo "Werewolf Squeezie"
    cp -f /minecraft/downloads/bin/werewolf/*.jar /minecraft/bin
  else
    echo "Werewolf UHC"
    cp -f /minecraft/downloads/bin/werewolf_uhc/*.jar /minecraft/bin
  fi

  # Init plugins needed
  FIRST_LAUNCH=1

  # Check Minecraft license
  if [[ "${EULA}" != "" ]]; then
    echo "# Generated via Docker on $(date)" > /minecraft/data/eula.txt
    echo "eula=${EULA}" >> /minecraft/data/eula.txt
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
  FIRST_LAUNCH=0
fi

# Check server configuration
[[ ! -f /minecraft/data/server.properties ]] || [[ "${FORCE_CONFIG}" = "true" ]] && python /minecraft/bin/configure.py --config

# Minecraft server session creation
tmux new -s minecraft -c /minecraft/data -d

# Plugins configuration
init_plugins

# Launching minecraft server
tmux send-keys -t minecraft "java -jar /minecraft/bin/${binary}.jar nogui" C-m

# Stop server in case of signal INT or TERM
trap stop INT
trap stop TERM
read < /tmp/FIFO &

# Waiting procedure
waiting_available_server

echo -e "\n*************************************************"
echo "* Minecraft server operational..."
echo "*************************************************"

wait
