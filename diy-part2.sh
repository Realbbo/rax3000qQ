#!/bin/bash

# 1. 修改默认 IP (这一行如果你不需要也可以注释掉)
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 2. 移除不需要的插件 (物理删除源码，防止它们被编译进固件)
# 加上 || true 是为了防止文件夹不存在时导致脚本报错退出
REMOVELIST="luci-app-frpc frpc luci-app-ddns-go ddns-go luci-app-natmap natmap luci-app-watchcat watchcat luci-app-xlnetacc luci-app-upnp miniupnpd luci-app-smartdns smartdns"
for pkg in $REMOVELIST; do
    find package/ feeds/ -name "$pkg" -type d -exec rm -rf {} + || true
done

# 3. 解决 OpenClash 依赖报错的核心逻辑
# 我们不通过 opkg 安装，而是在编译时就修正依赖
# 强制将 .config 中的 dnsmasq 替换为 dnsmasq-full
sed -i 's/CONFIG_PACKAGE_dnsmasq=y/# CONFIG_PACKAGE_dnsmasq is not set/' .config
echo 'CONFIG_PACKAGE_dnsmasq-full=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-openclash=y' >> .config
echo 'CONFIG_PACKAGE_luci-i18n-openclash-zh-cn=y' >> .config

# 4. 删除普通版 dnsmasq 源码，确保编译器只能选择 full 版
find package/ feeds/ -name "dnsmasq" -type d -exec rm -rf {} + || true
