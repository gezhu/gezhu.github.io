---
layout: post
title: " Install PPTP VPN On Centos 7"
categories:
- tech
tags:
- vpn

---
被逼得没办法了，自己掏银子搭建"科学上网"工具。买的是DO的vps, 最便宜的那种，$5每月，用的是paypal绑定银联卡支付的。 选的三藩市的机房，之前选的新加坡太不稳定了。
vps上我装的是CentOS 7。下面这个是安装并配置vpn服务器(pptpd)的脚本:

    rpm -Uvh http://download.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-1.noarch.rpm
    yum -y install ppp pptpd

    cp /etc/pptpd.conf /etc/pptpd.conf.bak
    cat >/etc/pptpd.conf<<EOF
    option /etc/ppp/options.pptpd
    logwtmp
    localip 10.0.10.1
    remoteip 10.0.10.2-254
    EOF

    cp /etc/ppp/options.pptpd /etc/ppp/options.pptpd.bak
    cat >/etc/ppp/options.pptpd<<EOF
    name pptpd
    refuse-pap
    refuse-chap
    refuse-mschap
    require-mschap-v2
    require-mppe-128
    proxyarp
    lock
    nobsdcomp
    novj
    novjccomp
    nologfd
    ms-dns 8.8.8.8
    ms-dns 8.8.4.4
    EOF

    cp /etc/ppp/chap-secrets /etc/ppp/chap-secrets.bak
    cat >/etc/ppp/chap-secrets<<EOF
    USERNAME pptpd PASSWORD *
    EOF

    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    cat >/etc/sysctl.conf<<EOF
    net.core.wmem_max = 12582912
    net.core.rmem_max = 12582912
    net.ipv4.tcp_rmem = 10240 87380 12582912
    net.ipv4.tcp_wmem = 10240 87380 12582912
    net.core.wmem_max = 12582912
    net.core.rmem_max = 12582912
    net.ipv4.tcp_rmem = 10240 87380 12582912
    net.ipv4.tcp_wmem = 10240 87380 12582912
    net.core.wmem_max = 12582912
    net.core.rmem_max = 12582912
    net.ipv4.tcp_rmem = 10240 87380 12582912
    net.ipv4.tcp_wmem = 10240 87380 12582912
    net.ipv4.ip_forward = 1
    EOF
    sysctl -p


    chmod +x /etc/rc.d/rc.local
    echo "iptables -t nat -A POSTROUTING -s 10.0.10.0/24 -o eth0 -j MASQUERADE" >> /etc/rc.d/rc.local
    iptables -t nat -A POSTROUTING -s 10.0.10.0/24 -o eth0 -j MASQUERADE

    systemctl start pptpd
    systemctl enable pptpd.service

有两个问题需要注意下：

*   上面脚本中的 ''/etc/ppp/chap-secrets''文件里面的USERNAME 和 PASSWORD要换成自己设置的vpn用户名和密码。
*   注意iptable访问控制里要设置相关的端口打开。
