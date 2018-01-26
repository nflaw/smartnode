#!/bin/bash
# install.sh
# Installs smartnode on Ubuntu 16.04 LTS x64
# ATTENTION: The anti-ddos part will disable http, https and dns ports.

if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as user: root"
  exit -1
fi

# start message
echo "This script will apply serious changes to your system configuration. "
echo "Please make sure you have done a backup first. "
echo "After running this script you have to manually reboot your server. "
echo "If this script gives you error messages, please look into them before you reboot. "
printf "Press Ctrl+C to cancel or Enter to continue: "
read IGNORE

cd
# Changing the SSH Port to a custom number is a good security measure against DDOS attacks
printf "Custom SSH Port(Enter to ignore): "
read VARIABLE
_sshPortNumber=${VARIABLE:-22}

# Add custom SSH port to firewall
ufw disable
ufw logging on
ufw enable

# Create a directory for smartnode's cronjobs and the anti-ddos script
mkdir smartnode

# Change the directory to ~/smartnode/
cd ~/smartnode/

# Download the appropriate scripts
wget https://raw.githubusercontent.com/nflaw/smartnode/master/anti-ddos.sh
wget https://raw.githubusercontent.com/nflaw/smartnode/master/makerun.sh
wget https://raw.githubusercontent.com/nflaw/smartnode/master/checkdaemon.sh
wget https://raw.githubusercontent.com/nflaw/smartnode/master/upgrade.sh
wget https://raw.githubusercontent.com/nflaw/smartnode/master/cleardebug.sh

# Create a cronjob for making sure smartcashd is always running
(crontab -l ; echo "*/1 * * * * ~/smartnode/makerun.sh") | crontab -
chmod 0700 ./makerun.sh

# Create a cronjob for making sure the daemon is never stuck
(crontab -l ; echo "*/30 * * * * ~/smartnode/checkdaemon.sh") | crontab -
chmod 0700 ./checkdaemon.sh

# Create a cronjob for making sure smartcashd is always up-to-date
(crontab -l ; echo "*/120 * * * * ~/smartnode/upgrade.sh") | crontab -
chmod 0700 ./upgrade.sh

# Create a cronjob for daily clearing of /.smartcash/debug.log
(crontab -l ; echo "@daily ~/smartnode/cleardebug.sh") | crontab -
chmod 0700 ./cleardebug.sh

# Change the SSH port
sed -i "s/[#]\{0,1\}[ ]\{0,1\}Port [0-9]\{2,\}/Port ${_sshPortNumber}/g" /etc/ssh/sshd_config
sed -i "s/14855/${_sshPortNumber}/g" ~/smartnode/anti-ddos.sh

# Run the anti-ddos script
bash ./anti-ddos.sh

# End message
echo "All commands executed. You can reboot now, if no error occured."
