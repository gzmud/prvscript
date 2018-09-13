#!/bin/bash
#
#raspberry pi  raspbian init cmd
#

function picmd_help ()
{
cat << EOF
private script

Usage:

wget --cache=off --no-cache https://raw.github.com/gzmud/prvscript/master/piinit.sh -O piinit.sh
. piinit.sh

EOF
}

function picmd_auto() {
  #statements
  picmd_initapt
  picmd_installwebmin
  picmd_postinstalldocker
  picmd_installdocker
  picmd_hotplug2
  picmd_rcmod
}

function picmd_updatecmd()
{
pushd ~
git clone https://github.com/gzmud/prvscript.git
popd

pushd ~/prvscript
git pull
. piinit.sh
popd
}

function picmd_init()
{
#change pwd
passwd
}

function picmd_test()
{
#test net speed
time wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip
time wget -O /dev/null http://cachefly.cachefly.net/100mb.test

time (for((i=1;i<=10000;i++));do echo $(expr $i \* 4) > /dev/null ;done)
time echo "scale=2000; 4*a(1)" | bc -l -q
}

function picmd_bench()
{
wget -qO- bench.sh | bash
}

function picmd_initapt()
{
apt-get update
apt-get install -y -q nano \
     screen git \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     python-pip \
     udisks2 \
     bash-completion
}

function picmd_installwebmin()
{
#webmin
#ref
#http://www.webmin.com/deb.html
#2018.9.8 by gzmud

echo "deb http://download.webmin.com/download/repository sarge contrib" >/etc/apt/sources.list.d/webmin.list
wget -qO- http://www.webmin.com/jcameron-key.asc  | apt-key add -
apt-get update
apt-get install -y webmin
}

function picmd_postinstalldocker()
{
#docker and docker-compose
#ref
#1 https://docs.docker.com/install/linux/linux-postinstall/
#2018.9.8 by gzmud
groupadd docker
usermod -aG docker $USER
#systemctl enable docker
}


function picmd_installdocker()
{
#docker and docker-compose
#ref
#1 https://docs.docker.com/install/linux/docker-ce/debian/#install-using-the-repository
#2018.9.8 by gzmud

apt-get remove docker docker-engine docker.io
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
apt-key fingerprint 0EBFCD88

echo "deb [arch=armhf] https://download.docker.com/linux/debian \
     $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce
pip install docker-compose

#curl -fsSL https://get.docker.com -o get-docker.sh
#usermod -aG docker your-user
}


function picmd_nextcloudpidocker()
{
#nextcloudpi docker
#ref
#1 https://ownyourbits.com/nextcloudpi/
#2018.9.8 by gzmud
#x86 https://ownyourbits.com/2017/06/08/nextcloudpi-docker-for-raspberry-pi/
#usermod -aG docker pi
#newgrp docker
#modify  /lib/systemd/system/docker.service
#ExecStart=/usr/bin/dockerd -g /media/USBdrive/docker -H fd://
#sed -i 's/CONFIG_BRCM2708_SD_BOOT_PARTSIZE\=20/CONFIG_BRCM2708_SD_BOOT_PARTSIZE\=100/' .config

#Change Docker data directory on Debian – Random thoughts
echo '{
  "data-root": "/media/sda/docker"
}' > /etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker
#docker info | grep Root
#DOMAIN=192.168.1.130        # example for allowing an IP
#DOMAIN=myclouddomain.net    # example for allowing a domain
#docker run -d -p 443:443 -p 80:80 -v ncdata:/data --name nextcloudpi ownyourbits/nextcloudpi $DOMAIN

#https://ownyourbits.com/2017/11/15/nextcloudpi-dockers-for-x86-and-arm/
cd ~
git clone git clone https://github.com/nextcloud/nextcloudpi.git
IP="192.168.1.170" docker-compose -f docker-compose-armhf.yml up -d
}

function picmd_hotplug()
{
  #make auto mount usb disk
  #ref https://blog.csdn.net/taiyang1987912/article/details/46985343
  #2018.9.8 by gzmud
  #to /etc/udev/rules.d/10-usbstorage.rules
  #apt-get install -y -q udisks2
  # fail function
  #same as udevcontrol reload_rules 50-udev-default.rules
  echo '# UDISKS_FILESYSTEM_SHARED
# ==1: mount filesystem to a shared directory (/media/VolumeName)
# ==0: mount filesystem to a private directory (/run/media/$USER/VolumeName)
# See udisks(8)
ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"' \
> /etc/udev/rules.d/79-udisks2.rules
echo '# udisks2 automount rule by gzmud
KERNEL!="loop*|mmcblk*[0-9]|msblk*[0-9]|mspblk*[0-9]|nvme*|sd*|sr*|vd*|xvd*|bcache*|cciss*|dasd*|ubd*|scm*|pmem*|nbd*", GOTO="media_by_label_auto_mount_end"
SUBSYSTEM!="block", GOTO="media_by_label_auto_mount_end"

ACTION=="add", PROGRAM+="/usr/bin/udisksctl mount --no-user-interaction -b %N"
# Exit
LABEL="media_by_label_auto_mount_end"' \
> /etc/udev/rules.d/81-automount-udisks2.rules
  cp /lib/systemd/system/systemd-udevd.service /etc/systemd/system/
  sed -i 's/MountFlags=slave/MountFlags=shared/g' /etc/systemd/system/systemd-udevd.service
  #/etc/polkit-1/localauthority/50-local.d/org.freedesktop.udisks2.pkla
}

function picmd_hotplug_udev()
{
  echo 'KERNEL!="loop*|mmcblk*[0-9]|msblk*[0-9]|mspblk*[0-9]|nvme*|sd*|sr*|vd*|xvd*|bcache*|cciss*|dasd*|ubd*|scm*|pmem*|nbd*", GOTO="media_by_label_auto_mount_end"
  SUBSYSTEM!="block", GOTO="media_by_label_auto_mount_end"
# Import FS infos
IMPORT{program}="blkid -o udev -p %N"
# Get a label if present, otherwise specify one
ENV{dir_name}="usb-%k"
ENV{ID_FS_UUID}!="", ENV{dir_name}="%E{ID_FS_UUID}"
ENV{ID_FS_LABEL}!="", ENV{dir_name}="%E{ID_FS_LABEL}"

# Global mount options
ACTION=="add", ENV{mount_options}="relatime"
# Filesystem-specific mount options
# 如果是vfat 或者ntfs 系统，则设置mount_options 的选项如下
ACTION=="add", ENV{ID_FS_TYPE}=="vfat|ntfs", ENV{mount_options}="$env{mount_options},utf8,gid=100,umask=000"
# Mount the device
#  如果文件系统不是ntfs ,意味着是vfat
# 同时挂载到/mnt/dir_name 的形式
ACTION=="add",ENV{ID_FS_TYPE}=="vfat", PROGRAM+="/bin/mkdir -p /mnt/$env{dir_name}", PROGRAM+="/bin/mount -o $env{mount_options},rw %N /mnt/$env{dir_name}"
#ntfs
#  如果文件系统是ntfs ,以ntfs-3g 的形式挂载，实现可读写
# 同时挂载到/mnt/dir_name的形式
ACTION=="add",ENV{ID_FS_TYPE}=="ntfs", PROGRAM+="/bin/mkdir -p /mnt/$env{dir_name}", PROGRAM+="/bin/mount -t ntfs-3g -o $env{mount_options},rw %N /mnt/$env{dir_name}"

#  如果文件系统是其他,以 -t auto 的形式挂载，实现可读写
# 同时挂载到/mnt/dir_name的形式
ACTION=="add",ENV{ID_FS_TYPE}!="vfat|ntfs", PROGRAM+="/bin/mkdir -p /mnt/$env{dir_name}", PROGRAM+="/bin/mount -t auto -o $env{mount_options},rw %N /mnt/$env{dir_name}"
# Clean up after removal
#
ACTION=="remove", ENV{dir_name}!="", PROGRAM+="/bin/umount -l /mnt/$env{dir_name}",  PROGRAM+="/bin/rmdir /mnt/$env{dir_name}" ,  PROGRAM+="/bin/rm /mnt/$env{dir_name}"

# Exit
LABEL="media_by_label_auto_mount_end"' \
 > /etc/udev/rules.d/81-hhh_usb.rules

}

function picmd_hotplug2()
{
# base op
  cp /lib/systemd/system/systemd-udevd.service /etc/systemd/system/
  sed -i 's/MountFlags=slave/MountFlags=shared/g' /etc/systemd/system/systemd-udevd.service
cat <<EOF  > /etc/udev/rules.d/81-usbautomount.rules
KERNEL!="loop*|mmcblk*[0-9]|msblk*[0-9]|mspblk*[0-9]|nvme*|sd*|sr*|vd*|xvd*|bcache*|cciss*|dasd*|ubd*|scm*|pmem*|nbd*", GOTO="media_by_label_auto_mount_end"
SUBSYSTEM!="block", GOTO="media_by_label_auto_mount_end"
ACTION!="add", GOTO="media_by_label_auto_mount_end"
ENV{ID_BUS}!="usb", GOTO="media_by_label_auto_mount_end"
ENV{DEVTYPE}=="disk", ENV{ID_PART_TABLE_TYPE}!="" ,  GOTO="media_by_label_auto_mount_end"
ENV{DEVTYPE}!="disk|partition", GOTO="media_by_label_auto_mount_end"

LABEL="media_by_label_auto_mount_start"
# Import FS infos
IMPORT{program}="/sbin/blkid -o udev -p %N"
# Get a label if present, otherwise specify one
ENV{dir_name}="usb-%k"
ENV{ID_FS_UUID}!="", ENV{dir_name}="%E{ID_FS_UUID}"
ENV{ID_FS_LABEL}!="", ENV{dir_name}="%E{ID_FS_LABEL}"

# Global mount options
ENV{mount_options}="relatime"
#  如果文件系统是其他,以 -t auto 的形式挂载，实现可读写
# 同时挂载到/mnt/dir_name的形式
PROGRAM+="/bin/mkdir -p /media/%E{dir_name}"
PROGRAM+="/bin/mount -t auto -o rw %N /media/%E{dir_name}"

# Exit
LABEL="media_by_label_auto_mount_end"
EOF

cat <<EOF > /etc/udev/rules.d/81-autounclean.rules
KERNEL!="loop*|mmcblk*[0-9]|msblk*[0-9]|mspblk*[0-9]|nvme*|sd*|sr*|vd*|xvd*|bcache*|cciss*|dasd*|ubd*|scm*|pmem*|nbd*", GOTO="media_by_label_auto_unmount_end"
SUBSYSTEM!="block", GOTO="media_by_label_auto_unmount_end"
ACTION!="remove", GOTO="media_by_label_auto_unmount_start"
ENV{ID_BUS}!="usb", GOTO="media_by_label_auto_unmount_end"
ENV{DEVTYPE}=="disk", ENV{ID_PART_TABLE_TYPE}!="" , GOTO="media_by_label_auto_unmount_end"
ENV{DEVTYPE}!="disk|partition", GOTO="media_by_label_auto_unmount_end"

LABEL="media_by_label_auto_unmount_start"
# Import FS infos
# Clean up after removal
#
PROGRAM+="/bin/sh -c '/bin/cat /proc/mounts | /bin/grep %N'"
ENV{mountdir}="%c{2}"
ENV{mountdir}!="" , PROGRAM+="/bin/umount %E{mountdir}" , PROGRAM+="/bin/rmdir %E{mountdir}"
ENV{mountdir}=="" , ENV{dir_name}!="" , PROGRAM+="/bin/rmdir /media/%E{dir_name}"

LABEL="media_by_label_auto_unmount_end"
EOF
}

function picmd_rcmoddebug()
{
  for blk in /sys/class/block/*
  do
     dev=${blk##*/}
     #for argvs in `udevadm info  -q property -p $blk | grep = | awk '{print "'$dev'_" $1}'`
     for argvs in `udevadm info  -q property -p $blk | grep ID_BUS=usb | awk '{print "'$dev'_" $1}'`
     do
       #declare $argvs
       echo $dev $argvs
     done
      #echo `eval echo '$'"$dev"_ID_BUS`
  done
}

function picmd_rcmod()
{
mkdir -p /root/script/
sed -i '/\/root\/script\/rcmod\.sh/d' /etc/rc.local
echo '. /root/script/rcmod.sh' >>/etc/rc.local
cat <<EOF > /root/script/rcmod.sh
  #!/bin/bash
  #
  #rcscript
  rmdir /media/*
  for blk in /sys/class/block/*
  do
     dev=${blk##*/}
     for argvs in `udevadm info  -q property -p $blk | grep ID_BUS=usb | awk '{print "'$dev'_" $1}'`
     do
       udevadm test -a add $(udevadm info -q path -n $dev)
     done
  done
EOF
chmod +x /root/script/rcmod.sh
}
