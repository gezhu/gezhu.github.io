---
layout: post
title: "Fortran 随机数"
categories:
- tech
tags:
- fortran


---
先写个利用系统时间设置随即数种子的函数`init_random_seed()`，放到
一个模块文件里面，便于重复利用。
在主函数里面加载这个模块，调用一次这个`init_random_seed()`函数。

`random.f90`:
    {% highlight fortran %}
    module random
        contains
        subroutine init_random_seed()
            INTEGER :: i, n, clock
            INTEGER, DIMENSION(:), ALLOCATABLE :: seed
            CALL RANDOM_SEED(size = n)
            ALLOCATE(seed(n))
            CALL SYSTEM_CLOCK(COUNT=clock)
            seed = clock + 37 * (/ (i - 1, i = 1, n) /)
            CALL RANDOM_SEED(PUT = seed)
            DEALLOCATE(seed)
        end subroutine init_random_seed
    end module random
    {% endhighlight %}

调用测试一下:

`test_random.f90`:
    {% highlight fortran %}
    program test_rand
        use random
        real :: A
        call init_random_seed()
        call random_number(A)
        write(*,*) A
    end program test_rand
    {% endhighlight %}

每次运行结果应该都不一样。
