---
layout: post
title: "OpenFOAM 自定义边界条件类型"
categories:
- kuoyan
tags:
- OpenFOAM

---

主要参考：[openfoamwiki](http://openfoamwiki.net/index.php/HowTo_Adding_a_new_boundary_condition)
和[http://www.cfd-online.com/Forums/openfoam/72434-custom-boundary-condition-openfoam.html]

上面链接里面的wiki里面说得很清楚： Make/files 里面，源文件名后面的s不能丢，结果我就是在
这个地方没注意，害我折腾好久，编译的时候老出现 `error: redefinition of ‘Foam` 的错误。
