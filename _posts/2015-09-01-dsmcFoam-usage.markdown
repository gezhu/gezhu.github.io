---
layout: post
title: "dsmcFoam solver 分析"
categories:
- Research
tags:
- OpenFOAM

---


###dsmcFoam solver分析

分析这个solver的主要目的是弄清楚我用这个solver算热驱方腔流动问题为何速度场老是计算得有很大的噪音。即使统计了很长时间。我需要弄清楚这里面的场是如何平均的。

dsmcFoam 的架构：


主要的源文件：

*    `dsmcFoam.C` : https://github.com/OpenFOAM/OpenFOAM-2.3.x/blob/master/applications/solvers/discreteMethods/dsmc/dsmcFoam/dsmcFoam.C 
* `DsmcCloud.C` :  https://github.com/OpenFOAM/OpenFOAM-2.3.x/blob/master/src/lagrangian/dsmc/clouds/Templates/DsmcCloud/DsmcCloud.C
*    `DsmcCloud.H` :  https://github.com/OpenFOAM/OpenFOAM-2.3.x/blob/master/src/lagrangian/dsmc/clouds/Templates/DsmcCloud/DsmcCloud.H
*    `dsmcFields` function object : https://github.com/OpenFOAM/OpenFOAM-2.3.x/tree/master/src/postProcessing/functionObjects/utilities/dsmcFields


####`dsmcFoma` 源码：

```
int main(int argc, char *argv[])
{
    #include "setRootCase.H"
    #include "createTime.H"
    #include "createMesh.H"

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

    Info<< nl << "Constructing dsmcCloud " << endl;

    dsmcCloud dsmc("dsmc", mesh);

    Info<< "\nStarting time loop\n" << endl;

    while (runTime.loop())
    {
        Info<< "Time = " << runTime.timeName() << nl << endl;

        dsmc.evolve(); //<<------ 这里是演化步
        dsmc.info();  //<<------ dump到屏幕一些基本信息
        runTime.write(); //<<------- 这里很关键，到底写的是什么

        Info<< nl << "ExecutionTime = " << runTime.elapsedCpuTime() << " s"
            << "  ClockTime = " << runTime.elapsedClockTime() << " s"
            << nl << endl;
    }

    Info<< "End\n" << endl;

    return(0);
}
```

#### DsmcCloud 关键函数分析

`DsmcCloud::evolve()` 主要演化过程在这里

```
template<class ParcelType>
void Foam::DsmcCloud<ParcelType>::evolve()
{
    typename ParcelType::trackingData td(*this);

    // Reset the data collection fields
    resetFields();  //<<------ 每个演化步都需要重置 rhoN_ rhoM_ linearKE_ ... 等等这些场为0；

    if (debug)
    {
        this->dumpParticlePositions();
    }

    // Insert new particles from the inflow boundary
    this->inflowBoundary().inflow();  //<<------ 处理边界

    // Move the particles ballistically with their current velocities
    Cloud<ParcelType>::move(td, mesh_.time().deltaTValue()); //<<------ 自由迁移，得到particle新的位置

    // Update cell occupancy
    buildCellOccupancy(); //<<-------

    // Calculate new velocities via stochastic collisions
    collisions(); //<<------ 碰撞处理，得到particle新的速度

    // Calculate the volume field data
    calculateFields(); //<<------每个演化步都需要统计 rhoN_ rhoM_ linearKE_ ... 等等这些场为；
}
```

`DsmcCloud::resetFields()` 每个演化步都需要重置这些场为0，为开始统计做准备

```
template<class ParcelType>
void Foam::DsmcCloud<ParcelType>::resetFields()
{
    q_ = dimensionedScalar("zero",  dimensionSet(1, 0, -3, 0, 0), 0.0);

    fD_ = dimensionedVector
    (
        "zero",
        dimensionSet(1, -1, -2, 0, 0),
        vector::zero
    );

    rhoN_ = dimensionedScalar("zero",  dimensionSet(0, -3, 0, 0, 0), VSMALL);
    rhoM_ =  dimensionedScalar("zero",  dimensionSet(1, -3, 0, 0, 0), VSMALL);
    dsmcRhoN_ = dimensionedScalar("zero",  dimensionSet(0, -3, 0, 0, 0), 0.0);
    linearKE_ = dimensionedScalar("zero",  dimensionSet(1, -1, -2, 0, 0), 0.0);
    internalE_ = dimensionedScalar("zero",  dimensionSet(1, -1, -2, 0, 0), 0.0);
    iDof_ = dimensionedScalar("zero",  dimensionSet(0, -3, 0, 0, 0), VSMALL);
    momentum_ = dimensionedVector
    (
        "zero",
        dimensionSet(1, -2, -1, 0, 0),
        vector::zero
    );
}
```

`DsmcCloud::calculateFields()`统计场

```
template<class ParcelType>
void Foam::DsmcCloud<ParcelType>::calculateFields()
{
    scalarField& rhoN = rhoN_.internalField();
    scalarField& rhoM = rhoM_.internalField();
    scalarField& dsmcRhoN = dsmcRhoN_.internalField();
    scalarField& linearKE = linearKE_.internalField();
    scalarField& internalE = internalE_.internalField();
    scalarField& iDof = iDof_.internalField();
    vectorField& momentum = momentum_.internalField();

    forAllConstIter(typename DsmcCloud<ParcelType>, *this, iter)
    {
        const ParcelType& p = iter();
        const label cellI = p.cell();
        rhoN[cellI]++;
        rhoM[cellI] += constProps(p.typeId()).mass();
        dsmcRhoN[cellI]++;
        linearKE[cellI] += 0.5*constProps(p.typeId()).mass()*(p.U() & p.U());
        internalE[cellI] += p.Ei();
        iDof[cellI] += constProps(p.typeId()).internalDegreesOfFreedom();
        momentum[cellI] += constProps(p.typeId()).mass()*p.U();
    }

    rhoN *= nParticle_/mesh().cellVolumes();
    rhoN_.correctBoundaryConditions();

    rhoM *= nParticle_/mesh().cellVolumes();
    rhoM_.correctBoundaryConditions();

    dsmcRhoN_.correctBoundaryConditions();

    linearKE *= nParticle_/mesh().cellVolumes();
    linearKE_.correctBoundaryConditions();

    internalE *= nParticle_/mesh().cellVolumes();
    internalE_.correctBoundaryConditions();

    iDof *= nParticle_/mesh().cellVolumes();
    iDof_.correctBoundaryConditions();

    momentum *= nParticle_/mesh().cellVolumes();
    momentum_.correctBoundaryConditions();
}
```

看看`DsmcCloud`的构造函数，可以发现它主要存储哪些东西：
```
// * * * * * * * * * * * * * * * * Constructors  * * * * * * * * * * * * * * //

template<class ParcelType>
Foam::DsmcCloud<ParcelType>::DsmcCloud
(
    const word& cloudName,
    const fvMesh& mesh,
    bool readFields
)
:
    Cloud<ParcelType>(mesh, cloudName, false),
    DsmcBaseCloud(),
    cloudName_(cloudName),
    mesh_(mesh),
    particleProperties_
    (
        IOobject
        (
            cloudName + "Properties",
            mesh_.time().constant(),
            mesh_,
            IOobject::MUST_READ_IF_MODIFIED,
            IOobject::NO_WRITE
        )
    ),
    typeIdList_(particleProperties_.lookup("typeIdList")),
    nParticle_(readScalar(particleProperties_.lookup("nEquivalentParticles"))),
    cellOccupancy_(mesh_.nCells()),
    sigmaTcRMax_ //<<------ 这个主要是作为计算的时候用，输出并没有意义。
    (
        IOobject
        (
            this->name() + "SigmaTcRMax",
            mesh_.time().timeName(),
            mesh_,
            IOobject::MUST_READ,  //<<------ 这里都是MUST_READ
            IOobject::AUTO_WRITE
        ),
        mesh_
    ),
    collisionSelectionRemainder_(mesh_.nCells(), 0),
    q_
    (
        IOobject
        (
            "q",
            mesh_.time().timeName(),
            mesh_,
            IOobject::MUST_READ,
            IOobject::AUTO_WRITE
        ),
        mesh_
    ),
    fD_
    (
        IOobject
        (
            "fD",
            mesh_.time().timeName(),
            mesh_,
            IOobject::MUST_READ,
            IOobject::AUTO_WRITE
        ),
        mesh_
    ),
    rhoN_
    (
        IOobject
        (
            "rhoN",
            mesh_.time().timeName(),
            mesh_,
            IOobject::MUST_READ,
            IOobject::AUTO_WRITE
        ),
        mesh_
    ),
    rhoM_
    (
        IOobject
        (
            "rhoM",
            mesh_.time().timeName(),
            mesh_,
            IOobject::MUST_READ,
            IOobject::AUTO_WRITE
        ),
        mesh_
    ),
    dsmcRhoN_
    (
        IOobject
        (
            "dsmcRhoN",
            mesh_.time().timeName(),
            mesh_,
            IOobject::MUST_READ,
            IOobject::AUTO_WRITE
        ),
        mesh_
    ),
    linearKE_
    (
        IOobject
        (
            "linearKE",
            mesh_.time().timeName(),
            mesh_,
            IOobject::MUST_READ,
            IOobject::AUTO_WRITE
        ),
        mesh_
    ),
    internalE_
    (
        IOobject
        (
            "internalE",
            mesh_.time().timeName(),
            mesh_,
            IOobject::MUST_READ,
            IOobject::AUTO_WRITE
        ),
        mesh_
    ),
    iDof_
    (
        IOobject
        (
            "iDof",
            mesh_.time().timeName(),
            mesh_,
            IOobject::MUST_READ,
            IOobject::AUTO_WRITE
        ),
        mesh_
    ),
    momentum_
    (
        IOobject
        (
            "momentum",
            mesh_.time().timeName(),
            mesh_,
            IOobject::MUST_READ,
            IOobject::AUTO_WRITE
        ),
        mesh_
    ),
    constProps_(),
    rndGen_(label(149382906) + 7183*Pstream::myProcNo()),
    boundaryT_
    (
        volScalarField
        (
            IOobject
            (
                "boundaryT",
                mesh_.time().timeName(),
                mesh_,
                IOobject::MUST_READ,
                IOobject::AUTO_WRITE
            ),
            mesh_
        )
    ),
    boundaryU_
    (
        volVectorField
        (
            IOobject
            (
                "boundaryU",
                mesh_.time().timeName(),
                mesh_,
                IOobject::MUST_READ,
                IOobject::AUTO_WRITE
            ),
            mesh_
        )
    ),
    binaryCollisionModel_
    (
        BinaryCollisionModel<DsmcCloud<ParcelType> >::New
        (
            particleProperties_,
            *this
        )
    ),
    wallInteractionModel_
    (
        WallInteractionModel<DsmcCloud<ParcelType> >::New
        (
            particleProperties_,
            *this
        )
    ),
    inflowBoundaryModel_
    (
        InflowBoundaryModel<DsmcCloud<ParcelType> >::New
        (
            particleProperties_,
            *this
        )
    )
{
    buildConstProps();

    buildCellOccupancy();

    // Initialise the collision selection remainder to a random value between 0
    // and 1.
    forAll(collisionSelectionRemainder_, i)
    {
        collisionSelectionRemainder_[i] = rndGen_.scalar01();
    }

    if (readFields)
    {
        ParcelType::readFields(*this);
    }
}
```
可以发现`DsmcCloud`的演化过程十分清晰明了。就是内部记录了一些extensive fields，和 particle的位置、速度。然后每个演化步统计这些 extensive fields，然后执行迁移和碰撞，边界处理。这些extensive fields完全由新时刻的particle速度计算出来。

#### fieldAverage 分析
在一个dsmcFoam的case里面，`controlDict` 文件里面要设置在求解过程中输出一些时间平均的场, 这由OpenFOAM本身提供的`fieldAverage` 和dsmcFOAM提供的`dsmcField` 这两个[Function object](http://cfd.direct/openfoam/user-guide/function-objects/)来完成。
**NOTE**: 关于`fieldAverage` Function object到底是怎样进行时间平均的， [这篇博文](http://xiaopingqiu.github.io/2015/04/12/fieldAverage/)有很好的分析。

下面这个例子是一个dsmcFoam case里`controlDict`文件的`functions`部分:
```
functions // 这里面是设置了两个时间平均计算，一个是fieldAverage1，另一个是dsmcFields1
{
    fieldAverage1
    {
        type            fieldAverage; //<<------ 这个是OpenFOAM本身提供的。
        functionObjectLibs ( "libfieldFunctionObjects.so" );
        outputControl   outputTime; //<<------  随着每次dsmcFoam输出AUTO_WRITE属性的
                                    //场（由controlDict里面的writeControl控制）
                                    //的时候都会输出这些时均场。
        resetOnOutput   false;

        fields
        (
            rhoN
            {
                mean        on;
                prime2Mean  off;
                base        time; // 如果base设为time的话，每个演化步都会计算一次时均
                //windows    2;   //窗口长度为2，就是相对于没有windows,统计频率会降低一倍。
            }
            rhoM
            {
                mean        on;
                prime2Mean  off;
                base        time;
            }
            ... //省略
            fD
            {
                mean        on;
                prime2Mean  off;
                base        time;
            }
        );
    }
    dsmcFields1
    {
        type            dsmcFields;
        functionObjectLibs ( "libutilityFunctionObjects.so" );
        enabled         true;
        outputControl   outputTime;
    }
}

```
这里面设置每个需要计算时均值的场的设置。包括`mean`,`prome2Mean`,`base`,`window`。时均场输出的文件名后面会多一个*Mean*。 如momentum的时均场为momentumMean。

上面的设置中`base`为`time`，发现计算过程中每个演化步(`DsmcCloud::evolve()`)都计算了时均场，log里面每个演化都会出现：
```
fieldAverage fieldAverage1 output:
    Calculating averages
```
*  如果不设置`window` : 每次计算的时均场都是从**求解开始到目前所有步**的时均场。
*  如果设置了`window` :  
>base用来指定作时间平均的基础，是基于时间步数(ITER)还是物理时间(time);  window用来作平均的时间段的长度，如果不设定，则求的是从开始到当前时间这个时间段的平均值。window的数值的实际含义依base而定，如果base是ITER，则window=20表示当前步及其前 19 个时间步从 20 个时间步内的平均，而如果base是time,则表示的是 20s 内的平均。


在输出数据文件时（每evolve 100次）还会输出`fieldAverage1`设置的时均场(` writing average fields`)：
```
fieldAverage fieldAverage1 output:
    Calculating averages
    writing average fields //<------ 表示输出时均场

Calculating dsmcFields.
    Calculating UMean field.
    Calculating translationalT field.
    Calculating internalT field.
    Calculating overallT field.
    Calculating pressure field.
    mag(UMean) max/min : 76.50092418551631 1.282028354585403
    translationalT max/min : 436.5786449656766 219.0809500397843
    internalT max/min : 0 0
    overallT max/min : 436.5786449656766 219.0809500397843
    p max/min : 67296.44015303567 42358.60866053814
dsmcFields written.
```
**NOTE**: 可以发现在`writing average fields`的时候`dsmcFields` function object被触发了，它计算`UMean`,`translationalT `,`internalT`,`overallT`,`pressure`等场。

可以定义两个开关分别是`resetOnOutput`和`resetOnRestart`, 其意义是：
>resetOnRestart的值决定当solver继续运行时，是否要读取最近一个时间步的meanField的值来计算接下来时刻的时均值；>resetOnOutput，顾名思义，是否要在每一次输出到文件以后重置meanField的值。这两个开关的默认值都是false。"

这里可能有个疑问，如果不做这两个时均计算会怎样？会不会影响计算过程？毕竟dsmc的计算过程不依赖于这些宏观量场以及它们的时均场。这个疑问是很自然的。可以通过一个例子分析一下：
如果在`controlDict`文件里面如下设置
```
startTime       0;
stopAt          endTime;
endTime         1e-8;
deltaT          1e-11;
writeControl    timeStep;
writeInterval   100;
```
表示计算1000步，每100步输出。
1. 如果我们再注释掉`functions`部分, 也就是不求平均。运行dsmcFoam，也没有问题，不会报错。运行完会产生10个数据文件目录（1000/100=10）。
    ```
    [lhzhu@ws3 dsmc1]$ ls
    0  1e-08  1e-09  2e-09  3e-09  4e-09  5e-09  6e-09  7e-09  8e-09  9e-09  constant  log  PyFoamHistory  system
    ```
每个目录里面只有当前步的统计出来的场(非时均)：
```
[lhzhu@ws3 dsmc1]$ ls 1e-09
boundaryT  boundaryU  dsmcRhoN  dsmcSigmaTcRMax  fD  iDof  internalE  lagrangian  linearKE  momentum  q  rhoM  rhoN  uniform
```
2. 但是如果我们如果只注释掉`functions`里面的`fieldAverage1`部分，或者只去掉 `fieldAverage1`里面的任何一个时均场，则会报错。比如去掉`fD`的时均计算，会有Fatal Error如下：
```
--> FOAM FATAL ERROR:
    request for volVectorField fDMean from objectRegistry region0 failed
```
这个错误应该是在执行`dsmcFields` function object 时产生的。下面我们分析`dsmcFields`。

####dsmcFields分析
源文件位置： https://github.com/OpenFOAM/OpenFOAM-2.3.x/tree/master/src/postProcessing/functionObjects/utilities/dsmcFields

`dsmcFields.H`
```
Description
    Calculate intensive fields:
    - UMean
    - translationalT
    - internalT
    - overallT
    from averaged extensive fields from a DSMC calculation.
SourceFiles
    dsmcFields.C
    IOdsmcFields.H
```

```

class dsmcFields
{
    // Private data

        //- Name of this set of dsmcFields objects
        word name_;

        const objectRegistry& obr_;

        //- on/off switch
        bool active_;


    // Private Member Functions

        //- Disallow default bitwise copy construct
        dsmcFields(const dsmcFields&);

        //- Disallow default bitwise assignment
        void operator=(const dsmcFields&);


public:

    //- Runtime type information
    TypeName("dsmcFields");


    // Constructors

        //- Construct for given objectRegistry and dictionary.
        //  Allow the possibility to load fields from files
        dsmcFields
        (
            const word& name,
            const objectRegistry&,
            const dictionary&,
            const bool loadFromFiles = false
        );


    //- Destructor
    virtual ~dsmcFields();


    // Member Functions

        //- Return name of the set of dsmcFields
        virtual const word& name() const
        {
            return name_;
        }

        //- Read the dsmcFields data
        virtual void read(const dictionary&);

        //- Execute, currently does nothing
        virtual void execute();

        //- Execute at the final time-loop, currently does nothing
        virtual void end();

        //- Called when time was set at the end of the Time::operator++
        virtual void timeSet();

        //- Calculate the dsmcFields and write
        virtual void write(); //<------ 最重要的是这个函数

        //- Update for changes of mesh
        virtual void updateMesh(const mapPolyMesh&)
        {}

        //- Update for changes of mesh
        virtual void movePoints(const polyMesh&)
        {}
};

```
`dsmcFields::write()`
```
void Foam::dsmcFields::write()
{
    if (active_)
    {
        word rhoNMeanName = "rhoNMean";
        word rhoMMeanName = "rhoMMean";
        word momentumMeanName = "momentumMean";
        word linearKEMeanName = "linearKEMean";
        word internalEMeanName = "internalEMean";
        word iDofMeanName = "iDofMean";
        word fDMeanName = "fDMean";

        const volScalarField& rhoNMean = obr_.lookupObject<volScalarField>
        (
            rhoNMeanName
        );

        const volScalarField& rhoMMean = obr_.lookupObject<volScalarField>
        (
            rhoMMeanName
        );

        const volVectorField& momentumMean = obr_.lookupObject<volVectorField>
        (
            momentumMeanName
        );

        const volScalarField& linearKEMean = obr_.lookupObject<volScalarField>
        (
            linearKEMeanName
        );

        const volScalarField& internalEMean = obr_.lookupObject<volScalarField>
        (
            internalEMeanName
        );

        const volScalarField& iDofMean = obr_.lookupObject<volScalarField>
        (
            iDofMeanName
        );

        const volVectorField& fDMean = obr_.lookupObject<volVectorField>
        (
            fDMeanName
        );

        if (min(mag(rhoNMean)).value() > VSMALL)
        {
            Info<< "Calculating dsmcFields." << endl;

            Info<< "    Calculating UMean field." << endl;
            volVectorField UMean
            (
                IOobject
                (
                    "UMean",
                    obr_.time().timeName(),
                    obr_,
                    IOobject::NO_READ
                ),
                momentumMean/rhoMMean
            );

            Info<< "    Calculating translationalT field." << endl;
            volScalarField translationalT
            (
                IOobject
                (
                    "translationalT",
                    obr_.time().timeName(),
                    obr_,
                    IOobject::NO_READ
                ),

                2.0/(3.0*physicoChemical::k.value()*rhoNMean)
               *(linearKEMean - 0.5*rhoMMean*(UMean & UMean))
            );

            Info<< "    Calculating internalT field." << endl;
            volScalarField internalT
            (
                IOobject
                (
                    "internalT",
                    obr_.time().timeName(),
                    obr_,
                    IOobject::NO_READ
                ),
                (2.0/physicoChemical::k.value())*(internalEMean/iDofMean)
            );

            Info<< "    Calculating overallT field." << endl;
            volScalarField overallT
            (
                IOobject
                (
                    "overallT",
                    obr_.time().timeName(),
                    obr_,
                    IOobject::NO_READ
                ),
                2.0/(physicoChemical::k.value()*(3.0*rhoNMean + iDofMean))
               *(linearKEMean - 0.5*rhoMMean*(UMean & UMean) + internalEMean)
            );

            Info<< "    Calculating pressure field." << endl;
            volScalarField p
            (
                IOobject
                (
                    "p",
                    obr_.time().timeName(),
                    obr_,
                    IOobject::NO_READ
                ),
                physicoChemical::k.value()*rhoNMean*translationalT
            );

            const fvMesh& mesh = fDMean.mesh();

            forAll(mesh.boundaryMesh(), i)
            {
                const polyPatch& patch = mesh.boundaryMesh()[i];

                if (isA<wallPolyPatch>(patch))
                {
                    p.boundaryField()[i] =
                        fDMean.boundaryField()[i]
                      & (patch.faceAreas()/mag(patch.faceAreas()));
                }
            }

            Info<< "    mag(UMean) max/min : "
                << max(mag(UMean)).value() << " "
                << min(mag(UMean)).value() << endl;

            Info<< "    translationalT max/min : "
                << max(translationalT).value() << " "
                << min(translationalT).value() << endl;

            Info<< "    internalT max/min : "
                << max(internalT).value() << " "
                << min(internalT).value() << endl;

            Info<< "    overallT max/min : "
                << max(overallT).value() << " "
                << min(overallT).value() << endl;

            Info<< "    p max/min : "
                << max(p).value() << " "
                << min(p).value() << endl;

            UMean.write();

            translationalT.write();

            internalT.write();

            overallT.write();

            p.write();

            Info<< "dsmcFields written." << nl << endl;
        }
        else
        {
            Info<< "Small value (" << min(mag(rhoNMean))
                << ") found in rhoNMean field. "
                << "Not calculating dsmcFields to avoid division by zero."
                << endl;
        }
    }
}
```
明显可以发现`dsmcFields`所做的只是根据`fieldAverage1`输出的时均场来求出其他时均场，例如根据时均密度场和时均动量场来求出时均速度场。这个工作也可以由后处理工具`dsmcFieldsCalc`完成，而不是写成`controlDict`里面的function object。


####总结
综上分析，有以下总结：
* 用`fieldAverage`对宏观量场求时均是dsmcFoam里面输出宏观量场的最重要步骤。
*  `window`控制对那一段时间求平均。如果不设置`window`就是从开始到当前所有步的平均。
    如果设置`window`, 结合`base`  (`ITER`/`time`)，可以设置 从当前时间/步 往前多少s/步 求时均值。
*  `dsmcFields` 辅助计算其他时均场如 `UMean`, `overallT`等等，它只是对`fieldAverage`输出的时均场做简单的加减乘除计算。

####如何解决我的问题？
要算低速问题(Ma < 0.001)，`window`必须设置得足够大, 统计得出的速度场噪音才会足够小。

比如我算一个二维问题，计算区域为一个边长为1e-6m的方腔。上壁面温度为200K, 其他三个壁面温度为400K，壁面为漫反射边界。我的设置如下：

等我算对了，再回来更新吧！

