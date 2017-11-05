#!/bin/bash
#
#lede cmd ref  https://lede-project.org/docs/user-guide/imagebuilder
#

function prv_help ()
{
cat << EOF
private script 

Usage:

wget --no-cache https://raw.github.com/gzmud/prvscript/master/ledecmd.sh -O ledecmd.sh
. ledecmd.sh
EOF
}

# for lede init
function lede_set ()
{

ledeimg="https://downloads.lede-project.org/releases/17.01.2/targets/brcm2708/bcm2710/lede-imagebuilder-17.01.2-brcm2708-bcm2710.Linux-x86_64.tar.xz"

ledesdk="https://downloads.lede-project.org/releases/17.01.2/targets/brcm2708/bcm2710/lede-sdk-17.01.2-brcm2708-bcm2710_gcc-5.4.0_musl-1.1.16_eabi.Linux-x86_64.tar.xz"

ledepkg='luci luci-ssl luci-theme-material luci-i18n-base-zh-cn kmod-usb-net-rtl8152 kmod-usb-ohci kmod-usb-storage kmod-usb-hid kmod-usb2 kmod-fs-vfat kmod-fs-ext4 curl nano ip-full ipset iptables-mod-tproxy libev libpthread libpcre libssh2 libcares libstdcpp libmbedtls coreutils-base64 ca-certificates ca-bundle curl bind-dig mtd mount-utils block-mount ntfs-3g-utils minidlna samba36-server miniupnpd shadow-useradd usbutils luci-app-minidlna  luci-i18n-minidlna-zh-cn luci-app-samba luci-i18n-samba-zh-cn luci-app-upnp luci-i18n-upnp-zh-cn aria2 webui-aria2 yaaw luci-app-aria2 luci-i18n-aria2-zh-cn libudns libsodium shadowsocks-libev shadowsocks-libev-server luci-app-shadowsocks  ChinaDNS luci-app-chinadns dns-forwarder luci-app-dns-forwarder wget' 
ledesdk32="https://downloads.lede-project.org/releases/17.01.2/targets/brcm2708/bcm2708/lede-sdk-17.01.2-brcm2708-bcm2708_gcc-5.4.0_musl-1.1.16_eabi.Linux-x86_64.tar.xz"
#ledemyipk='aria2 webui-aria2 yaaw luci-app-aria2 luci-i18n-aria2-zh-cn'
ledemyipk='aria2 webui-aria2 yaaw'
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
	#make defconfig
	lede_makemyipk2
	popd

	pushd lede-img
	lede_setimgconfig
	lede_makeimg
	popd
popd
}

function lede_dl()
{
test -e ~/s/bin/targets/brcm2708/bcm2710/lede-sdk*.tar.xz && cp ~/s/bin/targets/brcm2708/bcm2710/lede-sdk*.tar.xz lede-sdk.tar.xz
test -e ~/s/bin/targets/brcm2708/bcm2710/lede-imagebuilder*.tar.xz && cp ~/s/bin/targets/brcm2708/bcm2710/lede-imagebuilder*.tar.xz lede-img.tar.xz
test -e lede-img.tar.xz || wget --no-cache $ledeimg -O lede-img.tar.xz
test -e lede-sdk.tar.xz || wget --no-cache $ledesdk -O lede-sdk.tar.xz
test -e lede-sdk32.tar.xz || wget --no-cache $ledesdk32 -O lede-sdk32.tar.xz
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
tar xJf lede-sdk.tar.xz
rm -rf lede-sdk
mv `find  . -maxdepth 1 -name 'lede-sdk-*' -type d` lede-sdk

tar xJf lede-img.tar.xz
rm -rf lede-img
mv `find  . -maxdepth 1 -name 'lede-imagebuilder*' -type d` lede-img

rm -rf lede-sdk32
tar xJf lede-sdk32.tar.xz
mv `find  . -maxdepth 1 -name 'lede-sdk-*' -type d` lede-sdk32
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
./scripts/feeds install $ledemyipk
}

function lede_getsource()
{
./scripts/feeds update -a
#lede_getss
# 添加 feeds
test -d package/feeds || git clone https://github.com/shadowsocks/openwrt-feeds.git package/feeds
# 获取 shadowsocks-libev Makefile
test -d package/shadowsocks-libev || git clone https://github.com/shadowsocks/openwrt-shadowsocks.git package/shadowsocks-libev
# 选择要编译的包 Network -> shadowsocks-libev
#make menuconfig
# 开始编译
#make package/shadowsocks-libev/compile V=99

# lede_getchinadns
# 获取 Makefile
test -d package/chinadns || git clone https://github.com/aa65535/openwrt-chinadns.git package/chinadns
# 选择要编译的包 Network -> ChinaDNS
# make menuconfig
# # 开始编译
# make package/chinadns/compile V=99

# lede_getDNS-forwarder
# 获取 Makefile
test -d package/dns-forwarder || git clone https://github.com/aa65535/openwrt-dns-forwarder.git package/dns-forwarder
# 选择要编译的包 Network -> dns-forwarder
# make menuconfig
# # 开始编译
# make package/dns-forwarder/compile V=99

# lede_getsimple-obfs
# 添加 feeds
test -d package/feeds || git clone https://github.com/shadowsocks/openwrt-feeds.git package/feeds
# 获取 simple-obfs Makefile
test -d package/simple-obfs || git clone https://github.com/aa65535/openwrt-simple-obfs.git package/simple-obfs
# # 选择要编译的包 Network -> simple-obfs
# make menuconfig
# # 开始编译
# make package/simple-obfs/compile V=99

# lede_getluci-app-shadowsocks
# Clone 项目
test -d package/luci-app-shadowsocks || git clone https://github.com/shadowsocks/luci-app-shadowsocks.git package/luci-app-shadowsocks
# 编译 po2lmo (如果有po2lmo可跳过)
# pushd package/luci-app-shadowsocks/tools/po2lmo
# make && sudo make install
# popd
# # 选择要编译的包 LuCI -> 3. Applications
# make menuconfig
# # 开始编译
# make package/luci-app-shadowsocks/compile V=99

# lede_getopenwrt-dist-luci
test -d package/openwrt-dist-luci || git clone https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci
# 编译 po2lmo (如果有po2lmo可跳过)
# pushd package/openwrt-dist-luci/tools/po2lmo
# make && sudo make install
# popd
# # 选择要编译的包 LuCI -> 3. Applications
# make menuconfig
# # 开始编译
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
	#sed -i 's/aarch64_cortex-a53/aarch64_cortex-a53_neon-vfpv4/' .config
	# CONFIG_TCP_CONG_BBR is not set
	#sed -i 's/\# CONFIG_TCP_CONG_BBR is not set/CONFIG_TCP_CONG_BBR\=y/' .config
	#sed -i 's/aarch64_cortex-a53\//aarch64_cortex-a53_neon-vfpv4\//' repositories.conf
	#src custom files/root/factoryipk
	./scripts/feeds update -a
}

function lede_makeimg()
{
	lede_imgcpfile
	lede_buildindex files/root/factoryipk/
	lede_genscript
	cp files/root/factoryipk/*.ipk packages
	make image PACKAGES="$ledepkg" FILES=files/
}

function lede_imgcpfile()
{
rm -rf files/
mkdir -p files/root/factoryipk
ipkbasedir="../lede-sdk/bin/packages/*/base"
cp $ipkbasedir/libudns*.ipk files/root/factoryipk
cp $ipkbasedir/shadowsocks-libev*.ipk files/root/factoryipk
cp $ipkbasedir/luci-app-shadowsocks_*.ipk files/root/factoryipk
cp $ipkbasedir/dns-forwarder*.ipk files/root/factoryipk
cp $ipkbasedir/luci-app-dns-forwarder_*.ipk files/root/factoryipk
cp $ipkbasedir/ChinaDNS_*.ipk files/root/factoryipk
cp $ipkbasedir/luci-app-chinadns_*.ipk files/root/factoryipk
cp $ipkbasedir/simple-obfs*.ipk files/root/factoryipk

ipkpkgdir="../lede-sdk/bin/packages/*/packages"
cp $ipkpkgdir/libsodium*.ipk files/root/factoryipk
cp $ipkpkgdir/aria2*.ipk files/root/factoryipk
cp $ipkpkgdir/webui-aria2*.ipk files/root/factoryipk
cp $ipkpkgdir/yaaw*.ipk files/root/factoryipk

ipklucidir="../lede-sdk/bin/packages/*/luci"
cp $ipklucidir/luci-app-aria2*.ipk files/root/factoryipk
cp $ipklucidir/luci-i18n-aria2-zh-cn*.ipk files/root/factoryipk
}

function lede_buildindex()
{
LEDE_OLDPATH="$PATH"
export PATH="$PATH:$(pwd)/staging_dir/host/bin:$(pwd)/scripts"
pushd $1
	ipkg-make-index.sh . 2>&1 > Packages.manifest
	grep -vE '^(Maintainer|LicenseFiles|Source|Require)' Packages.manifest > Packages && \
	gzip -9nc Packages > Packages.gz
popd
export PATH="$LEDE_OLDPATH"
}

function lede_genscript()
{
cat <<EOF > files/root/factoryinit.sh

EOF

cat <<EOF > files/root/ss_watchdog.sh
#!/bin/sh
 
LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")
wget --no-cache --spider --quiet --tries=1 --timeout=10 https://www.facebook.com/
if [ "$?" == "0" ]; then
	echo '['$LOGTIME'] No Problem.'
	exit 0
else
	wget --no-cache --spider --quiet --tries=1 --timeout=10 https://www.baidu.com/
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

wget --no-cache -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | \\
    awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", \$4, 32-log(\$5)/log(2)) }' > \\
    /tmp/chinadns_chnroute.txt

mv /tmp/chinadns_chnroute.txt /etc/

if pidof ss-redir>/dev/null; then
    /etc/init.d/shadowsocks restart
fi
EOF

cat <<EOF > files/root/crontab
# 文件格式说明
#  ——分钟 (0 - 59)
# |  ——小时 (0 - 23)
# | |  ——日   (1 - 31)
# | | |  ——月   (1 - 12)
# | | | |  ——星期 (0 - 7)（星期日=0或7）
# | | | | |
# * * * * * 被执行的命令
*/10 * * * * /root/ss_watchdog.sh >> /var/log/ss_watchdog.log 2>&1
0 1 * * 7 echo "" > /var/log/ss_watchdog.log
30    4     *     *     *     /root/update_ignore_list.sh>/dev/null 2>&1
EOF

}

function lede_makemyipk()
{
echo $ledemyipk  | xargs  -n1 echo | grep -v 'luci' | xargs -i make package/feeds/packages/{}/compile -j4
echo $ledemyipk  | xargs  -n1 echo | grep 'luci' | grep -v 'i18n' | xargs -i make package/feeds/luci/{}/compile -j4
}

function lede_makemyipk2()
{
for i in $ledemyipk;
do
if [[ $i =~ "luci" ]]
then
	! [[ $i =~ "i18n" ]] && make package/feeds/luci/$i/compile -j4
else	
	make package/feeds/packages/$i/compile -j4
fi
done
}

function lede_updatecmd()
{
pushd ~/prvscript
git pull
. ledecmd.sh
popd
}

function lede_getsource_all()
{
	cd
	git clone https://git.lede-project.org/source.git s
}

function lede_dbinit()
{
apt-get update
apt-get install -y build-essential libncurses5-dev gawk git subversion libssl-dev gettext unzip zlib1g-dev file python
}

function lede_quiltinit()
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

function lede_help ()
{
cat << EOF

from https://lede-project.org/docs/guide-developer/use-buildsystem

cd s
./scripts/feeds update -a
./scripts/feeds install -a
run make menuconfig and set target;
run make defconfig to set default config for build system and device;
run make menuconfig and modify set of package;
run scripts/diffconfig.sh >mydiffconfig (save your changes in the text file mydiffconfig);
make kernel_menuconfig CONFIG_TARGET=subtarget
git diff target/linux/
git checkout target/linux/
./scripts/diffconfig.sh > diffconfig # write the changes to diffconfig

Using diff file

These changes can form the basis of a config file (<buildroot dir>/.config). By running make defconfig these changes will be expanded into a full config.

cp diffconfig .config   # write changes to .config
make defconfig   # expand to full config
These changes can also be added to the bottom of the config file (<buildroot dir>/.config), by running make defconfig these changes will override the existing configuration.

cat diffconfig >> .config   # append changes to bottom of .config
make defconfig   # apply changes

ionice -c 3 nice -n19 make -j2
make package/cups/compile V=s
EOF
}
function ovz_bench() 
{ 
	wget -qO- bench.sh | bash
}