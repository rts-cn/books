# 503-ERROR问题解决方案

在日常维护中，有一次，我们收到客户电话求助，对方突然出现多部电话拨打失败，从日志及抓包发现提示503。根据往常经验认为是同一时间段同时发起呼叫量过多，因此首先查看了并发量。

## 解决过程

### 初期

抓包通过`wireshark`分析发现FS回了503，高峰期时在服务器上查询sps发现超额，初步认为sps问题。需通过FS日志确认，下载日志后对比抓包信息发现对不上，故无法确定原因。

### 中期

修改日志问题m

查询`logfile`配置文件，发现其`map`中含`debug,info,notice,warning,err,crit,alert`。

为了查看更多信息，在`map`加上`console`或在后台执行`sofia tracelevel info`

开启`sofia global siptrace on`获取更多信息。

### 排除sps

通过sip信息发现，回复的503含Service Unavailable ，而sps应该是 `SIP/2.0 503 Maximum Calls In Progress` ,排除sps。

## 后期解决

抓包，看pcap里有相当多的比例503（Service Unavailable），但都没有User-Agent头域（FS发往往都会有user agent），且pcap跟日志都对不上。而且日志太大不便于定位。

开启新日志：

```
fsctl send_sighup

```

重现问题，然后再次开启新日志

```
fsctl send_sighup

```

这样产生的日志文件就比较“干净”。通过分析日志，找到了`503 SIP`信息。但没有`FreeSWITCH`相关的日志，怀疑问题出在libsofia底层。开启

sofia loglevel all 9

抓包及日志对比，排出sps问题的方式为：

发现日志中有如下内容：

```
nta.c:2994 agent_recv_request() nta: proceeding queue full for INVITE (1)

```
至此，应该是libsofia底层队列满导致异常。至于具体原因很难定位，FreeSWITCH已稳定运行数年这是第一次遇到。重启FreeSWITCH，继续观察。


### 解决方案

确保将通话先移至其他服务器，对故障服务器执行`reload mod_sofia`或重启`FreeSWITCH`.

### 遗留问题

在生产上日志太多不便于定位。因此，应尽量缩小日志范围，而且需要确保日志中有`uuid`。

### 测试通话

测试各种通话是否正常

### 故障报告

总结问题

## 总结

该问题出在libsofia底层，普通的日志中也看不到异常，只能开启libsofia本身的log才能发现。











