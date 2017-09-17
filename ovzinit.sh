#!/bin/bash
#
#ovzinit cmd
#

function ovz_updatecmd()
{
pushd ~/prvscript
git pull
. ovzinit.sh
popd
}

function ovz_init()
{
#change pwd
passwd
}

function ovz_test()
{
#test net speed
time wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip
time wget -O /dev/null http://cachefly.cachefly.net/100mb.test

time (for((i=1;i<=10000;i++));do echo $(expr $i \* 4) > /dev/null ;done)
time echo "scale=2000; 4*a(1)" | bc -l -q
}

function ovz_bench()
{
wget -qO- bench.sh | bash
}

function ovz_initapt()
{
apt-get update
apt-get install -y nano screen
}

function ovz_webmin()
{
#webmin
apt-get update
apt-get install -y webmin
}

function ovz_lkl()
{

}

function ovz_ss()
{
#ss
apt-get update
apt-get install -y ss?
}
function ovz_
