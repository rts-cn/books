## 使用lsof查看freeswitch打开文件句柄数超高
> moyan/2020-09

<b>问题描述</b>    
使用网上流行的lsof -n|grep pid命令来查看打开的文件句柄数，得到结果如下：    

> [root@116_9 ~]# lsof -n|grep 4847|wc -l    
> 134574

    
通过统计freeswitch进程（进程id：4847）占用的句柄数，  达到134574.     
于是引发一系列联想， 这么高的句柄数，会不会引发什么问题，目前我的xx问题是不是由这么高的句柄数引起的。。。<br />总之，这是一个杯具的开始。    

<b>问题解决</b>    
如果真要查看实际的句柄， 使用下面的命令来查找：    
```bash
lsof -p 4847|wc -l
```
下面是具体的返回结果：<br /> 
   
> [root@116_9 ~]# lsof -p 4847|wc -l    
> 1086

可以看出，真实使用的句柄总数也才1086，虚惊一场.    
而为什么lsof -n|grep 4847返回的句柄数超高， 直接贴一段引用：  
   
> - lsof的结果包含了并非以fd形式打开的文件，比如用mmap方式访问文件（FD一栏显示为mem），实际并不占用fd。<br />其中包括了像.so这样的文件。从结果看.jar文件也是以FD为mem和具体fd编号分别打开了一次。
> - CentOS 7的lsof（我这里lsof -v的版本号是4.87）是按PID/TID/file的组合对应一行，不是一行一个fd。同一个进程如果多个线程访问同一个文件通常只需要打开一次、占用一个fd，但在lsof中就显示多行。<br />如果用lsof -p <pid>，则不按TID显示，结果数少很多。但仍包含了没有使用fd的文件。


使用lsof -n|grep xxx查看文件句柄数就是一个巨坑，慎重！

下面是[作者](https://www.jianshu.com/p/407c2baef92e) 推荐的查看占用fd最多进程的方法：    

```bash
find /proc -print | grep -P '/proc/\d+/fd/'| awk -F '/' '{print $3}' | uniq -c | sort -rn | head
```


<b>参考资料</b>    
1. [[Linux] lsof的错误使用场景和查看打开文件数的正确方法](https://www.jianshu.com/p/407c2baef92e)    
2. [lsof -p PID vs lsof | grep PID](https://unix.stackexchange.com/questions/252134/lsof-p-pid-vs-lsof-grep-pid)    
3. [HOW TO - Use lsof to list open files used by the Apache Cassandra database](https://support.datastax.com/hc/en-us/articles/209826153-lsof-shows-Cassandra-is-holding-a-large-amount-of-files-open)

