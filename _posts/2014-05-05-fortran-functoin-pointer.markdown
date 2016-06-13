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
module ExampleFuncs
   implicit none
    contains
    function f1 (x)
      real :: f1
      real, intent (in) :: x
      f1 = 2.0 * x
      write(*,*) "I am func 1"
    end function f1

    function f2 (x)
       real :: f2
       real, intent (in) :: x
       f2 = 3.0 * x**2
       write(*,*) "I am func 2"
       return
    end function f2
end module ExampleFuncs


program test_func_ptrs
    use ExampleFuncs
    implicit none
    abstract interface
        function func (z)
            real :: func
            real, intent (in) :: z
        end function func
    end interface

   procedure (func), pointer :: f_ptr => null ()
   real :: input

   write (*, '( / "Input test value: ")', advance="no" )
   read (*, *) input
   if ( input < 0 ) then
      f_ptr => f1
   else
      f_ptr => f2
   end if
   write (*, '(/ "evaluate function: ", ES14.4 )' )  f_ptr (input)
   stop
end program test_func_ptrs
{% endhighlight %}
