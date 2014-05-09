---
layout: post
title: "Bash 中的数组"
categories:
- tech
tags:
- bash
- linux

---


* 声明一个数组`array`
  {% highlight bash %}
  declare -a array
  {% endhighlight %}
  其实也可以不用声明，直接用赋值语句初始化一个数组，Bash会默认为它就是个数组

* 数组赋值
  {% highlight bash %}
  array=(var1 var2 var3 ... varN)
  array=([0]=var1 [1]=var2 [2]=var3 ... [n]=varN)
  array[0]=var1
  arrya[1]=var2
  #...
  array[n]=varN
  {% endhighlight %}

* 引用数组
    {% highlight bash %}
    echo ${array[0]} #数组下标从0开始
    echo ${array[1]}
    {% endhighlight %}

* 遍历数组
    {% highlight bash %}
    filename=(`ls`)
    for var in ${filename[@]};do
    echo $var
    done
    {% endhighlight %}

