#!/bin/bash

# 设置变量
INSTALL_DIR="$HOME/3xpanel"
PORT=6689
REPO="MHSanaei/3x-ui"
ARCH="amd64"

# 创建安装目录
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit 1

# 获取最新版本号
LATEST_VERSION=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep tag_name | cut -d '"' -f 4)

# 构建下载链接
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_VERSION/3x-ui-linux-$ARCH.tar.gz"

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "部署环境：容器NIX-3x UI面板 非root免安装版"
echo "当前时间：$(date -u)"
echo "安装路径：$INSTALL_DIR"
echo "运行端口：$PORT"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "下载最新 3x-ui release..."
echo "👉 正在下载：$DOWNLOAD_URL"

# 下载并解压
curl -L "$DOWNLOAD_URL" -o 3x-ui.tar.gz
if [ $? -ne 0 ]; then
  echo "❌ 下载失败，请检查网络或稍后再试"
  exit 1
fi

tar -xzvf 3x-ui.tar.gz
chmod +x 3x-ui

# 初始化数据库
./3x-ui setting -username admin -password admin123
./3x-ui setting -port $PORT

# 添加到 .bashrc 实现自启
if ! grep -q "$INSTALL_DIR/3x-ui" ~/.bashrc; then
  echo "$INSTALL_DIR/3x-ui" >> ~/.bashrc
fi

# 启动 3x-ui 面板
echo "正在启动 3x-ui 面板..."
nohup ./3x-ui > /dev/null 2>&1 &

echo "✅ 安装完成！请使用以下信息登录面板："
echo "-------------------------------------------------"
echo "地址： http://<你的服务器IP>:$PORT"
echo "账户： admin"
echo "密码： admin123"
echo "（首次登录后请及时修改密码）"
echo "-------------------------------------------------"
