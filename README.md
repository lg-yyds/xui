# XUI安装 / 升级命令

```shell
wget -N --no-check-certificate https://raw.githubusercontents.com/lg-yyds/xui/main/install.sh && bash install.sh
```


# linux一键dd脚本支持Debian 9/10/11、Ubuntu 16.04/18.04/20.04、CentOS 7/8、RockyLinux 8和AlmaLinux 8系统的网络重装，自动适配境内境外系统源，适用于 GigsGigsCloud、AkkoCloud、GreenCloud、Virmach和腾讯云等vps和云服务器。

本次更新：

增加CentoS 8、RockyLinux 8、AlmaLinux 8、Fedora 32+、Ubuntu 20.04下运行的支持； 新增dd RockyLinux 8、AlmaLinux 8。 本次更新在测试 腾讯云轻量1C2G配置中测试可用。

使用命令：
```shell
wget -N --no-check-certificate https://raw.githubusercontents.com/lg-yyds/xui/main/network-reinstall-os.sh && chmod +x network-reinstall-os.sh && ./network-reinstall-os.sh
```
输出如下：

##############################################################


Network reinstall OS

Last Modified: 2023-04-16

Linux默认密码：reinstallOS

Supported by reinstallOS


##############################################################

IP: XXX.XXX.XXX.XXX/24 网关: 173.230.137.1 网络掩码: 255.255.255.0

请选择您需要的镜像包:

0) 升级本脚本
1) Debian 9（Stretch） 用户名：root 密码：reinstallOS
2) Debian 10（Buster） 用户名：root 密码：reinstallOS
3) Debian 11（Bullseye）用户名：root 密码：reinstallOS ,推荐1G内存以上使用
4) CentOS 7 x64 (DD) 用户名：root 密码：Pwd@CentOS
5) CentOS 8 x64 (DD) 用户名：root 密码：cxthhhhh.com 推荐512M内存以上使用
6) CentOS 7 用户名：root 密码：reinstallOS, 要求2G RAM以上才能使用
7) CentOS 8 (EFI 引导) 用户名：root 密码：reinstallOS, 要求2G RAM以上才能使用
8) Ubuntu 16.04 LTS (Xenial Xerus) 用户名：root 密码：reinstallOS
9) Ubuntu 18.04 LTS (Bionic Beaver) 用户名：root 密码：reinstallOS
10) Ubuntu 20.04 LTS (Focal Fossa) 用户名：root 密码：reinstallOS ,推荐2G内存以上使用
11) Fedora 32 用户名：root 密码：reinstallOS, 要求2G RAM以上才能使用
12) Fedora 33 用户名：root 密码：reinstallOS, 要求2G RAM以上才能使用
13) Fedora 34 用户名：root 密码：reinstallOS, 要求2G RAM以上才能使用
14) Fedora 35 用户名：root 密码：reinstallOS, 要求2G RAM以上才能使用
15) RockyLinux 8 用户名：root 密码：reinstallOS, 要求2G RAM以上才能使用
16) AlmaLinux 8 用户名：root 密码：reinstallOS, 要求2G RAM以上才能使用



自定义安装请使用：bash network-reinstall.sh -dd '您的直连'
