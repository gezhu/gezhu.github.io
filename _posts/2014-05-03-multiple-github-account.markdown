---
layout: post
title: "github 多个账号"
categories:
- Linux
tags:

- linux, git


---

可以使用不同的邮箱在github上注册不同的账号，但是从*同一台电脑上*向不同账号的repo里面push
时会出问题。

这里假设我已用gmail邮箱<xxx@gmail.com>注册过一个github账号,叫做userGm。现在我用qq mail(sss@qq.com) 
注册另一个github账号userQm。

在github上注册了账号，要从我的电脑上push，还得把我在这台电脑的ssh公钥贴到github账号里面。
原来的github账号userGm已经完成了这一步，贴到userGm里面的ssh公钥文件是`~/.ssh/id_rsa.pub`。
当我尝试把这个公钥文件贴到userQm里面时，gitbhub告诉我这个公钥文件已被使用，不能再用了.:<

上面说的问题可以通过ssh的config功能解决。在Linux上，一个UNIX账户可以生成多个ssh密钥对。现在
默认的共钥`~/.ssh/id_rsa.pub`已经给userGm使用了，那我们就再生成一对新的密钥给userQm使用。


##生成新的密钥 

-----
首先用qq mail生成新的密钥对：

    $ ssh-keygen -t rsa -C "sss@qq.com"
    
当提示输入新的key文件名时，不要按回车，不然会覆`~/.ssh/id_rsa`和`~/.ssh/id_rsa.pub`。
应该取个新名字，如`~/.ssh/id_rsa_qm`。

然后把原来的密钥和上一步上生成的密钥都用`ssh-add`操作：

    $ ssh-add  ~/.ssh/id_rsa
    $ ssh-add  ~/.ssh/id_rsa_qm

完了可以检查下：

    $ ssh-add -l
    
应该可以看到两条记录。

##修改`~/.ssh/config`文件

-----
接下来的操作就是修改~/.ssh/config文件了。按照前面的配置，这个文件应该这样写：

    #userGm account
    Host github.com-userGm 
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa

    #userQm account
    Host github.com-userQm
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_rsa_qm



##设置userQm的repo里的git user 和 email

-----
比如clone了userQm的repo 到目录 `userQm_demo_git`, 接下来修改它的git配置:


    $ cd userQm_demo_git
    $ git config user.name "userQm"
    $ git config user.email "sss@qq.com" 


最后还要修改`remote`地址，编辑 `userQm_demo_git/.git/config`文件，把
\[remote\ "origin"] 里面的url换成这样子：

     url = ssh://git@github.com-userQm/userQm/your-git-repp.git





-----
