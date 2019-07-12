## 使用lua模拟自动播报工号功能

> 2016-11-1/RunX

问题提出：对于从呼叫中心`Callcenter`分配到坐席的电话，电话接起后需要先向主叫播报一下工号。  

###修改callcenter.conf的配置

首先想到的是通过`execute_on_answer`在接听时执行一个动作。为此修改`callcenter.conf.xml`配置文件如下： 
 
**添加队列**

```xml
<queues>
	<queue name="cc1234@default">
		<param name="strategy" value="round-robin"/>
		<param name="moh-sound" value="$${hold_music}"/>
		<param name="time-base-score" value="system"/>
		<param name="max-wait-time" value="0"/>
		<param name="max-wait-time-with-no-agent" value="0"/>
		<param name="max-wait-time-with-no-agent-time-reached" value="5"/>
		<param name="tier-rules-apply" value="false"/>
		<param name="tier-rule-wait-second" value="300"/>
		<param name="tier-rule-wait-multiply-level" value="true"/>
		<param name="tier-rule-no-agent-no-wait" value="false"/>
		<param name="discard-abandoned-after" value="60"/>
		<param name="abandoned-resume-allowed" value="false"/>
	</queue>
</queues>
```

**添加坐席**

```xml
<agents>  
	<agent name="81000" type="callback" contact="[call_timeout=60,execute_on_answer='lua sayNumber.lua']user/1000"
	       status="Available" max-no-answer="3" wrap-up-time="10" reject-delay-time="10" busy-delay-time="30" />
</agents>
```  

**绑定坐席**

```xml
<tiers>
	<tier agent="81000" queue="cc1234@default" level="1" position="1"/> 
</tiers>
```  

通过上面的修改，就已经创建好了一个简单的呼叫中心队列cc1234，并添加一个坐席8100到队列中。

### 修改拨号计划

在拨号计划`default.xml`中添加一个`Extension`，当呼叫1234时转到呼叫中心去。

```xml
<extension name="test-cc">
	<condition field="destination_number" expression="^(1234)$">
		<action application="answer"/>
		<action application="callcenter" data="cc${destination_number}@default"/>
	</condition>
</extension>
```

###编写语音播报脚本

语音播报首先想到的是使用`playback`，测试后发现只有坐席人员能听到声音，而呼叫者听不到，达不到原来的要求。  
通过`session:bridged`发现原来两个通道还为桥接在一起，呼叫者当然无法听到声音了，为此使用`uuid_broadcast`直接给呼叫者的通道播放声音，具体脚本如下：

```lua
session:setAutoHangup(false)

local opUuid = session:getVariable("cc_member_session_uuid")
local theAgent = session:getVariable("cc_agent")

session:consoleLog("NOTICE", "The incoming call: " .. theAgent .. " " .. opUuid)

-- sleep to wait the media ready, and play to the Caller
local waitMax = 10
while session:ready()==false and waitMax>0 do
	waitMax = waitMax - 1
	session:sleep(100)
end

local fsApi = freeswitch.API()
fsApi:execute("uuid_broadcast", opUuid .. " " .. "say::en\\snumber\\siterated\\s" .. theAgent)  
```  

具体流程说明

* 通过`cc_member_session_uuid`获取呼叫者的UUID  
* 通过`cc_agent`获取坐席号码（即前面设定的`8100`）
* 通过`session:ready()`判断是否准备好，可接收媒体了  
* 通过执行`uuid_broadcast`播放工号

修改完成后，重新加载配置，并把脚本保存到`script`目录下，呼叫‘1234’电话就被路由到1000话机上，接听后呼叫方就会听到工号播报了。工号播报部分日志如下：

```bash
switch_ivr_play_say.c:1749 done playing file file_string://digits/8.wav!digits/1.wav!digits/0.wav!digits/0.wav!digits/0.wav
```

以上即为一个简单的工号播报脚本，读者可根据具体情况自由发挥来满足实际的需求。
