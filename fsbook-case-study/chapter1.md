# 基本案例

## 巧用`mod_prefix`生成呼叫字符串

> 2016-10-22/Seven

笔者今天测试了一个好玩的功能。

问题提出：需要一个路由查询功能，生成相关的呼叫字符串，针对不同的号码走不同的网关。

这还不简单，你可能说，看我的：

```xml
<condition field="destination_number" expression=“^(130.*)|(186.*)$">
    <action application=“bridge" data=“sofia/gateway/chinaunicom/$1"/>
</condition>

<condition field="destination_number" expression=“^(138.*)|(139.*)$">
    <action application=“bridge" data=“sofia/gateway/chinamobile/$1"/>
</condition>

<condition field="destination_number" expression=“^(133.*)|(189.*)$">
    <action application=“bridge" data=“sofia/gateway/chinatelecom/$1"/>
</condition>
```

嗯，不错，在Dialplan中是可以这么做，根据正则表达式，联通、移动、电信的电话分别走不同的网关。

但是，有时候，我们需要在程序中直接呼出，如

    originate sofia/gateway/chinaunicom/1860535xxxx &echo

这时，除了直接将呼叫字符串写死在程序里，需要一种简便的方法。能够根据被叫号码自动生成呼叫字符串。

当然，这里有一种方法，就是使用`loopback` Endpoint。`loopback`会生成一个假的Channel，预先进入Dialplan查找路由。因此，上述Dialplan中的路由配置是有效的。

但是，`loopback`会生成假的Channel，有时候，它并不是最佳的选择。

好在，我们还有另外的一种方法。

首先，我们知道，常用的呼叫字符串如`user/1000`会查找一个本地用户，再根据该用户的配置去查找实际的呼叫字符串（如用`sofia_contact`从数据库中查询当前用户的注册信息）。

下面，我们来创建一个特殊的用户，配置如下：

```xml
<include>
  <user id="prefix">
    <params>
      <param name="dial-string" value="test_prefix/1234"/>
    </params>
  </user>
</include>
```

因为该用户只是为了做“被叫”使用，我们只用它来生成呼叫字符串，因此，它只有一个配置参数：`dial-string`。

好了，尝试呼叫一下：

    originate user/prefix &echo
    [ERR] switch_core_session.c:511 Could not locate channel type test_prefix

出错了。找不到`test_prefix`这种Channel。当然了，我们测着玩嘛。

这里，我们需要一个真正的呼叫字符串。其实，在默认的配置中，精简一下，它是这么做的：

```xml
<param name="dial-string" value="${sofia_contact(1007@${dialed_domain})}"/>
```

如果使用`originate user/prefix &echo`，则用户1007就会振铃。

是的，上述`originate命令中，`prefix`已经定死了，它就是`prefix`这个用户。那么，为了将真正的被叫号码传递进来，我们就需要一个通道变量，好了，我们这样配：

```xml
<param name="dial-string" value="${sofia_contact(${prefix}@${dialed_domain})}"/>
```

然后，就可以使用下面的方式呼叫了：

    originate {prefix=1007}user/prefix &echo
    originate {prefix=1006}user/prefix &echo

即，第一个`prefix`是一个通道变量，而第二个`prefix`是一个用户的配置文件。通过后者将找到`prefix`用户的`dial-string`，在`dial-string`中将进行变量替换，将`${prefix}`替换为`1006`、`1007`，或任何你在命令行上输入的其它值。

除`prefix`外，`sofia_contact`是一个API，它用于找到真正的SIP用户注册消息中的`Contact`字符串。

那么，这里除了`sofia_contact`，还有没有其它API可以用呢？答案是肯定的，任何API都可以用在这里，只要产生的字符串是有意义的。

我们还真找到一个有实际意义的。

FreeSWITCH中有一个模块叫`mod_prefix`。这个模块默认是不加载的，需要手工编译加载一下。

`autoload_configs/prefix.conf.xml`配置如下：

```xml
<configuration name="prefix.conf">
  <tables>
    <table name="gw" file="/usr/local/freeswitch/conf/prefix/testgw.json"/>
  </tables>
</configuration>
```

该模块在加载时会加载多个表（`table`），每个表对应一个JSON格式的文件。上述配置中我们配置了一个名为`gw`的表，内容如下：

```json
{
    "130": "sofia/gateway/chinaunicom/",
    "186": "sofia/gateway/chinaunicom/",
    "138": "sofia/gateway/chinamobile/",
    "139": "sofia/gateway/chinamobile/",
    "133": "sofia/gateway/chinatelecom/",
    "189": "sofia/gateway/chinatelecom/",
    "1860535": "sofia/gateway/test/"
}
```

上述JSON中其实就包含了一个对像，其中对像的属性配置了号码和网关的对应关系。

加载`mod_prefix`后，可以先测试一下：

    freeswitch> prefix get gw 13012345678
    sofia/gateway/chinaunicom/
    freeswitch> prefix get gw 13912345678
    sofia/gateway/chinamobile/
    freeswitch> prefix get gw 18612345678
    sofia/gateway/chinaunicom/
    freeswitch> prefix get gw 18605350000
    sofia/gateway/test/

该模块使用最大号长匹配，返回匹配的值所对应的字符串。如果读到这里还不明白的话，可以用不同的手机号试一下上面的例子。

该模块实现了一个`prefix` API，可以用于最大号长匹配的查询。

好了，我们把`prefix`用户的呼叫字符串改成如下形式：

```xml
<param name="dial-string" value="${prefix(get gw ${prefix})}${dialed_user}"/>
```

发几个呼叫玩玩：

```bash
freeswitch> originate {prefix=13900000000}user/prefix &echo
[ERR] mod_sofia.c:4520 Invalid Gateway 'chinamobile'

freeswitch> originate {prefix=18600000000}user/prefix &echo
[ERR] mod_sofia.c:4520 Invalid Gateway 'chinaunicom'

freeswitch> originate {prefix=18605350000}user/prefix &echo
[ERR] mod_sofia.c:4520 Invalid Gateway 'test'
```

从上述日志中可以看出，我们的呼叫全部失败了。那是因为我们只是在做实验并没有实际创建那些Gateway。但是，从出错信息看它确实生成了正确的指向Gateway的字符串。

课后作业：我们说`prefix`有时是一个用户，有时是一个通道变量，有时还是一个API，你都能正确地找到它们吗？


## `leg_timeout`是怎么工作的？

> Seven

FreeSWITCH呼叫字符串可以用“`|`”隔开实现顺振，并可以通过`leg_timeout`控制第一路由的超时时间，如：

```
freeswitch> originate [leg_timeout=20]sofia/gateway/gw1/$dest_number|sofia/gateway/gw2/$dest_number
```


那这个20秒超时跟什么有关呢？我们做了一个实验：

### 对方不返回100 Trying

```

freeswitch> bgapi originate [leg_timeout=20]sofia/internal/test@192.168.7.7|sofia/internal/test@sipsip.cn &echo

send 1397 bytes to udp/[192.168.7.7]:5060 at 13:30:44.174430:
   INVITE sip:test@192.168.7.7 SIP/2.0

send 1393 bytes to udp/[121.40.231.235]:5080 at 13:31:05.038922:
   INVITE sip:test@sipsip.cn SIP/2.0
```

其中，我们让超时时长为20秒，并且`192.168.7.7`是一个不通的IP地址，因此，第一个INVITE不会有任何响应，FreeSWITCH发送第二个INVITE的时间大约是20秒后。

### 返回100 Trying，但不返回180

为了能让对方返回100 Trying但不返回180，可以在对端FS上构造如下路由：

```xml
   <extension name="test">
    <condition field="destination_number" expression="^sleep(.*)$">
      <action application="sleep" data="$1"/>
    </condition>
   </extension>
```

接下来我们呼叫对端的FS `192.168.7.6`，对端会`sleep` 30秒后再返回：


```
bgapi originate [leg_timeout=20]sofia/internal/sleep30000@192.168.7.6|sofia/internal/test@sipsip.cn &echo


send 1439 bytes to udp/[192.168.7.6] at 13:42:41.362829:
   INVITE sip:sleep30000@192.168.7.6 SIP/2.0

recv 400 bytes from udp/[192.168.7.6] at 13:42:41.363968:
   SIP/2.0 100 Trying

send 388 bytes to udp/[192.168.7.6] at 13:43:02.020060:
   CANCEL sip:sleep30000@192.168.7.6 SIP/2.0

send 1393 bytes to udp/[121.40.231.235]:5080 at 13:43:02.040098:
   INVITE sip:test@sipsip.cn SIP/2.0
```

可以看出，FreeSWITCH在20秒后发了CANCEL终止了请求，并向第二个服务器`sipsip.cn`发起请求。


### 让对端返回180，然后30s内不返回任何其它消息

把们把对端的Dialplan修改如下：


```xml
      <action application="ring_ready" data=""/>
      <action application="sleep" data="$1"/>
```

```
send 1719 bytes to udp/[192.168.7.6] at 13:52:27.392158:
   INVITE sip:sleep30000@192.168.7.6 SIP/2.0

recv 400 bytes from udp/[192.168.7.6] at 13:52:27.395370:
   SIP/2.0 100 Trying

recv 1035 bytes from udp/[192.168.7.6] at 13:52:27.426464:
   SIP/2.0 180 Ringing

send 388 bytes to udp/[192.168.7.6] at 13:52:48.018667:
   CANCEL sip:sleep30000@192.168.7.6 SIP/2.0

send 1393 bytes to udp/[121.40.231.235]:5080 at 13:52:48.109543:
   INVITE sip:test@sipsip.cn SIP/2.0
```

可见，FreeSWITCH即使收到了180，也会在20秒后发送CANCEL。

FreeSWITCH只会在收到183（SDP）或200后才认为呼叫成功，不再尝试第二路由。读者可以自行尝试一下。

## IP对接ACL

> Seven

在《FreeSWITCH互联互通》中讲过很多IP对接方式，但在实际环境中，对IP也需要认证，也就是说，你不仅知道哪些IP是可信的，更需要将这些IP关联到一个用户，以便对其进行计费、审计等。

其实FreeSWITCH中已经有这样的认证机制。在用户目录中创建一个特殊用户，如，假设你的客户是`seven`：

```xml
<include>
  <user id="seven" cidr="192.168.3.119/32">
    <params>
    </params>
    <variables>
      <variable name="accountcode" value="seven"/>
      <variable name="user_context" value="default"/>
      <variable name="effective_caller_id_name" value="seven"/>
      <variable name="effective_caller_id_number" value="seven"/>
    </variables>
  </user>
</include>
```

上述配置跟一般用户配置的区别就是多了一个`cidr`属性。CIDR是一种IP地址的表示方式，格式是“IP/掩码位数”，上述表示仅表示一个IP地址，如果写成“`192.168.3.119/24`”则表示整个“`192.168.3.0`”地址段。

配置好以后，在FreeSWITCH中执行`reloadacl`，你可以看到类似以下的输出：

```
[NOTICE] switch_utils.c:545 Adding 192.168.3.119/32 (allow) [seven@192.168.3.119] to list domains
```

打个电话试试，所有来自“`192.168.3.119`”这个地址的呼叫都认为是`seven`发起的呼叫，不再进行Challenge验证：

```
[DEBUG] sofia.c:9715 IP 192.168.3.119 Approved by acl "domains[seven@192.168.3.119]". Access Granted.
```

当然，如果你想让对方透传主、被叫号码，只需把`effective_caller_id_name/number`注释掉就可以了。此外，你还可以将`user_context`设置成其它的值，让它走专门的路由（Dialplan Context）。

SIP对接，就是这么简单。
