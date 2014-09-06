---
layout: post
title: "OpenFOAM funkySetFields"
categories:
- tech
tags:
- OpenFOAM

---

Dict File `system/funkySetFieldsDict`

Examples:

```
/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  2.2.1                                 |
|   \\  /    A nd           | Web:      www.OpenFOAM.org                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    location    "system";
    object      funkySetFieldsDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

expressions
(
    UField
    {
        variables
        (
            "Ri=0.1512e-6;"
            "Ro=0.6e-6;"
            "r=mag(vector(pos().x, pos().y, 0));"
            "U0=877.7073637014773;"
            "cs=pos().x/r;"
            "ss=pos().y/r;"
            "vr= U0*(1-Ri*Ri/r/r)*cs;"
            "vs=-U0*(1+Ri*Ri/r/r)*ss;"
            "vx=vr*cs-vs*ss;"
            "vy=vr*ss+vs*cs;"
        );
        field U;
        expression "vector(vx, vy, 0)";
    }
);
```
