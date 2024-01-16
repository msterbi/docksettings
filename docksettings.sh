#!/bin/bash

ROOTDIR=/home/deck/Documents
DATE=$(date '+%d-%m-%Y %H:%M:%S')
LOGFILE="$ROOTDIR/docksettings/$1/logfile"

## Check if argument has been provided

if [ $# -lt 2 ]
then
    echo "$DATE Please provide name of game and location to config file." >> "$ROOTDIR/docksettings_error"
    echo "$DATE Example: ./docksettings.sh "Resident Evil 2" "/home/deck/.steam/steam/steamapps/common/RESIDENT EVIL 2  BIOHAZARD RE2/re2_config.ini"" >> "$ROOTDIR/docksettings_error"
    exit 1
fi


## Extract config filename from path

CONFIG=$(echo "$2" | awk '{print $NF}' FS=/)


## Check if directory structure exists and create it if not

if [ -d "$ROOTDIR/docksettings/$1" ]; then
    echo "$DATE INFO: Directory structure already exists." >> "$LOGFILE"
else
    mkdir -p "$ROOTDIR/docksettings/$1/deck"
    mkdir -p "$ROOTDIR/docksettings/$1/dock"
    echo "$DATE CHANGE: Directory structure have been created." >> "$LOGFILE"
fi


## Check validity of provided config file path

if [ -f "$2" ]; then
    echo "$DATE INFO: Provided config file location is valid." >> "$LOGFILE"
else
    echo "$DATE ERROR: Provided config file location doesn't exist. Exiting." >> "$LOGFILE"
    exit 1
fi


## Create initial backup and two profiles of savefile

if [ -f "$ROOTDIR/docksettings/$1/backup_$CONFIG" ]; then
    echo "$DATE INFO: Initial backup and profiles already exist." >> "$LOGFILE"
else
    cp -p "$2" "$ROOTDIR/docksettings/$1/backup_$CONFIG"
    cp -p "$2" "$ROOTDIR/docksettings/$1/deck/deck_$CONFIG"
    cp -p "$2" "$ROOTDIR/docksettings/$1/dock/dock_$CONFIG"
    echo "$DATE CHANGE: Initial backup and docked/undocked profiles have been created." >> "$LOGFILE"
fi


## Create last state file if it doesn't exist yet

if [ ! -f "$ROOTDIR/docksettings/$1/laststate" ]; then
    echo 0 > "$ROOTDIR/docksettings/$1/laststate"
    echo "$DATE CHANGE: Last state file have been created with dummy value 'undocked'." >> "$LOGFILE"
fi


## Read last state value

LASTSTATE=$(cat "$ROOTDIR/docksettings/$1/laststate")

if [ "$LASTSTATE" = "0" ]; then
    echo "$DATE INFO: Last state was 'undocked'." >> "$LOGFILE"
elif [ "$LASTSTATE" = "1" ]; then
    echo "$DATE INFO: Last state 'docked'." >> "$LOGFILE"
else
    echo "$DATE ERROR: Last state was 'unknown'. Exiting." >> "$LOGFILE"
    exit 1
fi


## Determine resolution of primary display

RESOLUTION=$(xrandr --current | grep primary | awk '{ print $4 }' | awk -F'+' '{print $1}')
echo "$DATE INFO: Detected resolution of primary display is $RESOLUTION." >> "$LOGFILE"


## Determine if Deck is docked and save current state to file for future run

if [ "$RESOLUTION" = "1280x800" ]; then
    DOCK=0
    echo 0 > "$ROOTDIR/docksettings/$1/laststate"
    echo "$DATE INFO: Current state is 'undocked'." >> "$LOGFILE"
else
    DOCK=1
    echo 1 > "$ROOTDIR/docksettings/$1/laststate"
    echo "$DATE INFO: Current state is 'docked'." >> "$LOGFILE"
fi


## Copy correct savefile according to current state and last state

if [ "$DOCK" = "0" ] && [ "$LASTSTATE" = "0" ]; then
    echo "$DATE INFO: Last state was 'undocked' and current state is 'undocked'. Nothing to do." >> "$LOGFILE"
elif [ "$DOCK" = "0" ] && [ "$LASTSTATE" = "1" ]; then
    echo "$DATE CHANGE: Last state was 'docked' and current state is 'undocked'. Copying correct save files." >> "$LOGFILE"
    cp -p "$2" "$ROOTDIR/docksettings/$1/dock/dock_$CONFIG"
    cp -p "$ROOTDIR/docksettings/$1/deck/deck_$CONFIG" "$2"
elif [ "$DOCK" = "1" ] && [ "$LASTSTATE" = "0" ]; then
    echo "$DATE CHANGE: Last state was 'undocked' and current state is 'docked'. Copying correct save files." >> "$LOGFILE"
    cp -p "$2" "$ROOTDIR/docksettings/$1/deck/deck_$CONFIG"
    cp -p "$ROOTDIR/docksettings/$1/dock/dock_$CONFIG" "$2"
elif [ "$DOCK" = "1" ] && [ "$LASTSTATE" = "1" ]; then
    echo "$DATE INFO: Last state was 'docked' and current state is 'docked'. Nothing to do." >> "$LOGFILE"
fi
