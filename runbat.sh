#!/bin/bash
export LANG=en_US.UTF-8
export nix=${nix:-''}
panel_dir=~/3xpanel
panel_port=6689

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "部署环境：${nix:+容器NIX-}3x UI面板 非root免安装版"
echo "当前时间：$(date)"
echo "安装路径：$panel_dir"
echo "运行端口：$panel_port"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# 创建目录
mkdir -p "$panel_dir"
cd "$panel_dir" || exit

# 检查是否已存在可执行文件
if [[ -f "$panel_dir/3x-ui" ]]; then
  echo "3x-ui 已安装，直接启动..."
else
  echo "下载最新 3x-ui release..."
  arch=$(uname -m)
  if [[ "$arch" == "x86_64" ]]; then
    arch="amd64"
  elif [[ "$arch" == "aarch64" ]]; then
    arch="arm64"
  else
    echo "不支持的架构: $arch"
    exit 1
  fi

  version=$(curl -s https://api.github.com/repos/MHSanaei/3x-ui/releases/latest | grep tag_name | cut -d '"' -f4)
  wget -qO 3x-ui-linux.tar.gz "https://github.com/MHSanaei/3x-ui/releases/download/$version/3x-ui-linux-$arch.tar.gz"
  tar -xzf 3x-ui-linux.tar.gz
  rm -f 3x-ui-linux.tar.gz
  chmod +x 3x-ui
  echo "下载并解压完成：3x-ui $version ($arch)"
fi

# 创建默认数据库和配置文件（如果不存在）
if [[ ! -f "$panel_dir/db.sqlite" ]]; then
  echo "初始化 3x-ui 数据库..."
  ./3x-ui migrate
  ./3x-ui users add --username admin --password admin123 --email admin@local
  echo "默认账户：admin / admin123"
fi

# 写入 .bashrc 自动启动
if [[ "$HOSTNAME" == *firebase* || "$HOSTNAME" == *idx* || -n "$nix" ]]; then
  [ -f ~/.bashrc ] || touch ~/.bashrc
  sed -i '/3xpanel\/3x-ui/d' ~/.bashrc
  echo "nohup ~/3xpanel/3x-ui run --port $panel_port > /dev/null 2>&1 &" >> ~/.bashrc
  source ~/.bashrc
  echo "已设置 .bashrc 自启"
fi

# 启动服务
echo "正在启动 3x-ui 面板..."
nohup "$panel_dir/3x-ui" run --port "$panel_port" > /dev/null 2>&1 &

echo
echo "✅ 安装完成！请使用以下信息登录面板："
echo "-------------------------------------------------"
echo "地址： http://<你的Firebase外网地址>:$panel_port"
echo "账户： admin"
echo "密码： admin123"
echo "（首次登录后请及时修改密码）"
echo "-------------------------------------------------"
