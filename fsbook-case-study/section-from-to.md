# SIP Trunk对接中如何修改From和To的值

今天有同学问到这个问题。其实解答这个问题很简单，挽起袖子试一下便知。

进入FreeSWITCH控制台。打开SIP Trace

```bash
sofia global siptrace on
```

呼叫一个地址，其中，我们从`external`这个Profile呼出，呼叫`demo.xswitch.cn`，由于我们只是为了看INVITE信息，所以直接挂掉即可。


```bash
bgapi originate sofia/external/to1234@demo.xswitch.cn &hangup
```

看信令

```bash
send 1547 bytes to udp/[211.159.171.210]:5060
---------------------------------------------
INVITE sip:to1234@demo.xswitch.cn SIP/2.0
From: "" <sip:0000000000@172.23.0.3>;tag=UyQt1USK0D86m
To: <sip:to1234@demo.xswitch.cn>
```

我们看到，To就是我们命令行中的`to1234`。

下面尝试改From：

```bash
bgapi originate {origination_caller_id_number=from5678}sofia/external/to1234@demo.xswitch.cn &hangup

INVITE sip:to1234@demo.xswitch.cn SIP/2.0
From: "" <sip:from5678@172.23.0.3>;tag=yS346ccyQ8aZQ
To: <sip:to1234@demo.xswitch.cn>
```

进一步修改：

```bash
bgapi originate {origination_caller_id_name='From Name',origination_caller_id_number=from5678}sofia/external/to1234@demo.xswitch.cn &hangup

INVITE sip:to1234@demo.xswitch.cn SIP/2.0
From: "From Name" <sip:from5678@172.23.0.3>;tag=2X87DSFccc49N
```

相信到这里你已经看明白了，`origination_caller_id_name`和`origination_caller_id_number`这两个通道变量就是管这个的。

当然，如果你不是用的`originate`，而是在Dialplan中使用`bridge`，差不多是一样的：

```xml
<action application="bridge" data="{origination_caller_id_number=123}sofia/..."/>
```

也许有的同学会说，那我想改domain部分怎么办？

这个有点麻烦，但难不住FreeSWITCH。我们先找到目标的IP地址。


```bash
ping demo.xswitch.cn
PING demo.xswitch.cn (211.159.171.210): 56 data bytes
64 bytes from 211.159.171.210: icmp_seq=0 ttl=54 time=22.331 ms
```

一步一步来。注意看，下面命令中的Domain都换成了IP地址，包括`INVITE`那一行（那一行叫Request Line）。

```bash
bgapi originate sofia/external/to1234@211.159.171.210 &hangup

send 1547 bytes to udp/[211.159.171.210]:5060
---------------------------------------------
INVITE sip:to1234@211.159.171.210 SIP/2.0
From: "" <sip:0000000000@172.23.0.3>;tag=5rmjKa2p3661r
To: <sip:to1234@211.159.171.210>
```

再来


```bash
bgapi originate {sip_invite_domain=demo.xswitch.cn}sofia/external/to1234@211.159.171.210 &hangup

send 1557 bytes to udp/[211.159.171.210]:5060 at 21:30:10.928189:
------------------------------------------------------------------------
INVITE sip:to1234@211.159.171.210 SIP/2.0
From: "" <sip:0000000000@demo.xswitch.cn>;tag=7a73p03XXrK7F
To: <sip:to1234@211.159.171.210>
```

对比下什么变化，上面的命令只会影响From中的domain。

继续，可以看到下面的命令中，domain又变回来了，并且多了`Route`头，表示SIP消息下一跳将发到这个地址。

```bash
bgapi originate {sip_invite_domain=demo.xswitch.cn}sofia/external/to1234@demo.xswitch.cn;fs_path=sip:211.159.171.210 &hangup

send 1577 bytes to udp/[211.159.171.210]:5060
---------------------------------------------
INVITE sip:to1234@demo.xswitch.cn SIP/2.0
Route: <sip:211.159.171.210>
From: "" <sip:0000000000@demo.xswitch.cn>;tag=BFc7Xc7Bjvcje
To: <sip:to1234@demo.xswitch.cn>
```

好了，下面我们开始换Domain了：

```bash
bgapi originate {sip_invite_domain=mydomain.example.com}sofia/external/to1234@mydomain.example.com;fs_path=sip:211.159.171.210 &hangup

send 1587 bytes to udp/[211.159.171.210]:5060
---------------------------------------------
INVITE sip:to1234@mydomain.example.com SIP/2.0
Route: <sip:211.159.171.210>
From: "" <sip:0000000000@mydomain.example.com>;tag=D1yr128jceSQN
To: <sip:to1234@mydomain.example.com>
```

到此，相信到此你已经完全明白了，`fs_path`决定下一跳送到哪个IP，其它参数改变Request Line，From和To的值。

不过，如果你在跟IMS对接时，会不会有这种情况呢？

```bash
bgapi originate {sip_invite_to_uri=tel:+86186xxxxxxxx}sofia/external/to1234@mydomain.example.com;fs_path=sip:211.159.171.210 &hangup

send 1574 bytes to udp/[211.159.171.210]:5060
---------------------------------------------
INVITE sip:to1234@mydomain.example.com SIP/2.0
Route: <sip:211.159.171.210>
From: "" <sip:0000000000@172.23.0.3>;tag=KQpDc5D8t3y7a
To: <tel:+86186xxxxxxxx>
```

还有

```bash
bgapi originate {sip_invite_req_uri=sip:example.com,sip_invite_to_uri=tel:+86186xxxxxxxx}sofia/external/to1234@mydomain.example.com;fs_path=sip:211.159.171.210 &hangup

send 1558 bytes to udp/[211.159.171.210]:5060
---------------------------------------------
INVITE sip:example.com SIP/2.0
Via: SIP/2.0/UDP 172.23.0.3:5080;rport;branch=z9hG4bK83rSUZyD7KX9g
Route: <sip:211.159.171.210>
Max-Forwards: 70
From: "" <sip:0000000000@172.23.0.3>;tag=N98yFUFFNNBDj
To: <tel:+86186xxxxxxxx>
```

在实际对接中，有时候也会使用Gateway方式对接。注意其中的各个参数，分别改一下，看看SIP消息会有什么变化。

```xml
<gateway name="example">
	<param name="username" value="用户名"/>
	<param name="password" value="密码"/>
	<param name="proxy" value="对端ip:端口"/>
	<param name="from-user" value="用户名"/>
	<param name="from-domain" value="域"/>
	<param name="register" value="false或true"/>
	<param name="extension" value="test"/>
	<param name="contact-params" value="domain_name=$${domain}"/>
	<param name="context" value="external"/>
<!-- <param name="caller-id-in-from" value="true"/> -->
</gateway>
```

使用上述Gateway的命令如下，你可以看到，上面学到了各个通道变量在这里大部分也是好使的。

```bash
bgapi originate {origination_caller_id_number=from1234}sofia/gateway/example/to1234 &hangup
```

祝玩得开心。
