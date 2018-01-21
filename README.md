# SmartNode
### Standalone security and cronjob addon for smartnode on Ubuntu 16.04 LTS x64
### (!) Please do NOT run this if you already used the official bash installer
### ATTENTION: This installer is only suitable for a dedicated vps. The anti-ddos script in this installer will disable all ports including the http, https and dns ports. It will only leave the smartnode port open as well as a custom port for SSH.

#### This shell script comes with 4 cronjobs: 
1. Make sure the daemon is always running: *makerun.sh*
2. Make sure the daemon is never stuck: *checkdaemon.sh*
3. Make sure smartcash is always up-to-date: *upgrade.sh*
4. Daily clearing of debug.log: *cleardebug.sh*

#### Login to your vps, donwload the install.sh file and then run it:
```
wget https://raw.githubusercontent.com/nflaw/smartnode/master/install.sh
bash ./install.sh
```

#### After your machine has rebooted you'll have a much more stable and secure SmartNode.

#### You're good to go now. BEE $SMART! https://smartcash.cc
