#!/bin/bash

# 设置颜色
green='\033[0;32m'
plain='\033[0m'

# 设置安装路径和端口
INSTALL_DIR="$HOME/3xpanel"
PORT=6689

echo -e "${green}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${plain}"
echo -e "${green}部署环境：容器NIX-3x UI面板 非root免安装版${plain}"
echo -e "${green}当前时间：$(date -u)${plain}"
echo -e "${green}安装路径：${INSTALL_DIR}${plain}"
echo -e "${green}运行端口：${PORT}${plain}"
echo -e "${green}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${plain}"

# 创建安装目录
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit

# 检测系统架构
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  *) echo -e "${red}不支持的架构: $ARCH${plain}"; exit 1 ;;
esac

# 设置3x-ui版本
VERSION="v2.5.8"

# 下载3x-ui
echo -e "${green}下载最新 3x-ui release...${plain}"
DOWNLOAD_URL="https://github.com/MHSanaei/3x-ui/releases/download/${VERSION}/3x-ui-linux-${ARCH}.tar.gz"
echo -e "👉 正在下载：$DOWNLOAD_URL"

wget -O 3x-ui.tar.gz "$DOWNLOAD_URL"
if [ $? -ne 0 ]; then
  echo -e "${red}❌ 下载失败，请检查网络或稍后再试${plain}"
  exit 1
fi

# 解压文件
tar -xzf 3x-ui.tar.gz
chmod +x 3x-ui

# 初始化数据库
./3x-ui setting -username admin -password admin123
./3x-ui setting -port $PORT

# 添加自启动到 .bashrc
if ! grep -q "$INSTALL_DIR/3x-ui" "$HOME/.bashrc"; then
  echo -e "\n# 启动3x-ui面板" >> "$HOME/.bashrc"
  echo "$INSTALL_DIR/3x-ui" >> "$HOME/.bashrc"
fi

# 启动3x-ui
echo -e "${green}正在启动 3x-ui 面板...${plain}"
nohup ./3x-ui > /dev/null 2>&1 &

echo -e "${green}✅ 安装完成！请使用以下信息登录面板：${plain}"
echo -e "-------------------------------------------------"
echo -e "地址： http://<你的服务器IP>:${PORT}"
echo -e "账户： admin"
echo -e "密码： admin123"
echo -e "（首次登录后请及时修改密码）"
echo -e "-------------------------------------------------"
