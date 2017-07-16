#!/bin/bash
PRV_SSCONFIG=~/.ss.json

function prv_help ()
{
cat << EOF
private script 

Usage:

wget --cache=off --no-cache https://raw.github.com/gzmud/prvscript/master/prvscript.sh -O prvscript.sh
. prvscript.sh
EOF
}

function ssloc ()
{
  nohup ss-local -c $PRV_SSCONFIG -u /dev/null 2>&1 &
}

function ssconfig ()
{
cat <<EOF > $PRV_SSCONFIG
{
    "server":"$1",
    "server_port":#2,
    "local_address":"0.0.0.0",
    "local_port":1080,
    "password":"$3",
    "timeout":600,
    "method":"$4"
}
EOF
}

# for lede init

function lede_set ()
{
ledeimg="https://downloads.lede-project.org/snapshots/targets/brcm2708/bcm2710/lede-imagebuilder-brcm2708-bcm2710.Linux-x86_64.tar.xz"
ledesdk="https://downloads.lede-project.org/snapshots/targets/brcm2708/bcm2710/lede-sdk-brcm2708-bcm2710_gcc-5.4.0_musl.Linux-x86_64.tar.xz"
ledepkg='luci luci-ssl luci-theme-material luci-i18n-base-zh-cn kmod-usb-net-rtl8152'
}

function lede_pgetimgbuilder ()
{
proxychains wget $ledeimg
tar xJf lede-imagebuilder*.xz
rm -rf lede-img
mv `find  . -maxdepth 1 -name 'lede-imagebuilder*' -type d` lede-img

}

function lede_pgetsdk ()
{
proxychains wget $ledesdk
tar xJf lede-sdk*.xz
rm -rf lede-sdk
mv `find  . -maxdepth 1 -name 'lede-sdk-*' -type d` lede-sdk
}

function lede_getimgbuilder ()
{
wget $ledeimg
tar xJf lede-imagebuilder*.xz
rm -rf lede-img
mv `find  . -maxdepth 1 -name 'lede-imagebuilder*' -type d` lede-img

}

function lede_getsdk ()
{
wget $ledesdk
tar xJf lede-sdk*.xz
rm -rf lede-sdk
mv `find  . -maxdepth 1 -name 'lede-sdk-*' -type d` lede-sdk
}
