#!/bin/bash

# 设置颜色
green='\033[0;32m'
red='\033[0;31m'
plain='\033[0m'

# 显示部署信息
echo -e "${green}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${plain}"
echo -e "${green}部署环境：容器NIX-3x UI面板 非root免安装版${plain}"
echo -e "${green}当前时间：$(date -u)${plain}"
echo -e "${green}安装路径：$HOME/3xpanel${plain}"
echo -e "${green}运行端口：6689${plain}"
echo -e "${green}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${plain}"

# 创建安装目录
mkdir -p "$HOME/3xpanel"
cd "$HOME/3xpanel" || exit 1

# 下载最新版本的 3x-ui
echo -e "${green}下载最新 3x-ui release...${plain}"
latest_version=$(curl -s https://api.github.com/repos/MHSanaei/3x-ui/releases/latest | grep tag_name | cut -d '"' -f 4)
download_url="https://github.com/MHSanaei/3x-ui/releases/download/${latest_version}/3x-ui-linux-amd64.tar.gz"

echo -e "${green}👉 正在下载：$download_url${plain}"
curl -L -o 3x-ui-linux-amd64.tar.gz "$download_url"

# 解压并设置权限
tar -zxvf 3x-ui-linux-amd64.tar.gz
chmod +x 3x-ui

# 初始化数据库
./3x-ui db migrate

# 设置默认账户
echo -e "${green}默认账户：admin / admin123${plain}"

# 配置 .bashrc 自启
echo "cd $HOME/3xpanel && ./3x-ui" >> "$HOME/.bashrc"
echo -e "${green}已设置 .bashrc 自启${plain}"

# 启动 3x-ui 面板
echo -e "${green}正在启动 3x-ui 面板...${plain}"
./3x-ui

# 显示完成信息
echo -e "${green}✅ 安装完成！请使用以下信息登录面板：${plain}"
echo -e "${green}-------------------------------------------------${plain}"
echo -e "${green}地址： http://<你的服务器IP>:6689${plain}"
echo -e "${green}账户： admin${plain}"
echo -e "${green}密码： admin123${plain}"
echo -e "${green}（首次登录后请及时修改密码）${plain}"
echo -e "${green}-------------------------------------------------${plain}"
