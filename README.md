# Minecraft - Docker

__*Take care, `Last` version is often in dev. Use stable version with TAG*__

Docker build for managing a Minecraft Bukkit/Spigot server based on Alpine with
Werewolf module include.

This image is borrowed from bbriggs/bukkit functionalities.
Thanks for this good base of Dockerfile and existing structure.

Plugins are manualy download and updated to git repository from
    https://www.spigotmc.org (WGET Blocked) 

This image uses [GetBukkit](https://getbukkit.org) to manage a Minecraft server.

---

## Features
 - Easy install
 - Easy port configuration
 - Easy access to Minecraft config file
 - `Docker stop` is a clean stop

---

## Variables

A full list of `server.properties` settings and their corresponding environment
variables is included below, along with their defaults:

| Configuration Option              | Environment Variable          | Default                  |
| ----------------------------------|-------------------------------|--------------------------|
| allow-flight                      | ALLOW_FLIGHT                  | `false`                  |
| allow-nether                      | ALLOW_NETHER                  | `true`                   |
| broadcast-console-to-ops          | BROADCAST_OPS                 | `true`                   |
| broadcast-rcon-to-ops             | BROADCAST_OPS                 | `true`                   |
| debug                             | DEBUG                         | `false`                  |
| difficulty                        | DIFFICULTY                    | `1`                      |
| enable-command-block              | ENABLE_COMMAND_BLOCK          | `false`                  |
| enable-jmx-monitoring             | ENABLE_JMX                    | `false`                  |
| enable-query                      | ENABLE_QUERY                  | `false`                  |
| enable-rcon                       | ENABLE_RCON                   | `false`                  |
| enable-status                     | ENABLE_STATUS                 | `true`                   |
| enforce-whitelist                 | FORCE_WHITELIST               | `false`                  |
| entity-broadcast-range-percentage | BROADCAST_ENTITY              | `100`                    |
| force-gamemode                    | FORCE_GAMEMODE                | `true`                   |
| function-permission-level         | FUNC_PERMISSION_LEVEL         | `2`                      |
| gamemode                          | GAMEMODE                      | `survival`               |
| generate-structures               | GENERATE_STRUCTURES           | `true`                   |
| generator-settings                | GENERATOR_SETTINGS            |                          |
| hardcore                          | HARDCORE                      | `false`                  |
| level-name                        | LEVEL_NAME                    | `world`                  |
| level-seed                        | LEVEL_SEED                    |                          |
| level-type                        | LEVEL_TYPE                    | `default`                |
| max-build-height                  | MAX_BUILD_HEIGHT              | `256`                    |
| max-players                       | MAX_PLAYERS                   | `30`                     |
| max-tick-time                     | MAX_TICK_TIME                 | `60000`                  |
| max-world-size                    | MAX_WORLD_SIZE                | `29999984`               |
| motd                              | MOTD                          | `"Welcome to Minecraft"` |
| network-compression-threshold     | NETWORK_COMPRESSION_THRESHOLD | `256`                    |
| online-mode                       | ONLINE_MODE                   | `false`                  |
| op-permission-level               | OP_PERMISSION_LEVEL           | `4`                      |
| player-idle-timeout               | PLAYER_IDLE_TIMEOUT           | `0`                      |
| prevent-proxy-connections         | PREVENT_PROXY_CONNECTIONS     | `false`                  |
| pvp                               | PVP                           | `true`                   |
| query.port                        | SERVER_PORT                   | `25565`                  |
| rate-limit                        | RATE_LIMIT                    | `0`                      |
| rcon.password                     | RCON_PASSWORD                 |                          |
| rcon.port                         | RCON_PORT                     | `25575`                  |
| resource-pack                     | RESOURCE_PACK                 |                          |
| resource-pack-sha1                | RESOURCE_PACK_SHA1            |                          |
| server-ip                         | SERVER_IP                     |                          |
| server-port                       | SERVER_PORT                   | `25565`                  | 
| snooper-enabled                   | SNOOPER_ENABLED               | `true`                   |
| spawn-animals                     | SPAWN_ANIMALS                 | `true`                   |
| spawn-monsters                    | SPAWN_MONSTERS                | `true`                   |
| spawn-npcs                        | SPAWN_NPCS                    | `true`                   |
| spawn-protection                  | SPAWN_PROTECTION              | `30`                     |
| sync-chunk-writes                 | SYNC_CHUNK                    | `true`                   |
| text-filtering-config             | TEXT_FILTERING                |                          |
| use-native-transport              | NATIVE_TRANSP                 | `true`                   |
| view-distance                     | VIEW_DISTANCE                 | `10`                     |
| white-list                        | WHITE_LIST                    | `false`                  |

---

## Usage

### Basic run of the server

To start the server and accept the EULA in one fell swoop, just pass the
`EULA=true` environment variable to Docker when running the container.

`docker run -it -p 25565:25565 -e EULA=true --name minecraf_server
mdestombes/minecraft_bukkit_wolf_server`

### Craftbukkit included

Base of container minecraft is `spigot`, because werewolf plugin need `spigot`.
But craftbukkit server should be run too.
To run the spigot server, supply it as an argument like so:
`docker run -it -p 25565:25565 -e EULA=true --name minecraf_server
mdestombes/minecraft_bukkit_wolf_server craftbukkit`

### Configuration

You should be able to pass configuration options as environment variables like
so:
`docker run -it -p 25565:25565 -p 8123:8123 -e EULA=true -e DIFFICULTY=2 -e
MOTD="A specific welcome message" -e SPAWN_ANIMALS=false --name minecraf_server
mdestombes/minecraft_bukkit_wolf_server`

This container will attempt to generate a `server.properties` file if one does
not already exist. If you would like to use the configuration tool, be sure that
you are not providing a configuration file or that you also set
`FORCE_CONFIG=true` in the environment variables.

### Environment Files

Because of the potentially large number of environment variables that you could
pass in, you might want to consider using an `environment variable file`.
Example:
```
# env.list
ALLOW_NETHER=false
LEVEL_SEED=123456789
EULA=true
```

`docker run -it -p 25565:25565 --env-file env.list --name
minecraf_server mdestombes/minecraft_bukkit_wolf_server`

### Saved run of the server

You can bring your own existing data + configuration and mount it to the `/data`
directory when starting the container by using the `-v` option.

`docker run -it -v /my/path/to/minecraft:/minecraft/data/:rw -p 25565:25565 
-e EULA=true --name minecraf_server mdestombes/minecraft_bukkit_wolf_server`

---

## Recommended Usage

### Stopping container

To stop the server:
+ More than 70 should be needed at first running. 90 seconds set to internal
stop running process, to avoid lost data.
+ More than 40 should be needed at other running. 60 seconds set to internal
stop running process, to avoid lost data.

/!\ The default timeout of command `stop` from docker command is 10 second.

That's why I highly recommend to use the following parameter to use the `stop`
command :

First => `docker stop -t 100 minecraf_server`
After => `docker stop -t 70 minecraf_server`

---

## Important point in available volumes
+ __/minecraft/data__: Working data directory wich contains:
  + /minecraft/data/logs: Logs directory
  + /minecraft/data/plugin: Plugins directory
  + /minecraft/data/server.properties: Minecraft server properties

---

## Expose
+ Port: __SERVER_PORT__: Minecraft steam port (default: 25565)

---

## Known issues

---

## Changelog

| Tag      | Notes                                                 |
|----------|-------------------------------------------------------|
| `1.0`    | -> Initialization                                     |
|          | -> Minecraft 1.16.4                                   |
|          | -> werewolf-uhc 1.6.1                                 |
|          | -> statistiks-for-werewolf-uhc 1.0                    |
|          |                                                       |
