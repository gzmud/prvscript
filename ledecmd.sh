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

function lede_buildmyimg()
{
lede_set
mkdir -p $lededir/t
pushd t
	lede_dl
	lede_unpack
	pushd lede-sdk
	lede_setsdk
	lede_makesdk
	popd

	pushd lede-img
	lede_setimgconfig
	lede_makeimg
	popd
popd
}

function lede_dl()
{
test -e lede-img.tar.xz || wget $ledeimg -O lede-img.tar.xz
test -e lede-sdk.tar.xz || wget $ledesdk -O lede-sdk.tar.xz
test -e lede-sdk32.tar.xz || wget $ledesdk32 -O lede-sdk32.tar.xz
}

function lede_set8812()
{
lede_gitdl12345="https://github.com/dl12345/rtl8812au.git"
gtidl12345=$(readlink -f ./dl12345) 
lede_gitweedy="https://github.com/weedy/lede-rtl8812au-rtl8814au.git"
gitweedy="weedy"
}

function lede_dldrv()
{
lede_set8812
echo git clone $lede_gitdl12345 $gtidl12345
echo git clone $lede_gitweedy $gitweedy
}

function lede_unpack()
{
rm -rf lede-sdk
tar xJf lede-sdk.tar.xz

rm -rf lede-img
tar xJf lede-img.tar.xz

rm -rf lede-sdk32
tar xJf lede-sdk32.tar.xz
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

function lede_getsource()
{
./scripts/feeds update -a
#lede_getss
# ���� feeds
test -d package/feeds || git clone https://github.com/shadowsocks/openwrt-feeds.git package/feeds
# ��ȡ shadowsocks-libev Makefile
test -d package/shadowsocks-libev || git clone https://github.com/shadowsocks/openwrt-shadowsocks.git package/shadowsocks-libev
# ѡ��Ҫ����İ� Network -> shadowsocks-libev
#make menuconfig
# ��ʼ����
#make package/shadowsocks-libev/compile V=99

# lede_getchinadns
# ��ȡ Makefile
test -d package/chinadns || git clone https://github.com/aa65535/openwrt-chinadns.git package/chinadns
# ѡ��Ҫ����İ� Network -> ChinaDNS
# make menuconfig
# # ��ʼ����
# make package/chinadns/compile V=99

# lede_getDNS-forwarder
# ��ȡ Makefile
test -d package/dns-forwarder || git clone https://github.com/aa65535/openwrt-dns-forwarder.git package/dns-forwarder
# ѡ��Ҫ����İ� Network -> dns-forwarder
# make menuconfig
# # ��ʼ����
# make package/dns-forwarder/compile V=99

# lede_getsimple-obfs
# ���� feeds
test -d package/feeds || git clone https://github.com/shadowsocks/openwrt-feeds.git package/feeds
# ��ȡ simple-obfs Makefile
test -d package/simple-obfs || git clone https://github.com/aa65535/openwrt-simple-obfs.git package/simple-obfs
# # ѡ��Ҫ����İ� Network -> simple-obfs
# make menuconfig
# # ��ʼ����
# make package/simple-obfs/compile V=99

# lede_getluci-app-shadowsocks
# Clone ��Ŀ
test -d package/luci-app-shadowsocks || git clone https://github.com/shadowsocks/luci-app-shadowsocks.git package/luci-app-shadowsocks
# ���� po2lmo (�����po2lmo������)
# pushd package/luci-app-shadowsocks/tools/po2lmo
# make && sudo make install
# popd
# # ѡ��Ҫ����İ� LuCI -> 3. Applications
# make menuconfig
# # ��ʼ����
# make package/luci-app-shadowsocks/compile V=99

# lede_getopenwrt-dist-luci
test -d package/openwrt-dist-luci || git clone https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci
# ���� po2lmo (�����po2lmo������)
# pushd package/openwrt-dist-luci/tools/po2lmo
# make && sudo make install
# popd
# # ѡ��Ҫ����İ� LuCI -> 3. Applications
# make menuconfig
# # ��ʼ����
# make package/openwrt-dist-luci/compile V=99
}

function lede_makesdk()
{
make package/shadowsocks-libev/compile -j4
make package/chinadns/compile -j4
make package/dns-forwarder/compile -j4
make package/simple-obfs/compile -j4
make package/luci-app-shadowsocks/compile -j4
make package/openwrt-dist-luci/compile -j4
}

function lede_setimgconfig ()
{
#	CONFIG_BRCM2708_SD_BOOT_PARTSIZE=20
#	CONFIG_TARGET_ROOTFS_PARTSIZE=256
	sed -i 's/CONFIG_BRCM2708_SD_BOOT_PARTSIZE\=20/CONFIG_BRCM2708_SD_BOOT_PARTSIZE\=100/' .config
	sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE\=256/CONFIG_TARGET_ROOTFS_PARTSIZE\=768/' .config
	./scripts/feeds update -a
}

function lede_makeimg()
{
	lede_imgcpfile
	lede_imgcpipk
	make image PACKAGES="$ledepkg" FILES=files/
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
#!/bin/sh
cd /root/factoryipk
opkg update
opkg install libudns*.ipk libsodium*.ipk
opkg install shadowsocks-libev*.ipk luci-app-shadowsocks*.ipk
opkg install ChinaDNS*.ipk luci-app-chinadns*.ipk
opkg install dns-forwarder*.ipk luci-app-dns-forwarder*.ipk
opkg install coreutils-base64 ca-certificates ca-bundle curl

chmod +x /root/ss_watchdog.sh
chmod +x /root/update_ignore_list.sh

wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/chinadns_chnroute.txt

echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
sysctl -p

mkdir /etc/dnsmasq.d
uci get dhcp.@dnsmasq[0].confdir
uci add_list dhcp.@dnsmasq[0].confdir=/etc/dnsmasq.d
uci commit dhcp


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

cat <<EOF > files/root/ss_watchdog.sh
#!/bin/sh
 
LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")
wget --spider --quiet --tries=1 --timeout=10 https://www.facebook.com/
if [ "$?" == "0" ]; then
	echo '['$LOGTIME'] No Problem.'
	exit 0
else
	wget --spider --quiet --tries=1 --timeout=10 https://www.baidu.com/
	if [ "$?" == "0" ]; then
		echo '['$LOGTIME'] Problem decteted, restarting shadowsocks.'
		/etc/init.d/shadowsocks restart >/dev/null
	else
		echo '['$LOGTIME'] Network Problem. Do nothing.'
	fi
fi
EOF

cat <<EOF > files/root/update_ignore_list.sh
#!/bin/sh

set -e -o pipefail

wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | \
    awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > \
    /tmp/chinadns_chnroute.txt

mv /tmp/chinadns_chnroute.txt /etc/

if pidof ss-redir>/dev/null; then
    /etc/init.d/shadowsocks restart
fi
EOF

cat <<EOF > files/root/crontab
# �ļ���ʽ˵��
#  �������� (0 - 59)
# |  ����Сʱ (0 - 23)
# | |  ������   (1 - 31)
# | | |  ������   (1 - 12)
# | | | |  �������� (0 - 7)��������=0��7��
# | | | | |
# * * * * * ��ִ�е�����
*/10 * * * * /root/ss_watchdog.sh >> /var/log/ss_watchdog.log 2>&1
0 1 * * 7 echo "" > /var/log/ss_watchdog.log
30    4     *     *     *     /root/update_ignore_list.sh>/dev/null 2>&1
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