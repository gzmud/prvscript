#!/bin/bash
#
#ovzinit cmd
#
PRV_SSCONFIG=/etc/shadowsocks-libev/config.json

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
apt-get install -y nano screen git
}

function ovz_installwebmin()
{
#webmin
apt-get update
apt-get install -y webmin
}

function ovz_lkl()
{

}

function ovz_installss()
{
#ss
#sh -c 'printf "deb http://deb.debian.org/debian jessie-backports main\n" > /etc/apt/sources.list.d/jessie-backports.list'
#sh -c 'printf "deb http://deb.debian.org/debian jessie-backports-sloppy main" >> /etc/apt/sources.list.d/jessie-backports.list'
#apt update
#apt -y -t jessie-backports-sloppy install shadowsocks-libev
test -z "$1" && SS_PORT="1088" || SS_PORT="$1"
test -z "$2" && SS_PASS='mustbescrt!@' || SS_PASS="$2"
test -z "$3" && SS_MATHOS="chacha20-ietf" || SS_MATHOS="$3" 
ovz_ssconfig "$SS_PORT" "$SS_PASS" "$SS_MATHOS"
}

function ovz_ssloc ()
{
  nohup ss-local -c $PRV_SSCONFIG -u /dev/null 2>&1 &
}

function ovz_ssconfig ()
{
cat <<EOF >$PRV_SSCONFIG
{
    "server":"0.0.0.0",
    "server_port":$1,
    "local_address":"0.0.0.0",
    "local_port":1080,
    "password":"$2",
    "timeout":600,
    "method":"$3"
}
EOF
}
