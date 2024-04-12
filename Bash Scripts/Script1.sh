#!/bin/bash

# OS Updates And Upgrades
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y
sudo reboot

# Setting Up A Static IP Address
sudo nano /etc/network/interfaces
# Add the following:
# iface eth0 inet static
#    address 192.168.1.190
#    network 192.168.1.0
#    netmask 255.255.255.0
#    broadcast 192.168.1.255
#    gateway 192.168.1.1
#    dns-nameservers 8.8.8.8


# Installing Webmin
sudo apt-get install -y libapt-pkg-perl libnet-ssleay-perl libauthen-pam-perl libio-pty-perl apt-show-versions
cd ~
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.580_all.deb
sudo dpkg -i webmin*.deb
sudo reboot

# Setting up RAID
sudo apt-get --no-install-recommends install -y mdadm
sudo mkdir -p /mnt/raidmount /mnt/disk1 /media/disk1
sudo blkid
# Take a note of the ID number for the drive you would like to mount
sudo nano /etc/fstab
# Add new line:
# UUID="ID From blkid" /media/disk1 ext4 rw,user,auto 0 0

# Creating Shared Folders
sudo mkdir -p /media/raidmount/folder_1

# Permissions
# Read/Write Access for one user:
sudo chown user:user /media/raidmount/folder_1
# Read/Write Access for everyone:
sudo chmod a=rw -R /media/raidmount
sudo chown nobody:nogroup /media/raidmount/folder_1

# Setting up Samba
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.old
# Edit config file using webmin>servers>samba windows file sharing
# Restart Samba Servers after editing config file
