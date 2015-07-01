---
layout: post
title: "安装PGI workstation 版本"
categories:
- tech
tags:
- cuda

---


我的计算BGK-Boltzmann方程的MPI Fortran code终于调通了，下一步是把计算核心换成CUDA的。
目前算一个40^3*20^3 （物理空间40^3的网格，速度空间28^3的网格） 的算例，需要用到内存约：40^3*28^3*2*8/2^30 = 20.9351GB. 必须得上多GPU。
但是等我写完MPI的Fortran code，才发现原来支持CUDA的编译器只有PGI一家，而且被Nvidia收购。并且目前不免费，试用期只有15天。
给Nvidia发邮件要到了PGI的 trail license （PGI的主页这几天 unavailable ...）,可以用到9月15号。
顺利装到学校机群上。发现把优化选项一开，PGI编译出的Fortran程序还是挺快的，跟intel的有得一拼。
但是发现这货自带的MPICH3怎么比学校的openmp-intel慢通信延迟慢好多。

那换成openmpi怎么样？搜来搜索发现，我只能用PGI CDK (Cluster Develop Toolkit), 这里面自带一套PGI编译的openMPI.


下面这里只记录PGI workstation version的安装过程：

    ####################################################
    # PGI 14.7 安装方法，总结自 PGI Installation Guide, Version2014
    # Lianhua Zhu, <zhulianhua121@gmail.com>
    ####################################################



    # 创建解压目录
    mkidr /tmp/pgi
    mv /home/lhzhu/pgilinux-2014-147-x86_64.tar.gz  /tmp/pgi
    cd /tmp/pgi
    tar xpfz pgilinux-2014-147-x86_64.tar.gz


    # 开始安装
    sudo ./install.sh
    # 默认安装在/opt/pgi下
    # 当问是否让安装目录之可写时，选否。即保证 /opt/pgi下面的东西可写。
    # 安装过程中选择安装如下组建
    # ACML math library
    # NVIDIA CUDA components
    # MPICH library ，这个只会安装在 /opt/pgi下面，不会与集群已有的 MPI环境冲突。


    #安装很快就完了，设置环境变量 ,根据实际安装位置替换/opt/pgi：
    export PGI=/opt/pgi;
    export PATH=/opt/pgi/linux86-64/14.7/bin:$PATH;
    export MANPATH=$MANPATH:/opt/pgi/linux86-64/14.7/man;
    export LM_LICENSE_FILE=$LM_LICENSE_FILE:/opt/pgi/license.dat;

    #验证安装正确与否：
    pgfortran –V

    #输出如下信息就代表安装 OK
    #pgfortran 14.7-0 64-bit target on x86-64 Linux -tp sandybridge
    #The Portland Group - PGI Compilers and Tools
    #Copyright (c) 2014, NVIDIA CORPORATION.  All rights reserved.

    #设置license ：
    cp /home/lhzhu/license.dat $PGI/license.dat
    sudo sed –i 27s/6/7/  $PGI/linux86-64/14.7/bin/lmgrd.rc
    $PGI/linux86-64/14.7/bin/lmgrd.rc start
    #设置 reboot之后自动启动license manger:


    #root登录：
    sudo cp $PGI/linux86-64 /14.7/bin/lmgrd.rc /etc/init.d/lmgrd
    sudo ln -s /etc/init.d/lmgrd /etc/rc.d/rc3.d/S90lmgrd
