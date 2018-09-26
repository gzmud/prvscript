#!/bin/bash
#
#lede cmd ref  https://lede-project.org/docs/user-guide/imagebuilder
#git clone https://github.com/gzmud/prvscript.git
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
lededir=$(readlink -f .)
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
	lede_imgcpfile
	lede_imgcpipk
	make image PACKAGES="$ledepkg" FILES=files/
}

function lede_pmakeimg()
{
	lede_imgcpfile
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
# ���� feeds
git clone https://github.com/shadowsocks/openwrt-feeds.git package/feeds
# ��ȡ shadowsocks-libev Makefile
git clone https://github.com/shadowsocks/openwrt-shadowsocks.git package/shadowsocks-libev
# ѡ��Ҫ�����İ� Network -> shadowsocks-libev
#make menuconfig
# ��ʼ����
#make package/shadowsocks-libev/compile V=99

# lede_getchinadns
# ��ȡ Makefile
git clone https://github.com/aa65535/openwrt-chinadns.git package/chinadns
# ѡ��Ҫ�����İ� Network -> ChinaDNS
# make menuconfig
# # ��ʼ����
# make package/chinadns/compile V=99

# lede_getDNS-forwarder
# ��ȡ Makefile
git clone https://github.com/aa65535/openwrt-dns-forwarder.git package/dns-forwarder
# ѡ��Ҫ�����İ� Network -> dns-forwarder
# make menuconfig
# # ��ʼ����
# make package/dns-forwarder/compile V=99

# lede_getsimple-obfs
# ���� feeds
git clone https://github.com/shadowsocks/openwrt-feeds.git package/feeds
# ��ȡ simple-obfs Makefile
git clone https://github.com/aa65535/openwrt-simple-obfs.git package/simple-obfs
# # ѡ��Ҫ�����İ� Network -> simple-obfs
# make menuconfig
# # ��ʼ����
# make package/simple-obfs/compile V=99

# lede_getluci-app-shadowsocks
# Clone ��Ŀ
git clone https://github.com/shadowsocks/luci-app-shadowsocks.git package/luci-app-shadowsocks
# ���� po2lmo (������po2lmo������)
# pushd package/luci-app-shadowsocks/tools/po2lmo
# make && sudo make install
# popd
# # ѡ��Ҫ�����İ� LuCI -> 3. Applications
# make menuconfig
# # ��ʼ����
# make package/luci-app-shadowsocks/compile V=99

# lede_getopenwrt-dist-luci
git clone https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci
# ���� po2lmo (������po2lmo������)
# pushd package/openwrt-dist-luci/tools/po2lmo
# make && sudo make install
# popd
# # ѡ��Ҫ�����İ� LuCI -> 3. Applications
# make menuconfig
# # ��ʼ����
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

function lede_makesdk()
{
make package/shadowsocks-libev/compile -j4
make package/chinadns/compile -j4
make package/dns-forwarder/compile -j4
make package/simple-obfs/compile -j4
make package/luci-app-shadowsocks/compile -j4
make package/openwrt-dist-luci/compile -j4
}

function lede_buildmyimg()
{
mkdir t
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

# insmod: error inserting 'wl.ko': -1 Unknown symbol in module
# �������Σ�Ӧ����ģ����������������
# modinfo  ./wl.ko | grep depend   ��ģ����������
# modprobe �ҳ�������
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
#git clone https://github.com/weedy/lede-rtl8812au-rtl8814au.git
git clone https://github.com/dl12345/rtl8812au.git
popd
#cp -r ../lede-rtl8812au-rtl8814au/package/kernel/ package/
cp -r ../rtl8812au/ package/
make package/kernel/rtl8812au/compile V=99
}

function lede_remakertl8812ua()
{
rm -rf package/kernel/rtl8812au
#cp -r ../lede-rtl8812au-rtl8814au/package/kernel/ package/
cp -r ../rtl8812au package/kernel/
make package/kernel/rtl8812au/compile V=99
}

function lede_get8812au()
{
pushd ..
#git clone https://github.com/weedy/lede-rtl8812au-rtl8814au.git
git clone https://github.com/dl12345/rtl8812au.git
popd
#cp -r ../lede-rtl8812au-rtl8814au/package/kernel/ package/
cp -r ../rtl8812au/ package/
}

function lede_diffMK()
{
#diff of rtl8812AU Makefile
cat <<EOF
--- a/Makefile
+++ b/Makefile
@@ -85,8 +85,8 @@ CONFIG_AP_WOWLAN = n
 ######### Notify SDIO Host Keep Power During Syspend ##########
 CONFIG_RTW_SDIO_PM_KEEP_POWER = y
 ###################### Platform Related #######################
-CONFIG_PLATFORM_I386_PC = y
-CONFIG_PLATFORM_ARM_RPI = n
+CONFIG_PLATFORM_I386_PC = n
+CONFIG_PLATFORM_ARM_RPI = y
 CONFIG_PLATFORM_ANDROID_X86 = n
 CONFIG_PLATFORM_ANDROID_INTEL_X86 = n
 CONFIG_PLATFORM_JB_X86 = n
@@ -136,7 +136,7 @@ CONFIG_PLATFORM_MOZART = n
 CONFIG_PLATFORM_RTK119X = n
 CONFIG_PLATFORM_NOVATEK_NT72668 = n
 CONFIG_PLATFORM_HISILICON = n
-CONFIG_PLATFORM_ARM64 = n
+CONFIG_PLATFORM_ARM64 = y
 ###############################################################

 CONFIG_DRVEXT_MODULE = n
EOF

#diff of ledepkg Makefile
cat <<EOF
--- a/package/kernel/rtl8812au/Makefile
+++ b/package/kernel/rtl8812au/Makefile
@@ -11,12 +11,12 @@ include $(INCLUDE_DIR)/kernel.mk
 include $(INCLUDE_DIR)/kernel-defaults.mk

 PKG_NAME:=RTL8812A
-PKG_VERSION=2016-10-20-$(PKG_SOURCE_VERSION)
+PKG_VERSION=2016-10-26-$(PKG_SOURCE_VERSION)
 PKG_RELEASE:=1

 PKG_SOURCE_PROTO:=git
-PKG_SOURCE_URL:=https://github.com/weedy/rtl8812AU.git
-PKG_SOURCE_VERSION:=a422338714853794b7cfb8ed7e2fcec355b4399d
+PKG_SOURCE_URL:=https://github.com/diederikdehaas/rtl8812AU.git
+PKG_SOURCE_VERSION:=845607043e532c26a196e96f837a449952a36c87
 PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)
 PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

@@ -36,7 +36,7 @@ endef

 define Build/Compile
        $(MAKE) $(KERNEL_MAKEOPTS) M=$(PKG_BUILD_DIR) \
-               USER_EXTRA_CFLAGS="-D_LINUX_BYTEORDER_SWAB_H -DCONFIG_BIG_ENDIAN -DCONFIG_IOCTL_CFG80211 -DRTW_USE_CFG80211_STA_EVENT" \
+               USER_EXTRA_CFLAGS="-D_LINUX_BYTEORDER_SWAB_H" \
                CONFIG_RTL8812A=y CONFIG_RTL8821A=y CONFIG_RTL8812AU_8821AU=m \
                modules
 endef
EOF
}

function lede_prepare()
{
lede_dl
}

function lede_8812set()
{
lede_gitdl12345="https://github.com/dl12345/rtl8812au.git"
gtidl12345=$(readlink -f ./dl12345)
lede_gitweedy="https://github.com/weedy/lede-rtl8812au-rtl8814au.git"
gitweedy="weedy"
}

function lede_dl()
{
lede_set
wget $ledeimg
wget $ledesdk
mkdir ledesdk32
pushd ledesdk32
wget $ledesdk32
popd
lede_8812set
git clone $lede_gitdl12345 $gtidl12345
git clone $lede_gitweedy $gitweedy
}

function lede_unpack()
{
pushd $lededir
tar xJf lede-sdk*.xz
rm -rf lede-sdk
mv `find  . -maxdepth 1 -name 'lede-sdk-*' -type d` lede-sdk

tar xJf lede-imagebuilder*.xz
rm -rf lede-img
mv `find  . -maxdepth 1 -name 'lede-imagebuilder*' -type d` lede-img

rm -rf lede-sdk32
pushd ledesdk32
tar xJf lede-sdk*.xz
mv `find  . -maxdepth 1 -name 'lede-sdk-*' -type d` ../lede-sdk32
popd
cp -r lede-sdk32/build_dir/target-arm_arm1176jzf-s+vfp_musl_eabi/linux-brcm2708_bcm2708/linux-4.9.37/arch/arm/ lede-sdk/build_dir/target-aarch64_cortex-a53+neon-vfpv4_musl/linux-brcm2708_bcm2710/linux-4.9.37/arch/
pushd lede-sdk
#./scripts/feeds update -a
#./scripts/feeds install -a
#mkdir -p staging_dir/toolchain-aarch64_cortex-a53+neon-vfpv4_gcc-5.4.0_musl/usr/include/mac80211/
#cp build_dir/target-aarch64_cortex-a53+neon-vfpv4_musl/linux-brcm2708_bcm2710/linux-4.9.37/Module.symvers staging_dir/toolchain-aarch64_cortex-a53+neon-vfpv4_gcc-5.4.0_musl/usr/include/mac80211/
cp ../weedy/package/kernel/rtl8812au/ package/kernel/ -r
popd
popd
}

function lede_clean()
{
 rm lede-sdk lede-sdk32 -rf
}

function lede_insbuildsys()
{
apt-get install build-essential libncurses5-dev gawk git subversion libssl-dev gettext unzip zlib1g-dev file python
git clone https://git.lede-project.org/source.git
}

function lede_bldprp()
{
git pull
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
make defconfig
}

function db_instdocker()
{
if [ `id -u` -eq 0 ];then
    echo "root ! go on"
else
    echo "not root ! exit"
	return -1
fi
apt-get remove docker docker-engine docker.io
apt-get update
apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install docker-ce
}

function db_ulimit() {
  #statements
  echo 'ulimit -n 65535' >/etc/profile.d/ulimit.sh
}

function db_set_caddy() {
  #https://github.com/mholt/caddy/tree/master/dist/init/linux-systemd
  #cp /path/to/caddy /usr/local/bin
  #chown root:root /usr/local/bin/caddy
  #chmod 755 /usr/local/bin/caddy
  setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy
  mkdir /var/www
  chown www-data:www-data /var/www
  chmod 555 /var/www
  cp -R example.com /var/www/
  chown -R www-data:www-data /var/www/example.com
  chmod -R 555 /var/www/example.com

  wget https://raw.githubusercontent.com/mholt/caddy/master/dist/init/linux-systemd/caddy.service
  cp caddy.service /etc/systemd/system/
  chown root:root /etc/systemd/system/caddy.service
  chmod 644 /etc/systemd/system/caddy.service

cat << EOF > /etc/caddy/Caddyfile
nas.sdmud.tk {
    gzip
    tls sdimud@gmail.com {
    protocols tls1.0 tls1.2
    }
    proxy  / 10.0.0.2 {
        websocket
        transparent
        insecure_skip_verify
    }
}
EOF

  systemctl daemon-reload
  systemctl start caddy.service

  systemctl enable caddy.service

  #journalctl --boot -u caddy.service
  #journalctl -f -u caddy.service
  #setfacl -m user:www-data:r-- /etc/ssl/private/my.key
}
