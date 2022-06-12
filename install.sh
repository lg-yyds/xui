#!/bin/bash

red() {
    echo -e "\033[31m\033[01m$1\033[0m"
}

green() {
    echo -e "\033[32m\033[01m$1\033[0m"
}

yellow() {
    echo -e "\033[33m\033[01m$1\033[0m"
}

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN="\033[0m"

REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS")
PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install")
PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove")

[[ $EUID -ne 0 ]] && red "请在root用户下运行脚本" && exit 1

CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')")

for i in "${CMD[@]}"; do
    SYS="$i" && [[ -n $SYS ]] && break
done

for ((int = 0; int < ${#REGEX[@]}; int++)); do
    [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && [[ -n $SYSTEM ]] && break
done

[[ -z $SYSTEM ]] && red "不支持当前VPS系统，请使用主流的操作系统" && exit 1

arch=$(arch)
os_version=$(grep -i version_id /etc/os-release | cut -d \" -f2 | cut -d . -f1)

if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
    arch="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64"
elif [[ $arch == "s390x" ]]; then
    arch="s390x"
else
    echo -e "不支持的CPU架构！脚本将自动退出！"
    rm -f install.sh
    exit 1
fi

if [ $(getconf WORD_BIT) != '32' ] && [ $(getconf LONG_BIT) != '64' ]; then
    echo "目前x-ui面板不支持 32 位系统(x86)，请使用 64 位系统(x86_64)，如果检测有误，请联系作者"
    rm -f install.sh
    exit -1
fi

if [[ $SYSTEM == "CentOS" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "请使用 CentOS 7 或更高版本的系统！\n" && exit 1
    fi
elif [[ $SYSTEM == "Ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "请使用 Ubuntu 16 或更高版本的系统！\n" && exit 1
    fi
elif [[ $SYSTEM == "Debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "请使用 Debian 8 或更高版本的系统！\n" && exit 1
    fi
fi

${PACKAGE_UPDATE[int]}
[[ -z $(type -P curl) ]] && ${PACKAGE_INSTALL[int]} curl
[[ -z $(type -P tar) ]] && ${PACKAGE_INSTALL[int]} tar

checkCentOS8(){
    if [[ -n $(cat /etc/os-release | grep "CentOS Linux 8") ]]; then
        yellow "检测到当前VPS系统为CentOS 8，是否升级为CentOS Stream 8以确保软件包正常安装？"
        read -rp "请输入选项 [y/n]：" comfirm
        if [[ $comfirm == "y" ]]; then
            yellow "正在为你升级到CentOS Stream 8，大概需要10-30分钟的时间"
            sleep 1
            sed -i -e "s|releasever|releasever-stream|g" /etc/yum.repos.d/CentOS-*
            yum clean all && yum makecache
            dnf swap centos-linux-repos centos-stream-repos distro-sync -y
        else
            red "已取消升级过程，脚本即将退出！"
            exit 1
        fi
    fi
}

config_after_install() {
    read -rp "请设置您的账户名 [默认admin]：" config_account
    if [[ -z $config_account ]]; then
        config_account="admin"
    fi
    read -rp "请设置您的账户密码 [默认admin]：" config_password
    if [[ -z $config_password ]]; then
        config_password="admin"
    fi
    read -rp "请设置面板访问端口 [默认54321]：" config_port
    if [[ -z $config_port ]]; then
        config_port=54321
    fi
    /usr/local/x-ui/x-ui setting -username ${config_account} -password ${config_password}
    /usr/local/x-ui/x-ui setting -port ${config_port}
}

show_login_address(){
    WgcfIPv4Status=$(curl -s4m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
    WgcfIPv6Status=$(curl -s6m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
    if [[ $WgcfIPv4Status =~ "on"|"plus" ]] || [[ $WgcfIPv6Status =~ "on"|"plus" ]]; then
        wg-quick down wgcf >/dev/null 2>&1
        v66=`curl -s6m8 https://ip.gs -k`
        v44=`curl -s4m8 https://ip.gs -k`
        wg-quick up wgcf >/dev/null 2>&1
    else
        v66=`curl -s6m8 https://ip.gs -k`
        v44=`curl -s4m8 https://ip.gs -k`
    fi
    if [[ -n $v44 && -z $v66 ]]; then
        echo -e "面板IPv4登录地址为：${GREEN}http://$v44:$config_port ${PLAIN}"
    elif [[ -n $v66 && -z $v44 ]]; then
        echo -e "面板IPv6登录地址为：${GREEN}http://[$v66]:$config_port ${PLAIN}"
    elif [[ -n $v44 && -n $v66 ]]; then
        echo -e "面板IPv4登录地址为：${GREEN}http://$v44:$config_port ${PLAIN}"
        echo -e "面板IPv6登录地址为：${GREEN}http://[$v66]:$config_port ${PLAIN}"
    fi
}

install_x-ui() {
    systemctl stop x-ui
    if [ $# == 0 ]; then
        last_version=$(curl -Ls "https://api.github.com/repos/lg-yyds/xui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            red "检测 x-ui 版本失败，可能是超出 Github API 限制，请稍后再试，或手动指定 x-ui 版本安装"
            rm -f install.sh
            exit 1
        fi
        yellow "检测到 x-ui 最新版本：${last_version}，开始安装"
        wget -N --no-check-certificate -O /usr/local/x-ui-linux-${arch}.tar.gz https://github.com/lg-yyds/xui/releases/download/${last_version}/x-ui-linux-${arch}.tar.gz
        if [[ $? -ne 0 ]]; then
            red "下载 x-ui 失败，请确保你的服务器能够连接并下载 Github 的文件"
            rm -f install.sh
            exit 1
        fi
    else
        last_version=$1
        url="https://github.com/lg-yyds/xui/releases/download/${last_version}/x-ui-linux-${arch}.tar.gz"
        yellow "开始安装 x-ui v$1"
        wget -N --no-check-certificate -O /usr/local/x-ui-linux-${arch}.tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            red "下载 x-ui v$1 失败，请确保此版本存在"
            rm -f install.sh
            exit 1
        fi
    fi
    if [[ -e /usr/local/x-ui/ ]]; then
        rm -rf /usr/local/x-ui/
    fi
    cd /usr/local/
    tar zxvf x-ui-linux-${arch}.tar.gz
    rm x-ui-linux-${arch}.tar.gz -f
    cd x-ui
    chmod +x x-ui bin/xray-linux-${arch}
    cp -f x-ui.service /etc/systemd/system/
    wget --no-check-certificate -O /usr/bin/x-ui https://raw.githubusercontents.com/lg-yyds/xui/main/x-ui.sh
    chmod +x /usr/local/x-ui/x-ui.sh
    chmod +x /usr/bin/x-ui
    config_after_install
    systemctl daemon-reload
    systemctl enable x-ui
    systemctl start x-ui
    cd /root
    rm -f install.sh
    green "x-ui v${last_version} 安装完成，面板已启动"
    echo -e ""
    echo -e "x-ui 管理脚本使用方法: "
    echo -e "----------------------------------------------"
    echo -e "x-ui              - 显示管理菜单 (功能更多)"
    echo -e "x-ui start        - 启动 x-ui 面板"
    echo -e "x-ui stop         - 停止 x-ui 面板"
    echo -e "x-ui restart      - 重启 x-ui 面板"
    echo -e "x-ui status       - 查看 x-ui 状态"
    echo -e "x-ui enable       - 设置 x-ui 开机自启"
    echo -e "x-ui disable      - 取消 x-ui 开机自启"
    echo -e "x-ui log          - 查看 x-ui 日志"
    echo -e "x-ui v2-ui        - 迁移本机器的 v2-ui 账号数据至 x-ui"
    echo -e "x-ui update       - 更新 x-ui 面板"
    echo -e "x-ui install      - 安装 x-ui 面板"
    echo -e "x-ui uninstall    - 卸载 x-ui 面板"
    echo -e "----------------------------------------------"
    echo -e ""
    show_login_address
}

checkCentOS8
install_x-ui $1
