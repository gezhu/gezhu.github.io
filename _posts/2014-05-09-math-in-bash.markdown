---
layout: post
title: "Bash 中的数学计算"
categories:
- tech
tags:
- bash
- linux


----

主要参考[这里](https://www.shell-tips.com/2010/06/14/performing-math-calculation-in-bash/)

整型数操作
==========

* 可以使用`expr`语句

        $expr 1 + 1
        2
        $myvar=$(expr 1 + 1)
        2
        $expr $myvar + 1
        3
        $expr $myvar / 3
        1
        $expr $myvar \* 3
        9

* 也可以使用圆括号或中括号

        $echo $myvar
        3
        $echo $((myvar+2))
        5
        $echo $[myvar+2]
        

浮点数计算
=========
需要借助其他程序，这里用介绍`bc`, `bc`是linux上一个任意精度
的计算程序。

        $ bc -l
        bc 1.06.95
        Copyright 1991-1994, 1997, 1998, 2000, 2004, 2006 Free Software Foundation, Inc.
        This is free software with ABSOLUTELY NO WARRANTY.
        For details type `warranty'.
        1/3
        0
        1.0/3
        0
        scale=4
        1.0/3
        .3333
        scale=6
        1.0/3
        .333333
        1+sqrt(3.0)
        2.732050


注意使用`bc`的内部环境变量`scale`改变默认的精度。如果启动`bc`是使用`-l`选项，可以加载数学库，默认为双精度。

        $ bc -l
        bc 1.06.95
        Copyright 1991-1994, 1997, 1998, 2000, 2004, 2006 Free Software Foundation, Inc.
        This is free software with ABSOLUTELY NO WARRANTY.
        For details type `warranty'.
        1/3.0
        .33333333333333333333
        scale=4
        1/3
        .3333

结合shell的管道操作可以方便的在shell语句用使用`bc`:

        $ echo "scale=2; 2/3" | bc
        0.66
        $ echo "scale=6;(2/3)+(7/8)" | bc
        1.541666
        echo "(2/3)+(7/8)" | bc -l
        1.54166666666666666666
        $  bc -l <<< "(2/3)+(7/8)"
        1.54166666666666666666
