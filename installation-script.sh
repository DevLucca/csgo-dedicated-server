#! /bin/bash

# CREATE AND GRANT SUDO TO `STEAM` USER
sudo useradd -m steam
sudo passwd steam 
sudo usermod -aG sudo steam
sudo -u steam -s
cd /home/steam

# INSTALL UNIX DEPENDENCIES FOR `STEAMCMD`
sudo apt-get update
sudo add-apt-repository multiverse
sudo apt-get install -y unzip software-properties-common
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt install -y lib32gcc-s1 lib32z1 steamcmd
sudo ln -s /usr/games/steamcmd /home/steam/steamcmd

# INSTALL CS:GO SERVER FILES
INSTALLATION_DIR=$(pwd)/Steam/steamapps/common/csgo-ds/
./steamcmd +force_install_dir $INSTALLATION_DIR +login anonymous +app_update 740 validate +quit

# INSTALL `METAMOD`, `SOURCEMOD` AND `PUG` ADDONS
mkdir mods
wget https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1148-linux.tar.gz -O mods/metamod.tar.gz
wget https://sm.alliedmods.net/smdrop/1.11/sourcemod-1.11.0-git6911-linux.tar.gz -O mods/sourcemod.tar.gz
wget https://github.com/splewis/csgo-pug-setup/releases/download/2.0.7/pugsetup_2.0.7.zip -O mods/pug.zip

cd mods
tar -xzf metamod.tar.gz
tar -xzf sourcemod.tar.gz
unzip pug.zip
echo '"Plugin"
{
	"file"	"../csgo/addons/metamod/bin/server"
}
' > addons/metamod.vdf

rm *.tar.gz *.zip

# MOVE ADDONS
rsync -a ./ $INSTALLATION_DIR/csgo
cd $INSTALLATION_DIR

# ADD CUSTOM CFGs
wget https://raw.githubusercontent.com/DevLucca/csgo-dedicated-server/main/server.cfg -O csgo/cfg/server.cfg
wget https://raw.githubusercontent.com/DevLucca/csgo-dedicated-server/main/tv.cfg -O csgo/cfg/tv.cfg
wget https://raw.githubusercontent.com/DevLucca/csgo-dedicated-server/main/knife.cfg -O csgo/cfg/knife.cfg
wget https://raw.githubusercontent.com/DevLucca/csgo-dedicated-server/main/competitive.cfg -O csgo/cfg/competitive.cfg
wget https://raw.githubusercontent.com/DevLucca/csgo-dedicated-server/main/infinite-warmup.cfg -O csgo/cfg/infinite-warmup.cfg

# CREATE STARTUP SCRIPT
echo "$INSTALLATION_DIR/srcds_run -game csgo -console -usercon -tickrate 128 +mapgroup mg_active +map de_mirage -authkey CHANGEME +sv_setsteamaccount CHANGEME -port 27015 -clientport 27005 +tv_port 27020" >> init_script
sudo chmod +x init_script
