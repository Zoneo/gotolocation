# gotolocation
SA:MP filterscript to allow for users to teleport to user-created locations. (MySQL, SSCANF, zCMD).

## Description
This filterscript uses a MySQL database to allow users to teleport between places on the map. It allows users to do the following:
* Create a location to allow anybody to teleport to it.
* Teleport to any created location.
* Teleport other players to any location.
* See the stats about the locations (To see how many times each is used, for example)
* Delete any location.

## Installation

### Prerequisites

The following *includes* are required:
* [zCMD](http://forum.sa-mp.com/showthread.php?t=91354)
* [sscanf2](https://github.com/Southclaws/sscanf2)
* [mysql](http://forum.sa-mp.com/showthread.php?t=56564)

The following *plugins* are required:
* [sscanf](https://github.com/Southclaws/sscanf2)
* [mysqlannounce](http://forum.sa-mp.com/showthread.php?t=56564)


This filterscript was originally created as part of the MGRP admin script. Therefore, it is designed to trust all players which use it. It's highly recommended to restrict certain commands to trusted players. To do this, find each line which begins with `if(true`, and replace `true` with the condition on which you want to restrict command usage. For example, check if these players are admins. Each of these lines is clearly commented. 

When compiling the .PWN file, you will see some warnings. These are purposeful and are due to the redundant if statements, which are provided to simplify the process of restricting the commands to trusted players.

### Installation process

1. Edit the `gotoloc.pwn` with Pawno. On lines 13, 14 and 15, replace the default database host, username and password with your database's data.
````
#define MYSQL_HOST "localhost" //*** Change this to wherever your database is hosted.
#define MYSQL_USER "root" //*** Change this to the username used to access the database.
#define MYSQL_PASS "" //*** Change this to the password of the user used to access the database.
````
2. Compile `gotoloc.pwn`.
3. Place the both the `gotoloc.amx` and the `gotoloc.pwn` file into the `filterscripts` folder located in your server files.
4. In MySql, create a new database called `gotoloc`.
5. Import the `gotoloclocations.sql` file into that database. This adds the necessary table.
6. Ensure that your MySql database server is running.


## Troubleshooting



