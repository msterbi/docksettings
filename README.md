DockSettings
============

DockSettings is shell script intended to be used by Steam Deck users, which are using Steam Deck in both handheld and docked (using external display) mode and would like to have separate ingame graphics settings, which will be automatically applied depending on mode in which game has been started. For example, using 1280x800 resolution & High preset in handheld mode and 1920x1080 resolution & Medium preset in docked mode, without needing to manually change these settings every time.

Features
--------
- Creates directory structure in /home/deck/Documents/docksettings/{NameOfGame}/ where config files for both modes are being stored.
- Automatically creates initial backup of config file during first execution in location /home/deck/Documents/docksettings/{NameOfGame}/backup_{ConfigFileName}.
- Determines if Deck is running in docked or handheld mode by current output resolution of primary display.
- Compares last running mode and current mode and execute necessary actions to copy correct config files as needed.

Requirements
------------
- Location of game's config file needs to be known.
- Game's config file needs to be separate from game's save file.

Limitations
-----------
- Currently, it is possible to use only one config file per game (should be suitable for most games).
- Steam Deck performance profiles (TDP, frame limit, etc.) are not being updated via DockSettings.

Usage
-----
- Download latest release of docksettings.sh to /home/deck/Documents/ (or any other fixed location).
- Update permissions of docksettings.sh to make it executable (chmod +x docksettings.sh).
- Update launch options of game to: /full/path/to/docksettings.sh -n "{NameOfGame}" -f "/path/to/{ConfigFileName}" & %command%
- _(Optional)_ Update Game Resolution from Default to Native if you're experiencing issues with detecting resolution or using 16:10 external display.
- Launch game.

![image](https://github.com/msterbi/docksettings/assets/50196622/86be7f19-2c7c-4f5b-9d6b-9106ddaa3afc)

Path to config file can be specified either using full path or using prefixes as a shortcuts to steamapps directory on either NVMe storage or SD card:
- **STEAMAPPS:** automatically detect if config file is located on NVMe or SD card. NVMe storage will be searched with priority
- **NVME:** /home/deck/.steam/steam/steamapps
- **SD:** /run/media/deck/{SDVolumeName}/steamapps _(correct name of SD card volume is being automatically retrieved)_

Examples of valid paths of config file:
- **Automatic detection of config file's location:** /home/deck/Documents/docksettings.sh -n "Resident Evil 2" -f "STEAMAPPS/common/RESIDENT EVIL 2  BIOHAZARD RE2/re2_config.ini"
- **Absolute path:** /home/deck/Documents/docksettings.sh -n "Resident Evil 2" -f "/home/deck/.steam/steam/steamapps/common/RESIDENT EVIL 2  BIOHAZARD RE2/re2_config.ini"
- **NVMe storage location:** /home/deck/Documents/docksettings.sh -n "Resident Evil 2" -f "NVME/common/RESIDENT EVIL 2  BIOHAZARD RE2/re2_config.ini"
- **SD card location:** /home/deck/Documents/docksettings.sh -n "Resident Evil 2" -f "SD/common/RESIDENT EVIL 2  BIOHAZARD RE2/re2_config.ini"

Cloud-based Config File
-----------------------
Steam Cloud should be normally used for syncing save game files only, however some games are breaking this functionality by syncing also config files. This results in having same graphics/system configuration when playing same game on multiple devices. DockSettings is normally executing itself when game is started, doing required syncing of config file and exiting still while game is starting. With option _-c "{GameExe}"_, DockSettings is running continuously, watching main game process until its exit and syncing config file to DockSettings directory only after you quit the game.

Example for game NieR Automata:

- Config file of NieR Automata is being identified as SystemData.dat
- When browsing personal [Steam Cloud](https://store.steampowered.com/account/remotestorage), we can confirm that config file SystemData.dat is also being synced to Steam Cloud
- Therefore we'll use following Launch options for game NieR Automata:
/home/deck/Documents/docksettings.sh -n "NieR Automata" -f "NVME/compatdata/524220/pfx/drive_c/users/steamuser/Documents/My Games/NieR_Automata/SystemData.dat" **-c "NieRAutomata.exe"** & %command%

Testing
-------
DockSettings have been tested on following games:
- Resident Evil 2
- Duke Nukem 3D: 20th Anniversary World Tour
- NieR Automata
