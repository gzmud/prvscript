#!/bin/bash
#
#raspberry pi  raspbian init cmd
#
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
systemctl enable docker
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
#systemctl daemon-reload
#systemctl restart docker
#docker info | grep Root
#DOMAIN=192.168.1.130        # example for allowing an IP
#DOMAIN=myclouddomain.net    # example for allowing a domain
#docker run -d -p 443:443 -p 80:80 -v ncdata:/data --name nextcloudpi ownyourbits/nextcloudpi $DOMAIN

#https://ownyourbits.com/2017/11/15/nextcloudpi-dockers-for-x86-and-arm/

echo

}
