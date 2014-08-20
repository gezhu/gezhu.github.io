---
layout: post
title: "OpenFOAM 自定义边界条件类型"
categories:
- kuoyan
tags:
- OpenFOAM

---

主要参考：[openfoamwiki](http://openfoamwiki.net/index.php/HowTo_Adding_a_new_boundary_condition)
和[CFD-online](http://www.cfd-online.com/Forums/openfoam/72434-custom-boundary-condition-openfoam.html)

上面wiki链接里面说得很清楚： Make/files 里面，源文件名后面的s不能丢。结果我就是在
这个地方没注意，害我折腾好久，编译的时候老出现 `error: redefinition of 'Foam...` 的错误。

使用自定义的新B.C.有两种方式:

* 把新B.C.嵌入到solver里面，编写solver的code的时候，直接包含将该B.C.的所有头文件.
* 把新B.C. 编译成一个动态链接库，在case 目录的system/controlDict里面是使用libs关键字调用这个动态链接库

无论哪种方式，首先要从一个现成的B.C.类型开始改.
