#!/bin/bash
export LANG=en_US.UTF-8
export nix=${nix:-''}
[ -z "$nix" ] && sys='主流VPS-' || sys='容器NIX-'
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "部署环境：${sys}3x UI面板 自动启动脚本"
echo "当前时间：$(date)"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# 设置默认路径
mkdir -p ~/3xpanel
panel_dir=~/3xpanel

# 判断是否已经安装
if [[ -f "$panel_dir/start.sh" ]]; then
  echo "3x UI 面板已安装，尝试重启面板..."
  nohup bash "$panel_dir/start.sh" > /dev/null 2>&1 &
  exit 0
fi

# 下载并安装 3x UI 面板（请根据你实际使用的3x UI项目调整）
echo "开始安装 3x UI 面板..."
cd "$panel_dir"
git clone https://github.com/MHSanaei/3x-ui.git . || {
  echo "下载失败，请检查网络或更换源"
  exit 1
}
chmod +x install.sh
bash install.sh

# 开机自动启动设置（适用于 Firebase Studio 容器环境）
if [[ "$HOSTNAME" == *firebase* || "$HOSTNAME" == *idx* ]]; then
  [ -f ~/.bashrc ] || touch ~/.bashrc
  sed -i '/3xpanel\/start.sh/d' ~/.bashrc
  echo 'nohup bash ~/3xpanel/start.sh > /dev/null 2>&1 &' >> ~/.bashrc
  source ~/.bashrc
  echo "已配置 bashrc 开机自动启动"
fi

# 启动面板
echo "启动 3x UI 面板..."
nohup bash "$panel_dir/start.sh" > /dev/null 2>&1 &
