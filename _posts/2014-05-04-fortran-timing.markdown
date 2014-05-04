---
layout: post
title: "Fortran 计时函数"
categories:
- tech
tags:
- fortran


---
Fotran 计时函数， 注意区分*CPU时间*和*系统时间* 。

*  Fortran 77 : etime()
    {% highlight fortran %}
        call etime(tarray,t0)
        ... ...
        call etime(tarray,t1)
        print *, 'Elapsed time:', t1 - t0
    {% endhighlight %}

*  Fortran 90 : system_clock() 测量真实时间(real time).
    {% highlight fortran %}
        integer ( kind = 4  ) clock_count
        integer ( kind = 4  ) clock_count1
        integer ( kind = 4  ) clock_count2
        integer ( kind = 4  ) clock_max
        integer ( kind = 4  ) clock_rate
        ... ...
        call system_clock ( clock_count1, clock_rate, clock_max  )
        do i = 1, n
         ...some big calculation...
        end do
        call system_clock ( clock_count2, clock_rate, clock_max  )
        write ( *, *  ) 'Elapsed real time = ', real ( t2 - t1  ) / real ( clock_rate  )
    {% endhighlight %}

*  Fortran 95 : cpu_time() 测量CPU时间(cpu time).
    {% highlight fortran %}
        real (kind=8) t1
        real (kind=8) t2
        ... ...
        call cpu_time ( t1  )
        do i = 1, n
           ...some big calculation...
        end do
        call cpu_time ( t2  )
        write ( *, *  ) 'Elapsed CPU time = ', t2 - t1
    {% endhighlight %}

-----

