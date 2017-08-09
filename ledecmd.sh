#!/bin/bash
#
#lede cmd ref  https://lede-project.org/docs/user-guide/imagebuilder
#

function prv_help ()
{
cat << EOF
private script 

Usage:

wget --cache=off --no-cache https://raw.github.com/gzmud/prvscript/master/ledecmd.sh -O ledecmd.sh
. ledecmd.sh
EOF
}

# for lede init
function lede_set ()
{
ledeimg="https://downloads.lede-project.org/snapshots/targets/brcm2708/bcm2710/lede-imagebuilder-brcm2708-bcm2710.Linux-x86_64.tar.xz"
ledesdk="https://downloads.lede-project.org/snapshots/targets/brcm2708/bcm2710/lede-sdk-brcm2708-bcm2710_gcc-5.4.0_musl.Linux-x86_64.tar.xz"
ledepkg='luci luci-ssl luci-theme-material luci-i18n-base-zh-cn kmod-usb-net-rtl8152 curl nano ip-full ipset iptables-mod-tproxy libev libpthread libpcre libmbedtls ChinaDNS dns-forwarder libsodium libudns luci-app-chinadns luci-app-dns-forwarder luci-app-shadowsocks-without-ipset luci-app-shadowsocks shadowsocks-libev-server shadowsocks-libev'
ledesdk32="https://downloads.lede-project.org/snapshots/targets/brcm2708/bcm2708/lede-sdk-brcm2708-bcm2708_gcc-5.4.0_musl_eabi.Linux-x86_64.tar.xz"
lededir=$(readlink -f .) 
}
