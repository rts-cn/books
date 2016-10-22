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

    freeswitch> originate {prefix=13900000000}user/prefix &echo
    [ERR] mod_sofia.c:4520 Invalid Gateway 'chinamobile'

    freeswitch> originate {prefix=18600000000}user/prefix &echo
    [ERR] mod_sofia.c:4520 Invalid Gateway 'chinaunicom'

    freeswitch> originate {prefix=18605350000}user/prefix &echo
    [ERR] mod_sofia.c:4520 Invalid Gateway 'test'

从上述日志中可以看出，我们的呼叫全部失败了。那是因为我们只是在做实验并没有实际创建那些Gateway。但是，从出错信息看它确实生成了正确的指向Gateway的字符串。

课后作业：我们说`prefix`有时是一个用户，有时是一个通道变量，有时还是一个API，你都能正确地找到它们吗？
