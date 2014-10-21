---
layout: post
title: "tecplot scripts"
categories:
- tech
tags:
- tecplot

---

Load data files
---------------

    $!READDATASET  '"Y:\OpenFOAM\lhzhu-2.3.0\run\myCases\cavity\Kn1Xi120\Tecplot360\Kn1Xi120_grid_0.plt" "Y:\OpenFOAM\lhzhu-2.3.0\run\myCases\cavity\Kn1Xi120\Tecplot360\Kn1Xi120_0.plt" '
    READDATAOPTION = NEW
    RESETSTYLE = YES
    INCLUDETEXT = NO
    INCLUDEGEOM = NO
    INCLUDECUSTOMLABELS = NO
    VARLOADMODE = BYNAME
    ASSIGNSTRANDIDS = YES
    INITIALPLOTTYPE = CARTESIAN2D
    VARNAMELIST = '"X" "Y" "Z" "T" "rho" "q_x" "q_y" "q_z" "U_x" "U_y" "U_z"'

Alter and Create dataset
------------------------
    
    $!ALTERDATA 
    EQUATION = '{Tr}=273.0*{T}'


Contours
---------------
Create contour and set contour levels

    $!FIELDLAYERS SHOWCONTOUR = YES
    $!GLOBALCONTOUR 1  VAR = 12
    $!CONTOURLEVELS NEW
      CONTOURGROUP = 1
      RAWDATA
    11
    271.6
    272
    272.4
    272.8
    273.2
    273.6
    274
    274.4
    274.8
    275.2
    275.6

Frame operatoin
---------------
Create new frame

    $!CREATENEWFRAME 
      XYPOS
        {
        X = 1.7495
        Y = 1.1542
        }
      WIDTH = 3.472
      HEIGHT = 3.4286

Transprant

    $!FRAMELAYOUT ISTRANSPARENT = YES

Frame link

    $!LINKING BETWEENFRAMES{LINKFRAMESIZEANDPOSITION = YES}
    $!LINKING BETWEENFRAMES{LINKXAXISRANGE = YES}
    $!LINKING BETWEENFRAMES{LINKYAXISRANGE = YES}
    $!LINKING BETWEENFRAMES{LINKAXISPOSITION = YES}
    $!LINKING BETWEENFRAMES{LINKCONTOURLEVELS = YES}
    $!REDRAWALL 
    $!PROPAGATELINKING 
      LINKTYPE = BETWEENFRAMES
      FRAMECOLLECTION = ALL

Frame control

    $!FRAMECONTROL ACTIVATEPREVIOUS

Frame rename

    $!FRAMENAME = "DSMC"

Frame resize

    $!FRAMELAYOUT WIDTH = 8
    $!FRAMELAYOUT HEIGHT = 8

Axis  edit
----------
Ticks

    $!TWODAXIS XDETAIL{RANGEMAX = 1}
    $!TWODAXIS YDETAIL{RANGEMAX = 1}
    $!TWODAXIS XDETAIL{TICKS{TICKDIRECTION = OUT}

Area
    
    $!TWODAXIS VIEWPORTPOSITION{X2 = 94}
    $!TWODAXIS VIEWPORTPOSITION{Y2 = 94

Grid Board Line

    $!TWODAXIS GRIDAREA{DRAWBORDER = YES}


Export 
------
Export to eps

    $!EXPORTSETUP EXPORTFORMAT = EPS
    $!EXPORTSETUP IMAGEWIDTH = 1050
    $!EXPORTSETUP EXPORTFNAME = 'G:\3rd\cavity\export.eps'
    $!EXPORT 
      EXPORTREGION = CURRENTFRAM
