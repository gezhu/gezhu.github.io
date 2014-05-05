---
layout: post
title: "Fortran 函数指针"
categories:
- tech
tags:
- fortran


---
例子:

    {% highlight fortran %}
    call etime(tarray,t0)
    ! ... ...
    call etime(tarray,t1)

    print *, 'Elapsed time:', t1 - t0
    {% endhighlight %}
