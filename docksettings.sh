#!/bin/bash

## Changelog
## 15-01-2024 v0.1 Initial release
## 19-01-2024 v0.2 Display help; replace positional parameters with options; allow prefix shortcut to steamapps location
## 20-01-2024 v0.3 Added support for games which are syncing config data to Steam Cloud


## Define basic variables

ROOTDIR=/home/deck/Documents
DATE=$(date '+%d-%m-%Y %H:%M:%S')
CLOUDSLEEP=10


## Display help message

help()
{
    echo "Available options for docksettings.sh:"
    echo "-h    Print this help"
    echo "-n    Name of game"
    echo "-f    Location of config file"
    echo "-c    Name of game's executable (optional; for games which are syncing config data to Steam Cloud)"
    echo ""
    echo "Examples:"
    echo "./docksettings.sh -n \"Resident Evil 2\" -f \"/home/deck/.steam/steam/steamapps/common/RESIDENT EVIL 2  BIOHAZARD RE2/re2_config.ini\""
    echo "./docksettings.sh -n \"Resident Evil 2\" -f \"NVME/common/RESIDENT EVIL 2  BIOHAZARD RE2/re2_config.ini\""
    echo "./docksettings.sh -n \"Resident Evil 2\" -f \"SD/common/RESIDENT EVIL 2  BIOHAZARD RE2/re2_config.ini\""
    echo "./docksettings.sh -n \"NieR Automata\" -f \"NVME/compatdata/524220/pfx/drive_c/users/steamuser/Documents/My Games/NieR_Automata/SystemData.dat\" -c \"NieRAutomata.exe\""
}


## Get the options

while getopts "hc:n:f:" option; do
    case $option in
        h) help; exit;;
        c) GAMEEXE=$OPTARG;;
        n) NAME=$OPTARG;;
        f) FILE=$OPTARG;;
        \?) echo "$DATE Invalid options have been used." >> "$ROOTDIR/docksettings_error"; exit;;
    esac
done


## Check if mandatory options have been provided

if [ "$NAME" = "" ] || [ "$FILE" = "" ]; then
    echo "$DATE Mandatory options have not been provided. Please provide name of game and location to config file." >> "$ROOTDIR/docksettings_error"
    echo "$DATE Example: ./docksettings.sh -n \"Resident Evil 2\" -f \"NVME/common/RESIDENT EVIL 2  BIOHAZARD RE2/re2_config.ini\"" >> "$ROOTDIR/docksettings_error"
    exit 1
fi


## Define path to game specific logfile

LOGFILE="$ROOTDIR/docksettings/$NAME/logfile"


## Extract config filename from path

CONFIG=$(echo "$FILE" | awk '{print $NF}' FS=/)


## Check if directory structure exists and create it if not

if [ -d "$ROOTDIR/docksettings/$NAME" ]; then
    echo "$DATE INFO: Directory structure already exists." >> "$LOGFILE"
else
    mkdir -p "$ROOTDIR/docksettings/$NAME/deck"
    mkdir -p "$ROOTDIR/docksettings/$NAME/dock"
    echo "$DATE CHANGE: Directory structure have been created." >> "$LOGFILE"
fi


## Support usage of NVME and SD prefixes for config file location shortcuts to steamapps folder
if [[ $FILE = NVME* ]]; then
    NVME="\/home\/deck\/.steam\/steam\/steamapps"
    FILE=$(echo "$FILE" | sed "s/NVME/$NVME/")
elif [[ $FILE = SD* ]]; then
    SDNAME=$(df | grep mmcblk0 | awk '{print $6}' | awk -F/ '{print $5}')
    SD="\/run\/media\/deck\/$SDNAME\/steamapps"
    FILE=$(echo "$FILE" | sed "s/SD/$SD/")
fi


## Check validity of provided config file path

if [ -f "$FILE" ]; then
    echo "$DATE INFO: Provided config file location is valid." >> "$LOGFILE"
else
    echo "$DATE ERROR: Provided config file location doesn't exist. Exiting." >> "$LOGFILE"
    exit 1
fi


## Create initial backup and two profiles of configfile

if [ -f "$ROOTDIR/docksettings/$NAME/backup_$CONFIG" ]; then
    echo "$DATE INFO: Initial backup and profiles already exist." >> "$LOGFILE"
else
    cp -p "$FILE" "$ROOTDIR/docksettings/$NAME/backup_$CONFIG"
    cp -p "$FILE" "$ROOTDIR/docksettings/$NAME/deck/deck_$CONFIG"
    cp -p "$FILE" "$ROOTDIR/docksettings/$NAME/dock/dock_$CONFIG"
    echo "$DATE CHANGE: Initial backup and docked/undocked profiles have been created." >> "$LOGFILE"
fi


## Create last state file if it doesn't exist yet

if [ ! -f "$ROOTDIR/docksettings/$NAME/laststate" ]; then
    echo 0 > "$ROOTDIR/docksettings/$NAME/laststate"
    echo "$DATE CHANGE: Last state file have been created with dummy value 'undocked'." >> "$LOGFILE"
fi


## Read last state value

if [ "$GAMEEXE" = "" ]; then
    LASTSTATE=$(cat "$ROOTDIR/docksettings/$NAME/laststate")

    if [ "$LASTSTATE" = "0" ]; then
        echo "$DATE INFO: Last state was 'undocked'." >> "$LOGFILE"
    elif [ "$LASTSTATE" = "1" ]; then
        echo "$DATE INFO: Last state 'docked'." >> "$LOGFILE"
    else
        echo "$DATE ERROR: Last state was 'unknown'. Exiting." >> "$LOGFILE"
        echo "------------------------------------" >> "$LOGFILE"
        exit 1
    fi
fi


## Determine resolution of primary display

RESOLUTION=$(python3 -c 'from gi.repository import Gdk; screen=Gdk.Screen.get_default(); \
geo = screen.get_monitor_geometry(screen.get_primary_monitor()); \
print(geo.width, "x", geo.height)' 2> /dev/null)
echo "$DATE INFO: Detected resolution of display is $RESOLUTION." >> "$LOGFILE"


## Determine if Deck is docked and save current state to file for future run

if [ "$RESOLUTION" = "1280 x 800" ]; then
    DOCK=0
    echo 0 > "$ROOTDIR/docksettings/$NAME/laststate"
    echo "$DATE INFO: Current state is 'undocked'." >> "$LOGFILE"
else
    DOCK=1
    echo 1 > "$ROOTDIR/docksettings/$NAME/laststate"
    echo "$DATE INFO: Current state is 'docked'." >> "$LOGFILE"
fi


## Implement logic for cloud-based config files

if [ "$GAMEEXE" != "" ]; then
    echo "$DATE INFO: Starting cloud-based config file syncing sequence." >> "$LOGFILE"
    if [ "$DOCK" = "0" ]; then
        cp -p "$ROOTDIR/docksettings/$NAME/deck/deck_$CONFIG" "$FILE"
        echo "$DATE CHANGE: Copying cloud-based config file $ROOTDIR/docksettings/$NAME/deck/deck_$CONFIG to $FILE" >> "$LOGFILE"
    elif [ "$DOCK" = "1" ]; then
        cp -p "$ROOTDIR/docksettings/$NAME/dock/dock_$CONFIG" "$FILE"
        echo "$DATE CHANGE: Copying cloud-based config file $ROOTDIR/docksettings/$NAME/dock/dock_$CONFIG to $FILE" >> "$LOGFILE"
    fi

    while true
    do
        ps -efa | grep $GAMEEXE | grep -v $0 | grep -v grep >/dev/null 2>&1
        if [ $? -eq 1 ]; then
            SHA1=$(sha1sum "$FILE" | cut -d " " -f1)
            echo "$(date '+%d-%m-%Y %H:%M:%S') INFO: Checksum of $FILE is $SHA1" >> "$LOGFILE"
            if [ "$DOCK" = "0" ]; then
                SHA2=$(sha1sum "$ROOTDIR/docksettings/$NAME/deck/deck_$CONFIG" | cut -d " " -f1)
                echo "$(date '+%d-%m-%Y %H:%M:%S') INFO: Checksum of deck_$CONFIG is $SHA2" >> "$LOGFILE"
                if [ "$SHA1" == "$SHA2" ]; then
                    echo "$(date '+%d-%m-%Y %H:%M:%S') INFO: Checksum matched. Nothing to do." >> "$LOGFILE"
                else
                    cp -p "$FILE" "$ROOTDIR/docksettings/$NAME/deck/deck_$CONFIG"
                    echo "$(date '+%d-%m-%Y %H:%M:%S') CHANGE: Config file has been updated. Syncing." >> "$LOGFILE"
                fi
            elif [ "$DOCK" = "1" ]; then
                SHA2=$(sha1sum "$ROOTDIR/docksettings/$NAME/dock/dock_$CONFIG" | cut -d " " -f1)
                echo "$(date '+%d-%m-%Y %H:%M:%S') INFO: Checksum of dock_$CONFIG is $SHA2" >> "$LOGFILE"
                if [ "$SHA1" == "$SHA2" ]; then
                    echo "$(date '+%d-%m-%Y %H:%M:%S') INFO: Checksum matched. Nothing to do." >> "$LOGFILE"
                else
                    cp -p "$FILE" "$ROOTDIR/docksettings/$NAME/dock/dock_$CONFIG"
                    echo "$(date '+%d-%m-%Y %H:%M:%S') CHANGE: Config file has been updated. Syncing." >> "$LOGFILE"
                fi
            fi
            echo "$(date '+%d-%m-%Y %H:%M:%S') CHANGE: Process $GAMEEXE no longer running. Exiting." >> "$LOGFILE"
            echo "------------------------------------" >> "$LOGFILE"
            exit 0
        else
            echo "$(date '+%d-%m-%Y %H:%M:%S') INFO: Process $GAMEEXE still running. Sleeping." >> "$LOGFILE"
            sleep $CLOUDSLEEP
        fi
    done
fi


## Copy correct savefile according to current state and last state

if [ "$DOCK" = "0" ] && [ "$LASTSTATE" = "0" ]; then
    echo "$DATE INFO: Last state was 'undocked' and current state is 'undocked'. Nothing to do." >> "$LOGFILE"
elif [ "$DOCK" = "0" ] && [ "$LASTSTATE" = "1" ]; then
    echo "$DATE CHANGE: Last state was 'docked' and current state is 'undocked'. Copying correct save files." >> "$LOGFILE"
    cp -p "$FILE" "$ROOTDIR/docksettings/$NAME/dock/dock_$CONFIG"
    echo "$DATE CHANGE: Copying file $FILE to $ROOTDIR/docksettings/$NAME/dock/dock_$CONFIG" >> "$LOGFILE"
    cp -p "$ROOTDIR/docksettings/$NAME/deck/deck_$CONFIG" "$FILE"
    echo "$DATE CHANGE: Copying file $ROOTDIR/docksettings/$NAME/deck/deck_$CONFIG to $FILE" >> "$LOGFILE"
elif [ "$DOCK" = "1" ] && [ "$LASTSTATE" = "0" ]; then
    echo "$DATE CHANGE: Last state was 'undocked' and current state is 'docked'. Copying correct save files." >> "$LOGFILE"
    cp -p "$FILE" "$ROOTDIR/docksettings/$NAME/deck/deck_$CONFIG"
    echo "$DATE CHANGE: Copying file $FILE to $ROOTDIR/docksettings/$NAME/deck/deck_$CONFIG" >> "$LOGFILE"
    cp -p "$ROOTDIR/docksettings/$NAME/dock/dock_$CONFIG" "$FILE"
    echo "$DATE CHANGE: Copying file $ROOTDIR/docksettings/$NAME/dock/dock_$CONFIG to $FILE" >> "$LOGFILE"
elif [ "$DOCK" = "1" ] && [ "$LASTSTATE" = "1" ]; then
    echo "$DATE INFO: Last state was 'docked' and current state is 'docked'. Nothing to do." >> "$LOGFILE"
fi


## Add separator for better log readability

echo "------------------------------------" >> "$LOGFILE"
