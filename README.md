# fsbooks

集体写一本书，这真是一件令人振奋的事情。如果一本不过瘾，那就写两本。

* 《FreeSWITCH案例大全》 fsbook-case-study
* 《FreeSWITCH参考手册》 fsbook-references

源文件使用Markdown格式，排版使用Pandoc和Latex。参见[《我在Mac上的写作工具链》](http://mp.weixin.qq.com/s?__biz=MjM5MzIwMzExMg==&mid=222341648&idx=1&sn=1a6c4c69e57194153080050b352b8d2e&mpshare=1&scene=1&srcid=1019tXeqPF7qSccOsyBM0GK7#rd)。

关于Markdown格式请参考已有的内容。欢迎大家配置好自己的Pandoc环境，但配置不起来也没什么问题。我们会有专人负责格式。


## 《FreeSWITCH案例大全》

按照《FreeSWITCH实例解析》的格式来写。

## 《FreeSWITCH参考手册》

主要内容：

* 模块 （杜金房）
* 通道变量
* API参考
* App参考


## 协作流程

在多人写作过程中，可能有一些冲突。为避免不必要的冲突，我们建议使用如下流程：

* 先在群里跟大家讨论要写的内容
* 如果一个内容有多个人同时写，则可以有一个主要负责人，其它人统一由这个负责人协调
* 把每个人负责的部分更新到该README主要内容部分。


## 注意事项

* 本仓库是私有的，不要Fork和公开本仓库。
* 所有提交都提交到Master分支上。注意尽量避免冲突。当然，如果不确定，也可以自己创建分支，由杜老师审核。
* 可以在Windows系统上工作，但要使用UNIX换行符。文件尾部必须有换行符。
* 中文使用UTF-8编码。需要一个称手的编辑器。可以使用Sublime Text之类的编辑器。不要用Windows记事本。
* 每次修改前都先`pull`最新的，以减少冲突。为了保持一个清淅的提交历史，建议使用rebase方式更新`master`，如，修改 `.git/config`：

```
[branch "master"]
        remote = origin
        merge = refs/heads/master
        rebase = true
```

## 权益声明

每个人的作品自己有版权。如果以后书能大卖，或许每个人都能获得一些收益，但是，不要指望写书挣钱，把这个过程更多的看作是一种贡献。与其计算每个人应该分多少钱，不如我们一起支持一个开源项目或捐赠一个公益事业。

