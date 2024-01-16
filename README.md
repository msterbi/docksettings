Description:
- creates directory structure in /home/deck/Documents/docksettings/<NameOfGame>/ where config files, logs are stored
- automatically create backup of config file during first execution in location /home/deck/Documents/docksettings/<NameOfGame>/backup_<ConfigFileName> for case when something goes wrong and needs to be restored
- 

Usage:


Limitations:
- it is possible to use only one config file per game at the moment (should be suitable for most games)
- not able to update Steam Deck performance profiles (TDP, frame limit, etc.) as profiles are not being stored in plain text
