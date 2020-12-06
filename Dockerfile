FROM openjdk:8-alpine

# Builder Maintainer
MAINTAINER mdestombes

# Configuration variables
ENV SERVER_PORT=25565
ENV MOTD="Welcome to Minecraft Werewolf"

# Install dependencies
RUN apk update &&\
    apk add \
        tmux \
        wget \
        git \
        bash \
        python

# Download last version
# From 'https://getbukkit.org'
WORKDIR /minecraft/downloads
RUN wget -O /minecraft/downloads/craftbukkit.jar https://cdn.getbukkit.org/craftbukkit/craftbukkit-1.16.4.jar
RUN wget -O /minecraft/downloads/spigot.jar https://cdn.getbukkit.org/spigot/spigot-1.16.4.jar

# Copy Bukkit, Spigot and Plugins
WORKDIR /minecraft/bin
RUN cp /minecraft/downloads/craftbukkit.jar /minecraft/bin/craftbukkit.jar
RUN cp /minecraft/downloads/spigot.jar /minecraft/bin/spigot.jar

# Expose needed port
EXPOSE ${SERVER_PORT}

# Copy plugins
# Manualy downloaded from https://www.spigotmc.org (WGET Blocked)
# https://www.spigotmc.org/resources/loup-garou-uhc-werewolf-uhc.73113/ (v1.6.1)
COPY plugins/werewolfplugin.jar /minecraft/downloads/plugins/
# https://www.spigotmc.org/resources/statistiks-for-loup-garou-uhc-werewolf-uhc.81472/ (v1.0)
COPY plugins/Statistiks.jar /minecraft/downloads/plugins/

# Copy runner
COPY run.sh /minecraft/bin/run.sh
COPY configure.py /minecraft/bin/configure.py
RUN chmod +x /minecraft/bin/run.sh

# Change and share the data directory to Minecraft
WORKDIR /minecraft/data
RUN chmod -R 777 /minecraft/data
VOLUME  /minecraft/data

# Update game launch the game.
ENTRYPOINT ["/minecraft/bin/run.sh"]
CMD ["spigot"]
