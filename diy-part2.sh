#!/bin/bash

# 1. 修改默认管理 IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 2. 强力清除 .config 中不需要的插件（不再物理删除文件夹，确保依赖链完整）
# 这样能解决 "does not exist" 和 "recursive dependency" 报错
REMOVELIST="luci-app-frpc frpc luci-app-ddns-go ddns-go luci-app-natmap natmap luci-app-watchcat watchcat luci-app-xlnetacc luci-app-upnp miniupnpd luci-app-smartdns smartdns"

for pkg in $REMOVELIST; do
    sed -i "/CONFIG_PACKAGE_$pkg=y/d" .config
    echo "# CONFIG_PACKAGE_$pkg is not set" >> .config
done

# 3. 核心修复：强制选择 dnsmasq-full 供 OpenClash 使用
# 我们不删源码，只是在配置里切换
sed -i 's/CONFIG_PACKAGE_dnsmasq=y/# CONFIG_PACKAGE_dnsmasq is not set/' .config
sed -i '/CONFIG_PACKAGE_dnsmasq-full/d' .config
echo 'CONFIG_PACKAGE_dnsmasq-full=y' >> .config

# 4. 彻底关掉导致空间爆满的 Xray/v2ray 核心 (针对 SSR Plus 和 VSSR)
sed -i '/CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_v2ray/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray/d' .config
