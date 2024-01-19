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
- Steam Cloud usage needs to be properly implemented by developer of game in question (config files shouldn't be backed up to Steam Cloud).

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
- **NVME:** /home/deck/.steam/steam/steamapps
- **SD:** /run/media/deck/{SDVolumeName}/steamapps _(correct name of SD card volume is being automatically retrieved)_

Examples of valid paths of config file:
- **Absolute path:** /home/deck/Documents/docksettings.sh -n "Resident Evil 2" -f "/home/deck/.steam/steam/steamapps/common/RESIDENT EVIL 2 BIOHAZARD RE2/re2_config.ini"
- **NVMe storage location:** /home/deck/Documents/docksettings.sh -n "Resident Evil 2" -f "NVME/common/RESIDENT EVIL 2 BIOHAZARD RE2/re2_config.ini"
- **SD card location:** /home/deck/Documents/docksettings.sh -n "Resident Evil 2" -f "SD/common/RESIDENT EVIL 2 BIOHAZARD RE2/re2_config.ini"

Testing
-------
DockSettings have been tested on following games:
- Resident Evil 2
- Duke Nukem 3D: 20th Anniversary World Tour
