---
layout: post
title: "OpenFOAM function objects"
categories:
- kuoyan
tags:
- OpenFOAM

---

{% highlight %}
functions
(
    fieldAverage1
    {
        // Type of functionObject
        type fieldAverage;

        // Where to load it from (if not already in solver)
        functionObjectLibs ("libfieldFunctionObjects.so");

        outputControl     outputTime;

        // Fields to be  averaged - runTime modifiable
        fields
        (
            U
            {
                mean            on;
                prime2Mean      on;
                base            time;
            }
            p
            {
                mean            on;
                prime2Mean      on;
                base            time;
            }
        );
    }
);
{% endhighlight %}
