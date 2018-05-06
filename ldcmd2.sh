#!/bin/bash
#
#ldcmd ref  https://lede-project.org/docs/user-guide/imagebuilder
#

function prv_help ()
{
cat << EOF
private script 

Usage:

wget --cache=off --no-cache https://raw.github.com/gzmud/prvscript/master/ldcmd2.sh -O ldcmd2.sh && . ldcmd2.sh
git clone https://github.com/gzmud/prvscript.git

EOF
}

# for lede init
function ld_set ()
{
ldpkg='luci luci-ssl luci-theme-material luci-i18n-base-zh-cn kmod-usb-net-rtl8152 kmod-usb-ohci kmod-usb-storage kmod-usb-hid kmod-usb2 kmod-fs-vfat kmod-fs-ext4 curl nano ip-full ipset iptables-mod-tproxy libev libpthread libpcre libssh2 libcares libstdcpp libmbedtls coreutils-base64 ca-certificates ca-bundle bind-dig mtd mount-utils block-mount ntfs-3g-utils minidlna samba36-server miniupnpd shadow-useradd usbutils luci-app-minidlna luci-i18n-minidlna-zh-cn luci-app-samba luci-i18n-samba-zh-cn luci-app-upnp luci-i18n-upnp-zh-cn aria2 webui-aria2 yaaw luci-app-aria2 luci-i18n-aria2-zh-cn libudns libsodium shadowsocks-libev shadowsocks-libev-server luci-app-shadowsocks ChinaDNS luci-app-chinadns dns-forwarder luci-app-dns-forwarder wget' 

#ldmyipk='aria2 webui-aria2 yaaw luci-app-aria2 luci-i18n-aria2-zh-cn'
ldmyipk='aria2 webui-aria2 yaaw'
lddir=$(readlink -f .) 
}

function ld_updatecmd()
{
pushd ~/prvscript
git pull
. ldcmd2.sh
popd
}

function _ld_get()
{
	pushd $lddir
	git clone https://git.lede-project.org/source.git s
}

function _ld_gitit()
{
test -d $2 && ( pushd $2; git pull ; popd ) || git clone $1 $2
}

function _ld_getmy()
{
#_ld_gitit https://github.com/shadowsocks/openwrt-feeds.git package/feeds 
./scripts/feeds uninstall shadowsocks-libev 
_ld_gitit https://github.com/shadowsocks/openwrt-shadowsocks.git package/shadowsocks-libev
_ld_gitit https://github.com/aa65535/openwrt-chinadns.git package/chinadns
_ld_gitit https://github.com/aa65535/openwrt-dns-forwarder.git package/dns-forwarder
_ld_gitit https://github.com/aa65535/openwrt-simple-obfs.git package/simple-obfs
_ld_gitit https://github.com/shadowsocks/luci-app-shadowsocks.git package/luci-app-shadowsocks
_ld_gitit https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci
}

function ld_getsrc()
{
	_ld_get
	pushd s
	./scripts/feeds update -a
	./scripts/feeds install -a
	_ld_getmy
}

function ld_build()
{
	make -j4 tools/compile
	make -j1 tools/cmake/compile
	make -j4 tools/compile
	make -j4 toolchain/compile
	make -j1 toolchain/compile
	make -j4
	#make target/linux/compile -j4 V=99
	#make target/compile -j4
	#make package/compile -j4
}

function ld_make()
{
#ld_getsrc
#ld_update
ld_kerconf
ld_build
}

function _ld_quiltinit()
{
cat > ~/.quiltrc <<EOF
QUILT_DIFF_ARGS="--no-timestamps --no-index -p ab --color=auto"
QUILT_REFRESH_ARGS="--no-timestamps --no-index -p ab"
QUILT_SERIES_ARGS="--color=auto"
QUILT_PATCH_OPTS="--unified"
QUILT_DIFF_OPTS="-p"
EDITOR="nano"
EOF
}

function ld_kerconf()
{
make menuconfig
make defconfig
make kernel_menuconfig CONFIG_TARGET=subtarget -j4
sed -i 's/CONFIG_BRCM2708_SD_BOOT_PARTSIZE\=20/CONFIG_BRCM2708_SD_BOOT_PARTSIZE\=100/' .config
sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE\=256/CONFIG_TARGET_ROOTFS_PARTSIZE\=768/' .config
}

function ld_checkcfg()
{
awk -v ldpkg="$ldpkg" 'BEGIN {gsub(/ +/," ",ldpkg);tLen = split(ldpkg,tNeed," ")};{for(k in tNeed ){if ($0 ~ "_"tNeed[k]"=y") {print $0;tHave[k]=tNeed[k];delete tNeed[k] } else if ($0 ~ "_"tNeed[k]" " ){ print "\033[40;33m"$0"\033[0m"} }}; END {for(k in tNeed ){ print tNeed[k] };print length(tNeed)}' .config
}

function ld_modcfg()
{
	for i in $ldpkg
	do
		cat hhhtmpdiff.conf | grep CONFIG_PACKAGE_$i= || echo $i >> hhhtmpnoneset.conf
	done
	cat hhhtmpnoneset.conf
	#awk -v ldpkg="$ldpkg" 'BEGIN {gsub(/ +/," ",ldpkg);tLen = split(ldpkg,tNeedpkg," ");for(k in tNeedpkg){ tStat [ tNeedpkg[k] ]="n"}};{for(k in tStat ){ if ($0 ~ "_"k "=y") {print $0;tStat[ k ] ="y";delete tStat[ k ];tHave[k]="y" } else if ($0 ~ "_"k" " ){ print "\033[40;33m"$0"\033[0m"} }}; END {for(k in tStat ){ print k }}' .config
	#awk -v ldpkg="$ldpkg" 'BEGIN {gsub(/ +/," ",ldpkg);tLen = split(ldpkg,tNeed," ")};{for(k in tNeed ){key=tNeed[k]; if ($0 ~ "_"key"=y") {print $0;tHave[k]=key;delete tNeed[k] } else if ($0 ~ "_"key" " ){ print "\033[40;33m"$0"\033[0m"} }}; END {for(k in tNeed ){ print tNeed[k] }}' .config
	#awk -v ldpkg="$ldpkg" 'BEGIN {gsub(/ +/," ",ldpkg);tLen = split(ldpkg,tNeed," ")};{for(k in tNeed ){if ($0 ~ "_"tNeed[k]"=y") {print $0;tHave[k]=tNeed[k];delete tNeed[k] } else if ($0 ~ "_"tNeed[k]" " ){ print "\033[40;33m"$0"\033[0m"} }}; END {for(k in tNeed ){ print tNeed[k] };print length(tNeed)}' .config

}

function ld_savecfg()
{
    conffile=ldconf/$(date +%Y-%m-%d-%s).conf
	./scripts/diffconfig.sh > ~/prvscript/$conffile
    pushd ~/prvscript
    git pull
    git add conffile
    git commit -a -m "add $conffile"
    git push
    popd
}
