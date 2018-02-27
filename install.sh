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
ufw allow "$_sshPortNumber"/tcp
ufw limit "$_sshPortNumber"/tcp
ufw logging on
ufw default deny incoming
ufw default allow outgoing
ufw enable

# Create a directory for smartnode's cronjobs and the anti-ddos script
mkdir smartnode

# Change the directory to ~/smartnode/
cd ~/smartnode/

# Download the appropriate scripts
wget https://raw.githubusercontent.com/nflaw/smartnode/master/makerun.sh
wget https://raw.githubusercontent.com/nflaw/smartnode/master/checkdaemon.sh
wget https://raw.githubusercontent.com/nflaw/smartnode/master/upgrade.sh
wget https://raw.githubusercontent.com/nflaw/smartnode/master/cleardebug.sh

# Create a cronjob for making sure smartcashd runs after reboot
if ! crontab -l | grep "@reboot smartcashd"; then
  (crontab -l ; echo "@reboot smartcashd") | crontab -
fi

# Create a cronjob for making sure smartcashd is always running
if ! crontab -l | grep "~/smartnode/makerun.sh"; then
  (crontab -l ; echo "*/5 * * * * ~/smartnode/makerun.sh") | crontab -
fi

# Create a cronjob for making sure the daemon is never stuck
if ! crontab -l | grep "~/smartnode/checkdaemon.sh"; then
  (crontab -l ; echo "*/30 * * * * ~/smartnode/checkdaemon.sh") | crontab -
fi

# Create a cronjob for making sure smartcashd is always up-to-date
if ! crontab -l | grep "~/smartnode/upgrade.sh"; then
  (crontab -l ; echo "0 0 */1 * * ~/smartnode/upgrade.sh") | crontab -
fi

# Create a cronjob for clearing the log file
if ! crontab -l | grep "~/smartnode/cleardebug.sh"; then
  (crontab -l ; echo "@daily ~/smartnode/cleardebug.sh") | crontab -
fi

# Give execute permission to the cron scripts
chmod 0700 ./makerun.sh
chmod 0700 ./checkdaemon.sh
chmod 0700 ./upgrade.sh
chmod 0700 ./cleardebug.sh

# Change the SSH port
sed -i "s/[#]\{0,1\}[ ]\{0,1\}Port [0-9]\{2,\}/Port ${_sshPortNumber}/g" /etc/ssh/sshd_config

# End message
echo "All commands executed. You can reboot now, if no error occured."
