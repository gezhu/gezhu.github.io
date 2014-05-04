---
layout: post
title: "Fortran 内建函数"
categories:
- tech
tags:
- fortran


---

* `SIGN(X1, X2)` :`(REAL, REAL) -> REAL)` 取`X1`的绝对值与`X2`的符号组合, 
   如`SIGN(1.0, -3.0)`返回`-1.0`, 若`X2=0`, 则等效于`SIGN(X1,1)`, 对应的双精度为`DSIGN`



-----

