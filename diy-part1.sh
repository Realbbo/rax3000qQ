#!/bin/bash
# 1. 添加 OpenClash 官方源
echo 'src-git openclash https://github.com/vernesong/OpenClash.git' >> feeds.conf.default

# 2. 保留你原本的插件仓库
echo 'src-git kenzok8 https://github.com/kenzok8/openwrt-packages' >> feeds.conf.default
echo 'src-git small8 https://github.com/kenzok8/small' >> feeds.conf.default
