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

EOF
}

# for lede init
function ld_set ()
{
ldpkg='luci luci-ssl luci-theme-material luci-i18n-base-zh-cn kmod-usb-net-rtl8152 kmod-usb-ohci kmod-usb-storage kmod-usb-hid kmod-usb2 kmod-fs-vfat kmod-fs-ext4 curl nano ip-full ipset iptables-mod-tproxy libev libpthread libpcre libssh2 libcares libstdcpp libmbedtls coreutils-base64 ca-certificates ca-bundle curl bind-dig mtd mount-utils block-mount ntfs-3g-utils minidlna samba36-server miniupnpd shadow-useradd usbutils luci-app-minidlna  luci-i18n-minidlna-zh-cn luci-app-samba luci-i18n-samba-zh-cn luci-app-upnp luci-i18n-upnp-zh-cn aria2 webui-aria2 yaaw luci-app-aria2 luci-i18n-aria2-zh-cn libudns libsodium shadowsocks-libev shadowsocks-libev-server luci-app-shadowsocks ChinaDNS luci-app-chinadns dns-forwarder luci-app-dns-forwarder wget' 

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

function ld_get()
{
	pushd $lddir
	git clone https://git.lede-project.org/source.git s
}

function ld_gitit()
{
test -d $2 && ( pushd $2; git pull ; popd ) || git clone $1 $2
}

function ld_getmy()
{
#ld_gitit https://github.com/shadowsocks/openwrt-feeds.git package/feeds 
#ld_gitit https://github.com/shadowsocks/openwrt-shadowsocks.git package/shadowsocks-libev
ld_gitit https://github.com/aa65535/openwrt-chinadns.git package/chinadns
ld_gitit https://github.com/aa65535/openwrt-dns-forwarder.git package/dns-forwarder
#ld_gitit https://github.com/aa65535/openwrt-simple-obfs.git package/simple-obfs
#ld_gitit https://github.com/shadowsocks/luci-app-shadowsocks.git package/luci-app-shadowsocks
ld_gitit https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci
}

function ld_getsrc()
{
	ld_get
	pushd s
	./scripts/feeds update -a
	./scripts/feeds install -a
	ld_getmy
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

function ld_quiltinit()
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
}

function ld_checkcfg()
{
	./scripts/diffconfig.sh > hhhtmpdiff.conf
	rm hhhtmpnoneset.conf
	for i in $ledepkg
	do
		cat hhhtmpdiff.conf | grep CONFIG_PACKAGE_$i= || echo $i >> hhhtmpnoneset.conf
	done
	cat hhhtmpnoneset.conf
}

function ld_savecfg()
{
	./scripts/diffconfig.sh > ~/prvscript/ldconf/$(date +%Y-%m-%d-%s).conf
    pushd ~/prvscript
    git push
    popd
}