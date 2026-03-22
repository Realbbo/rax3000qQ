#!/bin/bash

# 1. 修改默认管理 IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 2. 物理删除不需要的插件目录（强制精简）
# 即使 .config 里有 y，只要源码文件夹删了，编译器就会自动忽略，这是最稳的方法
REMOVELIST="luci-app-frpc frpc luci-app-ddns-go ddns-go luci-app-natmap natmap luci-app-watchcat watchcat luci-app-xlnetacc luci-app-upnp miniupnpd luci-app-smartdns smartdns"

for pkg in $REMOVELIST; do
    find package/ feeds/ -name "$pkg" -type d -exec rm -rf {} +
done

# 3. 解决 OpenClash 手动安装报错的核心：强制切换 dnsmasq 版本
# OpenWrt 默认带的是 dnsmasq，但 OpenClash 必须用 dnsmasq-full
# 我们先删除源码里的普通版，编译器就会被迫去编译 full 版
find package/ -name "dnsmasq" -type d -exec rm -rf {} +

# 4. 修正 .config 中的关键核心选项（防止被 SSR Plus 等重新勾选）
# 删除那些会导致自动下载几十MB二进制文件的 INCLUDE 选项
sed -i '/CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_v2ray/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray/d' .config
# 5. 修正 DNS 冲突（OpenClash 必备）
sed -i 's/CONFIG_PACKAGE_dnsmasq=y/# CONFIG_PACKAGE_dnsmasq is not set/' .config
sed -i '/CONFIG_PACKAGE_dnsmasq-full/d' .config
echo 'CONFIG_PACKAGE_dnsmasq-full=y' >> .config

# 6. 移除你明确不需要的插件（避免挤占空间）
sed -i '/CONFIG_PACKAGE_luci-app-watchcat/d' .config
sed -i '/CONFIG_PACKAGE_watchcat/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-upnp/d' .config
sed -i '/CONFIG_PACKAGE_miniupnpd/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-ddns-go/d' .config
sed -i '/CONFIG_PACKAGE_ddns-go/d' .config

# 7. 砍掉 SSR Plus 和 VSSR 的巨大内核（如果你用 OpenClash，这些是没用的）
sed -i '/CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_v2ray/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray/d' .config
