#!/bin/bash

# 修改 IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 移除不需要的插件
REMOVELIST="luci-app-frpc frpc luci-app-ddns-go ddns-go luci-app-natmap natmap luci-app-watchcat watchcat luci-app-xlnetacc luci-app-upnp miniupnpd luci-app-smartdns smartdns"
for pkg in $REMOVELIST; do
    find package/ feeds/ -name "$pkg" -type d -exec rm -rf {} + || true
done

# 【核心修复】先给 .config 注入 dnsmasq-full，再删普通版
sed -i 's/CONFIG_PACKAGE_dnsmasq=y/# CONFIG_PACKAGE_dnsmasq is not set/' .config
echo 'CONFIG_PACKAGE_dnsmasq-full=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-openclash=y' >> .config

# 排除普通 dnsmasq 源码，防止冲突
find package/ -name "dnsmasq" -type d -exec rm -rf {} + || true
