#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Change ssh port
SSHPORT=$1

if [ -z $SSHPORT ]; then
    echo "SSH Port must be provided."
    exit 1
fi

# Update SSH configuration
sudo sed -i "s/#Port 22/Port ${SSHPORT}/" /etc/ssh/sshd_config

# Install and configure UFW firewall
sudo apt update
sudo apt install ufw -y
sudo ufw allow $SSHPORT/tcp
sudo ufw --force enable
sudo ufw reload

# Restart SSH service
sudo systemctl restart ssh

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Subversion
sudo apt remove subversion -y
sudo apt install subversion -y
svn --version