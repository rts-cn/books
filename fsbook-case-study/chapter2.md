# 安全相关

## iptables

如果FreeSWITCH要在公网上运行，第一要务就是需要设置好iptables。

在CentOS服务器上，可以使用`service iptables start|stop`来开启和关闭iptables，但在Debian上却没有这么便利。因此，我们需要自己实现一些机制。

首先，先建立一个关闭iptables的脚本，如`/root/stop-iptables.sh`，如下：

```bash
#!/bin/bash
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
```

做好后执行一遍确保能够清除iptables里所有的规则。接下来，设置`crontab`，执行`crontab -e`并添加如下规则：

    */5 * * * * /root/stop-iptables.sh > /dev/null 2>&1

这条规则让系统每5分钟执行脚本关闭`iptables`。为什么？因为不管新手还是老手，我们发现有相当多的系统管理员在设置iptables时把自己锁在外面，连SSH也登录不了了。如果是本地的机器还好，可以进控制台操作，但如果是远程的机器就不那么便利了，更不用说是在客户的机器上工作时......

添加一条测试规则：

    iptables -A INPUT -s 1.2.3.4 -j DROP

使用`iptables -L -n`查看结果。抽袋烟，确保在5分钟后，这条规则不见了，说明crontab生效了。慎重。

有了这个法宝，就可以随便玩了，如果不慎将自己锁在防火墙外面，抽袋烟，防火墙自己就倒了。

下面添加一些基本的规则。开启SIP端口5060和5080，开启UDP端口16384～32768。

```bash
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 5060 -j ACCEPT
iptables -A INPUT -p udp --dport 5060 -j ACCEPT
iptables -A INPUT -p tcp --dport 5080 -j ACCEPT
iptables -A INPUT -p udp --dport 5080 -j ACCEPT
iptables -A INPUT -p udp --dport 16384:32768 -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```

安装iptables-persistent，安装后，在开机时，它会从`/etc/iptables/rules.v4`读取并设置iptables规则。

```bash
apt-get install iptables-persistent
```

每次修改`iptables`规则，都要记得保存一下：

    /sbin/iptables-save > /etc/iptables/rules.v4

也可以添加到crontab，每分钟保存一次：

    * * * * * /sbin/iptables-save > /etc/iptables/rules.v4

好了，下面可以添加更多的记录了，比如，在公网上开了SIP就经常有人扫描，非常讨厌：

```bash
iptables -I INPUT -j DROP -p tcp --dport 5060 -m string --string "friendly-scanner" --algo bm
iptables -I INPUT -j DROP -p tcp --dport 5080 -m string --string "friendly-scanner" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "friendly-scanner" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5080 -m string --string "friendly-scanner" --algo bm
```

上面的`friendly-scanner`还可以换成`sipcli`等其它扫描器。

所有规则都设好后，可以重启服务器试一下，看是否所有的规则都能自动恢复。

如果到现在你还没把自己锁在外面，可以去掉crontab里自动关闭防火墙的脚本了。恭喜你，已经有点安全感了。
