---
layout: post
title: "OpenFOAM stabilise function"
categories:
- kuoyan
tags:
- OpenFOAM

---


{% highlight cpp %}
// Stabilisation around zero for division
inline Scalar stabilise(const Scalar s, const Scalar small)
{
    if (s >= 0)
    {
        return s + small;
    }
    else
    {
        return s - small;
    }
}
{% endhighlight %}
