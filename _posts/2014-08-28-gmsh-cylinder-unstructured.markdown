---
layout: post
title: "gmsh-Flow past circular cylinder, unstructure mesh"
categories:
- tech
tags:
- gmsh


---

这里用gmsh做了一个用于OpenFOAM模拟圆柱扰流的网格, 流场外边界是与
圆柱同心的一个圆。要注意的是创建圆弧时，弧度要*小于Pi*, 所以一个圆
最好用4个1/4圆弧来画，而不能用两个半圆弧来画。

`circular-cylinder.geo`:

```
// Gmsh project created on Thu Aug 28 07:48:53 2014

R = 0.4;
r = 0.1512;

cz1 = 0.01;
cz2 = 0.02;

Point(1) = {0, 0, 0, cz1};

Point(2) = { 0,  r, 0, cz1};
Point(3) = {-r,  0, 0, cz1};
Point(4) = { 0, -r, 0, cz1};
Point(5) = { r,  0, 0, cz1};

Point(6) = { 0,  R, 0, cz2};
Point(7) = {-R,  0, 0, cz2};
Point(8) = { 0, -R, 0, cz2};
Point(9) = { R,  0, 0, cz2};

Circle(10) = {2,1,3};
Circle(11) = {3,1,4};
Circle(12) = {4,1,5};
Circle(13) = {5,1,2};

Circle(14) = {6,1,7};
Circle(15) = {7,1,8};
Circle(16) = {8,1,9};
Circle(17) = {9,1,6};

Line Loop(18) = {10, 11, 12, 13};
Line Loop(19) = {14, 15, 16, 17};

Plane Surface(20) = {19, 18};

Extrude {0, 0, 0.01} {
  Surface{20};
  Layers{1};
  Recombine;
}

Physical Volume("flowDomain") = {1}; //这一行不能少！！
Physical Surface("cylinderWall") = {61, 57, 53, 49};
Physical Surface("freeStream") = {33, 37, 41, 45};
Physical Surface("frontAndBack") = {62, 20};

Mesh 3;  // Meshing
Save "circularCylinder.msh" //Save the mesh
```
