---
layout: post
title: "CentOS OpenFOAM openmpi set up"
categories:
- tech
tags:
- OpenFOAM


---
The official OpenFOAM does not supprt CentOS 5.x and 6.4.

When running xxxFoam solvers with mpi, the error message below pop up:

```
It looks like opal_init failed for some reason; your parallel process is
likely to abort. There are many reasons that a parallel process can
fail during opal_init; some of which are due to configuration or
environment problems. This failure appears to be an internal failure;
here's some additional information (which may only be relevant to an
Open MPI developer):
opal_shmem_base_select failed
--> Returned value -1 instead of OPAL_SUCCESS
```

I found the answer in cfd-online [here](http://www.cfd-online.com/Forums/openfoam/117893-problem-running-openfoam-2-2-x-parallel-centos-5-a.html#6). 

```
rm -rf $FOAM_EXT_LIBBIN/../../linux64Gcc/openmpi-1.6.3
cd $FOAM_INST_DIR/ThirdParty-2.2.x
./Allwmake

cd $FOAM_SRC/Pstream/dummy
wclean
cd ../mpi
wclean
cd ..
./Allwmake
```

At least it works in my centFOAM 2.2.x on CentOS 5.8.
