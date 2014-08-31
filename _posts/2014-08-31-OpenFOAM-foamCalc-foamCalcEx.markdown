---
layout: post
title: "OpenFOAM foamCalc and foamCalcEx"
categories:
- tech
tags:
- OpenFOAM


---

Links

*   [foamCalc](ihttp://www.openfoam.org/docs/user/cavity.php#dx5-24001)
*   [foamCalcEx wiki](http://openfoamwiki.net/index.php/Contrib_foamCalcEx)

官方的OpenFOAM提供的unities 中的foamCalc可以完成一些常见的后处理计算:
```
8
(
addSubtract
components
div
interpolate
mag
magGrad
magSqr
randomise
)
```
社区提供的foamCalcEx，功能跟多一点：
```
20
(
addSubtract
average
cellMinMax
components
curl
div
grad
interpolate
laplacian
mag
magGrad
magSqr
max
min
minMax
minMaxMag
multiplyDivide
randomise
smooth
volIntegrate
)
```

这里举个例子说明foamCalcEx中multipyDivede的使用，把0/U乘以3，生成一个新的场：

    foamCalcEx multiplyDivide U multiply -value 3/U -time 0

这样会在0/里面生成一个U_multiplyed文件。
