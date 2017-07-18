#!/bin/bash
#
#lede cmd ref  https://lede-project.org/docs/user-guide/imagebuilder
#
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

function lede_setimgconfig ()
{
#	CONFIG_BRCM2708_SD_BOOT_PARTSIZE=20
#	CONFIG_TARGET_ROOTFS_PARTSIZE=256
	sed -i 's/CONFIG_BRCM2708_SD_BOOT_PARTSIZE\=20/CONFIG_BRCM2708_SD_BOOT_PARTSIZE\=100/' .config
	sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE\=256/CONFIG_TARGET_ROOTFS_PARTSIZE\=768/' .config
}

function lede_makeimg()
{
	make image PACKAGES="$ledepkg"
}

function lede_pmakeimg()
{
	proxychains make image PACKAGES="$ledepkg"
}
function lede_setsdk()
{

# cat <<EOF >>feeds.conf.default
# src-git shadowsocks-libev https://github.com/shadowsocks/openwrt-shadowsocks.git
# src-git luci-app-shadowsocks https://github.com/shadowsocks/luci-app-shadowsocks.git
# src-git ChinaDNS https://github.com/aa65535/openwrt-chinadns.git
# src-git openwrt-dist-luci https://github.com/aa65535/openwrt-dist-luci.git
# src-git DNS-forwarder https://github.com/aa65535/openwrt-dns-forwarder.git
# src-git simple-obfs https://github.com/aa65535/openwrt-simple-obfs.git
# EOF

lede_getsource
./scripts/feeds update -a
}

function lede_psetsdk()
{

# cat <<EOF >>feeds.conf.default
# src-git shadowsocks-libev https://github.com/shadowsocks/openwrt-shadowsocks.git
# src-git luci-app-shadowsocks https://github.com/shadowsocks/luci-app-shadowsocks.git
# src-git ChinaDNS https://github.com/aa65535/openwrt-chinadns.git
# src-git openwrt-dist-luci https://github.com/aa65535/openwrt-dist-luci.git
# src-git DNS-forwarder https://github.com/aa65535/openwrt-dns-forwarder.git
# src-git simple-obfs https://github.com/aa65535/openwrt-simple-obfs.git
# EOF

lede_getsource
proxychains ./scripts/feeds update -a
}

function lede_getsource()
{
#lede_getss
# 添加 feeds
git clone https://github.com/shadowsocks/openwrt-feeds.git package/feeds
# 获取 shadowsocks-libev Makefile
git clone https://github.com/shadowsocks/openwrt-shadowsocks.git package/shadowsocks-libev
# 选择要编译的包 Network -> shadowsocks-libev
#make menuconfig
# 开始编译
#make package/shadowsocks-libev/compile V=99

# lede_getchinadns
# 获取 Makefile
git clone https://github.com/aa65535/openwrt-chinadns.git package/chinadns
# 选择要编译的包 Network -> ChinaDNS
# make menuconfig
# # 开始编译
# make package/chinadns/compile V=99

# lede_getDNS-forwarder
# 获取 Makefile
git clone https://github.com/aa65535/openwrt-dns-forwarder.git package/dns-forwarder
# 选择要编译的包 Network -> dns-forwarder
# make menuconfig
# # 开始编译
# make package/dns-forwarder/compile V=99

# lede_getsimple-obfs
# 添加 feeds
git clone https://github.com/shadowsocks/openwrt-feeds.git package/feeds
# 获取 simple-obfs Makefile
git clone https://github.com/aa65535/openwrt-simple-obfs.git package/simple-obfs
# # 选择要编译的包 Network -> simple-obfs
# make menuconfig
# # 开始编译
# make package/simple-obfs/compile V=99

# lede_getluci-app-shadowsocks
# Clone 项目
git clone https://github.com/shadowsocks/luci-app-shadowsocks.git package/luci-app-shadowsocks
# 编译 po2lmo (如果有po2lmo可跳过)
# pushd package/luci-app-shadowsocks/tools/po2lmo
# make && sudo make install
# popd
# # 选择要编译的包 LuCI -> 3. Applications
# make menuconfig
# # 开始编译
# make package/luci-app-shadowsocks/compile V=99

# lede_getopenwrt-dist-luci
git clone https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci
# 编译 po2lmo (如果有po2lmo可跳过)
# pushd package/openwrt-dist-luci/tools/po2lmo
# make && sudo make install
# popd
# # 选择要编译的包 LuCI -> 3. Applications
# make menuconfig
# # 开始编译
# make package/openwrt-dist-luci/compile V=99
}

function lede_pmakesdk()
{
proxychains make package/shadowsocks-libev/compile V=99
proxychains make package/chinadns/compile V=99
proxychains make package/dns-forwarder/compile V=99
proxychains make package/simple-obfs/compile V=99
proxychains make package/luci-app-shadowsocks/compile V=99
proxychains make package/openwrt-dist-luci/compile V=99
}
