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
#ledepkg='luci luci-ssl luci-theme-material luci-i18n-base-zh-cn kmod-usb-net-rtl8152 curl nano ip-full ipset iptables-mod-tproxy libev libpthread libpcre libmbedtls'
ledepkg='luci luci-ssl luci-theme-material luci-i18n-base-zh-cn kmod-usb-net-rtl8152 curl nano ip-full ipset iptables-mod-tproxy libev libpthread libpcre libmbedtls ChinaDNS dns-forwarder libsodium libudns luci-app-chinadns luci-app-dns-forwarder luci-app-shadowsocks-without-ipset luci-app-shadowsocks shadowsocks-libev-server shadowsocks-libev'
ledesdk32="https://downloads.lede-project.org/snapshots/targets/brcm2708/bcm2708/lede-sdk-brcm2708-bcm2708_gcc-5.4.0_musl_eabi.Linux-x86_64.tar.xz"
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
	#lede_imgcpfile
	lede_imgcpipk
	make image PACKAGES="$ledepkg" FILES=files/
}

function lede_pmakeimg()
{
	#lede_imgcpfile
	lede_imgcpipk
	proxychains make image PACKAGES="$ledepkg" FILES=files/
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

function lede_resetsdk()
{
rm -rf lede-sdk
tar xJf lede-sdk*.xz
rm -rf lede-sdk
mv `find  . -maxdepth 1 -name 'lede-sdk-*' -type d` lede-sdk
}

function lede_resetimg()
{
rm -rf lede-img
tar xJf lede-imagebuilder*.xz
rm -rf lede-img
mv `find  . -maxdepth 1 -name 'lede-imagebuilder*' -type d` lede-img

}

function lede_clean()
{
rm -rf lede-*
}

function lede_imgcpfile()
{
rm -rf files/
mkdir -p files/root/factoryipk
ipkbasedir="../lede-sdk/bin/packages/aarch64_cortex-a53_neon-vfpv4/base"
cp $ipkbasedir/libudns*.ipk files/root/factoryipk
cp $ipkbasedir/shadowsocks-libev*.ipk files/root/factoryipk
cp $ipkbasedir/luci-app*.ipk files/root/factoryipk
cp $ipkbasedir/dns-forwarder*.ipk files/root/factoryipk
cp $ipkbasedir/ChinaDNS_*.ipk files/root/factoryipk

ipkpkgdir="../lede-sdk/bin/packages/aarch64_cortex-a53_neon-vfpv4/packages"
cp $ipkpkgdir/libsodium*.ipk files/root/factoryipk

cat <<EOF > files/root/factoryinit.sh
#!/bin/bash
cd /root/factoryipk
opkg update
opkg install libudns*.ipk libsodium*.ipk
opkg install shadowsocks-libev*.ipk luci-app-shadowsocks*.ipk
opkg install ChinaDNS*.ipk luci-app-chinadns*.ipk
opkg install dns-forwarder*.ipk luci-app-dns-forwarder*.ipk

wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/chinadns_chnroute.txt

echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
sysctl -p

mkdir /etc/dnsmasq.d
uci get dhcp.@dnsmasq[0].confdir
uci add_list dhcp.@dnsmasq[0].confdir=/etc/dnsmasq.d
uci commit dhcp
opkg install coreutils-base64 ca-certificates ca-bundle curl

function dl_chnlistscrp ()
{
# China-List
curl -L -o generate_dnsmasq_chinalist.sh https://github.com/cokebar/openwrt-scripts/raw/master/generate_dnsmasq_chinalist.sh
chmod +x generate_dnsmasq_chinalist.sh
# GfwList
curl -L -o gfwlist2dnsmasq.sh https://github.com/cokebar/gfwlist2dnsmasq/raw/master/gfwlist2dnsmasq.sh
chmod +x gfwlist2dnsmasq.sh
}

function genchnlist ()
{
# China-list
sh generate_dnsmasq_chinalist.sh -d 114.114.114.114 -p 53 -o /etc/dnsmasq.d/accelerated-domains.china.conf
# GfwList
sh gfwlist2dnsmasq.sh -d 127.0.0.1 -p 5311 -o /etc/dnsmasq.d/dnsmasq_gfwlist.conf
# Restart dnsmasq
/etc/init.d/dnsmasq restart
}
EOF

}

function lede_imgcpipk()
{
ipkbasedir="../lede-sdk/bin/packages/aarch64_cortex-a53_neon-vfpv4/base"
cp $ipkbasedir/libudns*.ipk packages
cp $ipkbasedir/shadowsocks-libev*.ipk packages
cp $ipkbasedir/luci-app*.ipk packages
cp $ipkbasedir/dns-forwarder*.ipk packages
cp $ipkbasedir/ChinaDNS_*.ipk packages

ipkpkgdir="../lede-sdk/bin/packages/aarch64_cortex-a53_neon-vfpv4/packages"
cp $ipkpkgdir/libsodium*.ipk packages
}


functin lede_sdkmakertl8812au()
{
# it neef fix include arm
 rm -rf package/kernel/rtl8812au/
 cp -r ../lede-rtl8812au-rtl8814au/package/kernel/rtl8812au/ package/kernel/
 make package/kernel/rtl8812au/compile V=99
}

# insmod: error inserting 'wl.ko': -1 Unknown symbol in module
# 看到这段，应该是模块加载依赖的问题
# modinfo  ./wl.ko | grep depend   找模块的依赖，
# modprobe 找出的依赖
# insmod ./wl.ko

function lede_sdkpatche()
{
rm -rf ledesdk32
rm -rf lede-sdk32
mkdir ledesdk32
pushd ledesdk32
wget $ledesdk32
tar xJf lede-sdk*.xz
mv `find  . -maxdepth 1 -name 'lede-sdk-*' -type d` ../lede-sdk32
popd
cp -r lede-sdk32/build_dir/target-arm_arm1176jzf-s+vfp_musl_eabi/linux-brcm2708_bcm2708/linux-4.9.37/arch/arm/ lede-sdk/build_dir/target-aarch64_cortex-a53+neon-vfpv4_musl/linux-brcm2708_bcm2710/linux-4.9.37/arch/
}

function lede_makertl8812ua()
{
pushd ..
git clone https://github.com/weedy/lede-rtl8812au-rtl8814au.git
popd
cp -r ../lede-rtl8812au-rtl8814au/package/kernel/ package/
make package/kernel/rtl8812au/compile V=99
}
