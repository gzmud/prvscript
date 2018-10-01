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

function picmd_scrauto() {
  #statements
screen -dmS apt -t w
screen -r apt -p w -X stuff 'pushd ~
git clone https://github.com/gzmud/prvscript.git
popd
pushd ~/prvscript
git pull
. piinit.sh
popd
picmd_auto
'
screen -r apt
}

function pinc_auto() {
  #statements
  #picmd_hotplug2
  #picmd_rcmod
  #there is some other way for automount
  echo pinc_auto
}

function picmd_auto() {
  #statements
  picmd_initapt
  picmd_installwebmin
  picmd_postinstalldocker
  picmd_installdocker
  #picmd_hotplug2
  #picmd_rcmod
  #there is some other way for automount
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
     bash-completion \
     smartmontools \
     jq
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
docker_root_new=/media/storage/docker
docker_root_old=`(docker info  2> /dev/null) | awk '/Root/{print $4}'`
systemctl stop docker
mkdir -p $docker_root_new
cp -r $docker_root_old/* $docker_root_new
echo '{
  "data-root": "'$docker_root_new'"
}' > /etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker
#docker info | grep Root
#DOMAIN=192.168.1.130        # example for allowing an IP
#DOMAIN=myclouddomain.net    # example for allowing a domain
#docker run -d -p 443:443 -p 80:80 -v ncdata:/data --name nextcloudpi ownyourbits/nextcloudpi-armhf $DOMAIN

#https://ownyourbits.com/2017/11/15/nextcloudpi-dockers-for-x86-and-arm/
cd ~
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
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
ENV{fs_type}="auto"

# Global mount options
ENV{mount_options}="relatime"
PROGRAM+="/bin/mkdir -p /media/%E{dir_name}",PROGRAM+="/bin/chmod 0766 /media/%E{dir_name}"

ENV{ID_FS_TYPE}=="vfat|ntfs", ENV{mount_options}="%E{mount_options},utf8,gid=100,umask=000" , ENV{fs_type}=ENV{ID_FS_TYPE}
ENV{ID_FS_TYPE}!="vfat|ntfs", ENV{mount_options}="%E{mount_options},noatime"
#  如果文件系统是其他,以 -t auto 的形式挂载，实现可读写
# 同时挂载到/mnt/dir_name的形式
PROGRAM+="/bin/mount -t %E{fs_type} -o %E{mount_options},rw %N /media/%E{dir_name}"

# Exit
LABEL="media_by_label_auto_mount_end"
EOF

cat <<EOF > /etc/udev/rules.d/81-autounclean.rules
KERNEL!="loop*|mmcblk*[0-9]|msblk*[0-9]|mspblk*[0-9]|nvme*|sd*|sr*|vd*|xvd*|bcache*|cciss*|dasd*|ubd*|scm*|pmem*|nbd*", GOTO="media_by_label_auto_unmount_end"
SUBSYSTEM!="block", GOTO="media_by_label_auto_unmount_end"
ACTION!="remove", GOTO="media_by_label_auto_unmount_end"
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
     dev=\${blk##*/}
     for argvs in \`udevadm info  -q property -p \$blk | grep ID_BUS=usb | awk '{print "'\$dev'_" $1}'\`
     do
       udevadm test -a add \`udevadm info -q path -n \$dev\`
     done
  done
EOF
chmod +x /root/script/rcmod.sh
}

function pinc_fixncautomount() {
  #fix nc-automount-links don;t remove ln
  test -e /usr/local/etc/nc-automount-links.bak || \
  cp /usr/local/etc/nc-automount-links /usr/local/etc/nc-automount-links.bak
  sed -i 's/test -L \/media\/"$l"/\( test -L \/media\/"$l" \&\& ! test -d \/media\/"$l" \)/' \
  /usr/local/etc/nc-automount-links
  #cat /usr/local/etc/nc-automount-links | \
  #sed 's/test -L \/media\/"$l"/\( test -L \/media\/"$l" \&\& ! test -d \/media\/"$l" \)/'

  #fix nc-automount-links-mon
cat <<EOF >/usr/local/etc/nc-automount-links-mon.h
#!/bin/bash
function linkproc()
{
#echo $1 for $2
if [ "$2" == "CREATE" ] ; then
	islinked $1 || makelink $1
fi
}

function islinked()
{
tmres=`ls -od /media/* | awk '$9 ~/->/ && $10 ~/\media\/'$1'$/ {print $10}'`
test -n "$tmres"
return $?
}

function makelink()
{
 # create links
  test -e /media/USBdrive || { ln -sT "/media/$1" /media/USBdrive ; return ; }
  # create links
  for((i=1;i<=10;i++));do
    test -h /media/USBdrive$i || { ln -sT "/media/$1" /media/USBdrive$i ; return ; }
  done
}
EOF

#sed -i 's/#!\/bin\/bash$/#!\/bin\/bash\/n\' \
#/usr/local/etc/nc-automount-links-mon
  test -e /usr/local/etc/nc-automount-links-mon.bak || \
  cp /usr/local/etc/nc-automount-links-mon /usr/local/etc/nc-automount-links-mon.bak
  sed -i '/#!\/bin\/bash/{s/$/\n\n. \/usr\/local\/etc\/nc-automount-links-mon\.h\n\n/;:f;n;b f;}' \
  /usr/local/etc/nc-automount-links-mon
   sed -i 's/\([ \t]*\)\([^ \t]*nc-automount-links\)/\1#\2\n\1linkproc ${f%,*}/' \
  /usr/local/etc/nc-automount-links-mon

mkdir /etc/udiskie/
cat <<EOF >/etc/udiskie/config.yml
device_config:

- id_type: vfat
  options: [noexec, nodev , umask=0000 ]

- id_type: ntfs
  options: [ umask=0000 ]

- id_type: exfat
  options: [noexec, nodev , umask=0000 ]
EOF
#cat /usr/lib/systemd/system/nc-automount.service | \
sed -i "s/ExecStart=\/usr\/bin\/udiskie -NTF/ExecStart=\/usr\/local\/bin\/udiskie -NTF2v -c \/etc\/udiskie\/config.yml/g" /usr/lib/systemd/system/nc-automount.service

}

function pinc_updateudiskie() {
  version_ge `udiskie -V | awk '{print $2}'` 1.7.4 && return
  easy_install pip pip3
  pip3 uninstall udiskie
  pip3 install udiskie
}

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" == "$1"; }
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; }
function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }

function pinc_startbbr() {
#echo try star bbr
echo 'net.core.default_qdisc=fq
net.ipv4.tcp_allowed_congestion_control="bbr cubic reno"
net.ipv4.tcp_available_congestion_control="bbr cubic reno"
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_wmem="4096 65536 67108864"' >> /etc/sysctl.conf
echo 'net.core.default_qdisc=fq
net.ipv4.tcp_allowed_congestion_control="bbr cubic reno"
net.ipv4.tcp_available_congestion_control="bbr cubic reno"
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_wmem="4096 65536 67108864"' >> /etc/sysctl.d/99-zbbr.conf
sysctl -p
}

function pinc_getrealip(){
  dig +short myip.opendns.com @resolver1.opendns.com
}

function pinc_addtrust(){
  pushd /var/www/nextcloud
  sudo -u www-data php occ config:system:get \
  trusted_domains --output=json_pretty 
  sudo -u www-data php occ config:system:set \
  trusted_domains 6 --value=nas.lan
  sudo -u www-data php occ  config:system:set \
  trusted_domains 7 --value=nas.sdmud.tk
  popd
}

function pinc_joinfrp(frptoken,frphost){
cat <<EOF > /usr/lib/systemd/system/FRP-Client.service
[Unit]
Description=FRP-Client
After=network-online.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/frpc -c  /usr/local/frpc/frpc.ini
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
WantedBy=graphical.target
EOF

mkdir -p /usr/local/frpc/
cat <<EOF > /usr/local/frpc/frpc.ini
# [common] is integral section
[common]
# A literal address or host name for IPv6 must be enclosed
# in square brackets, as in "[::1]:80", "[ipv6-host]:http" or "[ipv6-host%zone]:80"
server_addr = $frphost
server_port = 5443

# for authentication
token = $frptoken

# connections will be established in advance, default value is zero
pool_count = 5

# if tcp stream multiplexing is used, default is true, it must be same with frps
tcp_mux = true

# your proxy name will be changed to {user}.{proxy}
user = admin

# decide if exit program when first login failed, otherwise continuous relogin to frps
# default is true
login_fail_exit = false

# console or real logFile path like ./frpc.log
log_file = ./frpc.log
# trace, debug, info, warn, error
log_level = info
log_max_days = 3

# communication protocol used to connect to server
# now it supports tcp and kcp, default is tcp
protocol = tcp

[webmin]
type = tcp
#local_ip = 192.168.1.130
local_port = 10000
remote_port = 9000

#use_encryption = true
#use_compression = true
#custom_domains = $frphost

#[web]
#type = tcp
#local_port = 80
#remote_port = 9080

[web2]
type = tcp
local_port = 443
remote_port = 9443

EOF

frptar='https://github.com/fatedier/frp/releases/download/v0.21.0/frp_0.21.0_linux_arm.tar.gz'

pushd ~
mkdir -p frp
pushd frp
wget $frptar
tar xvf frp_0.21.0_linux_arm.tar.gz
cp frpc /usr/bin/
chmod +xxx /usr/bin/frpc
popd
popd
}
