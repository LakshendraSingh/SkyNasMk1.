#### SkyNasMk1.
## Scroll down to view the disclaimer and Legal Notice
SkyNasMk1 is a Linux-based Network Attached Storage (NAS) server built on top of Debian/Ubuntu. It utilizes Webmin as a dashboard for easy management and Samba for networking protocol, with the ability to configure RAID.

## Features

- **Webmin Dashboard**: A user-friendly web interface for managing your NAS server.
- **Samba Networking Protocol**: Share files across different systems seamlessly.
- **RAID Configuration**: Enhance storage reliability and performance with RAID setup.
- **Linux-Based**: Built on the stable and versatile Debian/Ubuntu Linux distributions.

## Requirements

- A computer with Debian/Ubuntu installed.
- An internet connection for installing necessary packages.
- Basic knowledge of Linux command-line operations.

## Installation

**Note**: It is recommended that you use the manual process instead of the automated script, as it (the automated script) may not allow you to edit certain settings during installation.

### Step 1: OS Updates and Upgrades

Update your system to ensure all packages are current:

```bash
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y
sudo reboot
```

### Step 2: Setting Up a Static IP Address

1. Edit the network interfaces file:

   ```bash
   sudo nano /etc/network/interfaces
   ```

2. Add the following:

   ```plaintext
   iface eth0 inet static
       address 192.168.1.190
       network 192.168.1.0
       netmask 255.255.255.0
       broadcast 192.168.1.255
       gateway 192.168.1.1
       dns-nameservers 8.8.8.8
   ```

### Step 3: SSH Access

SSH into your server:

```bash
ssh user@192.168.1.190
```

### Step 4: Installing Webmin

For more information, visit [Webmin](https://webmin.com).

1. Install dependencies:

   ```bash
   sudo apt-get install -y libapt-pkg-perl libnet-ssleay-perl libauthen-pam-perl libio-pty-perl apt-show-versions
   ```

2. Download and install Webmin:

   ```bash
   cd ~
   wget http://prdownloads.sourceforge.net/webadmin/webmin_1.580_all.deb
   sudo dpkg -i webmin*.deb
   sudo reboot
   ```

### Step 5: Setting Up RAID

1. Install the RAID management tool:

   ```bash
   sudo apt-get --no-install-recommends install -y mdadm
   ```

2. Create mount directories:

   ```bash
   sudo mkdir -p /mnt/raidmount /mnt/disk1 /media/disk1
   ```

3. Identify the disk UUID:

   ```bash
   sudo blkid
   ```

4. Edit the `/etc/fstab` file to mount the disk at boot:

   ```bash
   sudo nano /etc/fstab
   ```

   Add the following line (replace `"ID From blkid"` with the actual UUID):

   ```plaintext
   UUID="ID From blkid" /media/disk1 ext4 rw,user,auto 0 0
   ```

### Step 6: Access Webmin

Open your web browser and navigate to:

```url
https://192.168.1.190:10000
```

Log in using your system credentials.

### Step 7: Creating Shared Folders

1. Create the folder:

   ```bash
   sudo mkdir -p /media/raidmount/folder_1
   ```

### Step 8: Setting Permissions

1. For Read/Write access for one user:

   ```bash
   sudo chown user:user /media/raidmount/folder_1
   ```

2. For Read/Write access for everyone:

   ```bash
   sudo chmod a=rw -R /media/raidmount
   sudo chown nobody:nogroup /media/raidmount/folder_1
   ```

### Step 9: Setting Up Samba

1. Backup the old config file:

   ```bash
   sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.old
   ```

2. Edit the Samba config file with the following content:

   ```plaintext
   #======================= Global Settings =======================
   [global]
   log file = /var/log/samba/log.%m
   load printers = no
   passwd chat = *Enter\snew\s*\spassword:* %n\n
   *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   obey pam restrictions = yes
   null passwords = yes
   map to guest = Bad User
   encrypt passwords = yes
   passdb backend = tdbsam
   passwd program = /usr/bin/passwd %u
   dns proxy = no
   server string = %h server (Samba, Ubuntu)
   unix password sync = yes
   workgroup = WORKGROUP
   debug level = 1
   guest account = nobody
   os level = 20
   auto services = global
   syslog = 0
   usershare allow guests = yes
   panic action = /usr/share/samba/panic­action %d
   max log size = 1000
   pam password change = yes
   use sendfile = yes
   time server = no
   wins support = no

   #======================= Share Definitions =======================
   [homes]
   browseable = no
   comment = Home Directories
   available = no

   [Folder1]
   read list = nobody,user
   write list = user, add nobody here for passwordless read/write access
   force directory mode = 0755
   store dos attributes = no
   create mask = 0755
   hide dot files = yes
   user = nobody,user
   public = yes
   ea support = no
   inherit acls = yes
   browseable = yes
   writeable = yes
   inherit permissions = yes
   printable = no
   path = /media/raiddisk/Folder1
   force create mode = 0755
   comment = Folder 1
   directory mask = 0755
   valid users = nobody,user
   ```

3. Restart Samba services.

## Automated Installation Script

**Note**: It is recommended that you use the manual process instead of the automated script, as it (the automated script) may not allow you to edit certain settings during installation.

Save the following script as `install_sky_nas.sh` and make it executable:

```bash
#!/bin/bash

# OS Updates And Upgrades
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y
sudo reboot

# Setting Up A Static IP Address
sudo bash -c 'cat <<EOF >> /etc/network/interfaces
iface eth0 inet static
    address 192.168.1.190
    network 192.168.1.0
    netmask 255.255.255.0
    broadcast 192.168.1.255
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8
EOF'

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
sudo bash -c 'cat <<EOF >> /etc/fstab
UUID="ID From blkid" /media/disk1 ext4 rw,user,auto 0 0
EOF'

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
```

## TODO

- [ ] Finalize the automated installation script.
```

These are the Steps and recommendations for setting up SkyNasMk1 both manually and using the automated script.
Certainly! Here are the disclaimer and legal boilerplate sections to be added to your README file:

---

## Disclaimer

SkyNasMk1 is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the creators or contributors be held liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.

## Legal Notice

By using SkyNasMk1, you agree to comply with all applicable laws and regulations regarding the use and distribution of software. You acknowledge that it is your responsibility to ensure that your use of this software complies with the laws and regulations of your jurisdiction.

---
## Note : If you have any recomendations Make sure to let me know.
