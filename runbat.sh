#!/bin/bash
export LANG=en_US.UTF-8
export nix=${nix:-''}
[ -z "$nix" ] && sys='主流VPS-' || sys='容器NIX-'
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " 宝塔面板一键安装 + 自启动脚本"
echo " 当前模式：${sys}"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# 判断是否已安装宝塔
bt_installed() {
    command -v bt >/dev/null 2>&1 && [ -d "/www/server/panel" ]
}

# VPS模式下的开机自启：使用 @reboot crontab
enable_autostart_vps() {
    crontab -l > /tmp/crontab.bt || true
    sed -i '/bt start/d' /tmp/crontab.bt
    echo '@reboot /etc/init.d/bt start' >> /tmp/crontab.bt
    crontab /tmp/crontab.bt
    rm /tmp/crontab.bt
}

# NIX（容器）模式下的开机自启：通过 bashrc
enable_autostart_nix() {
    [ -f ~/.bashrc ] || touch ~/.bashrc
    sed -i '/bt start/d' ~/.bashrc
    echo 'command -v bt >/dev/null 2>&1 && bt start' >> ~/.bashrc
}

# 宝塔安装
install_bt() {
    echo "开始安装宝塔面板..."
    if [ -f /etc/redhat-release ]; then
        yum install -y wget && yum update -y
        curl -sSO http://download.bt.cn/install/install_6.0.sh
        bash install_6.0.sh
    elif grep -i -E "debian|ubuntu" /etc/issue >/dev/null 2>&1 || grep -i -E "debian|ubuntu" /etc/os-release >/dev/null 2>&1; then
        apt update -y && apt install -y wget
        curl -sSO http://download.bt.cn/install/install-ubuntu_6.0.sh
        bash install-ubuntu_6.0.sh
    else
        echo "暂不支持的系统，请使用CentOS、Ubuntu或Debian" && exit 1
    fi
}

# 主流程
if bt_installed; then
    echo "宝塔面板已安装，尝试配置自启动..."
else
    install_bt
fi

if [ -z "$nix" ]; then
    enable_autostart_vps
    echo "VPS模式：已设置 crontab @reboot 启动宝塔"
else
    enable_autostart_nix
    echo "NIX容器模式：已写入 ~/.bashrc 自动启动宝塔"
fi

echo "完成。你可以使用 bt 命令查看宝塔状态。"
