FROM openjdk:8-alpine

# Builder Maintainer
MAINTAINER mdestombes

# Configuration variables
ENV SERVER_PORT=25565
ENV MOTD="Welcome to Minecraft Werewolf"
ENV WEREWOLF_MODE=1

# Install dependencies
RUN apk update &&\
    apk add \
        tmux \
        wget \
        git \
        bash \
        python

# Download minecraft binaries
# From 'https://getbukkit.org'
WORKDIR /minecraft/downloads/bin/werewolf_uhc
RUN wget -O /minecraft/downloads/bin/werewolf_uhc/craftbukkit.jar https://cdn.getbukkit.org/craftbukkit/craftbukkit-1.16.4.jar
RUN wget -O /minecraft/downloads/bin/werewolf_uhc/spigot.jar https://cdn.getbukkit.org/spigot/spigot-1.16.4.jar
WORKDIR /minecraft/downloads/bin/werewolf
RUN wget -O /minecraft/downloads/bin/werewolf/craftbukkit.jar https://cdn.getbukkit.org/craftbukkit/craftbukkit-1.15.1.jar
RUN wget -O /minecraft/downloads/bin/werewolf/spigot.jar https://cdn.getbukkit.org/spigot/spigot-1.15.1.jar

# Copy Bukkit, Spigot and Plugins
#WORKDIR /minecraft/bin
#RUN cp /minecraft/downloads/craftbukkit.jar /minecraft/bin/craftbukkit.jar
#RUN cp /minecraft/downloads/spigot.jar /minecraft/bin/spigot.jar

# Expose needed port
EXPOSE ${SERVER_PORT}

# Copy plugins
# Manualy downloaded from https://www.spigotmc.org (WGET Blocked)
# https://www.spigotmc.org/resources/loup-garou-uhc-werewolf-uhc.73113/ (v1.6.1)
COPY plugins/werewolfplugin.jar /minecraft/downloads/plugins/werewolf_uhc/
# https://www.spigotmc.org/resources/statistiks-for-loup-garou-uhc-werewolf-uhc.81472/ (v1.0)
COPY plugins/Statistiks.jar /minecraft/downloads/plugins/werewolf_uhc/
# https://www.spigotmc.org/resources/loup-garou-squeezie.76251/ (v1.1.0)
COPY plugins/LoupGarou.jar /minecraft/downloads/plugins/werewolf/
# https://www.spigotmc.org/resources/protocollib.1997/ (v4.5.1)
COPY plugins/ProtocolLib.jar /minecraft/downloads/plugins/werewolf/

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
