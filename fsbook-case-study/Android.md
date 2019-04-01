## FreeSWITCH与Android终端的通信

### 前言

FreeSWITCH是软件换平台系统，Android是终端设备的操作系统，表面上看，两者并没有直接联系，是完全独立两个系统。然而，FreeSWITCH近年来发展迅速，已经成为主流的电话软交换解决方案；而Android在占据了超过80%智能手机市场份额的同时，由于其高度的开源和可扩展性，也在各类终端设备上（平板、电视、车载、可穿戴、机器人、游戏机...）迅速普及开来。因此，以Android操作系统为基础开发SIP终端可谓是大势所趋，Android与FreeSWITCH之间如何进行音视频通信是FreeSWITCH终端开发人员所必须要面对的问题。

FreeSWITCH是基于SIP协议的软交换平台，在Android设备上我们也需要基于SIP协议开发终端应用以和FreeSWITCH进行通信。但是作为普通的开发者，从上层界面到底层SIP协议来编写一个软电话应用，不仅工作量大，而且也比较困难，因此，我们完全可以借鉴当前比较好的开源SIP用户端库，再基于此编写Android软电话应用，下面先简单介绍和对比下当前可用于Android系统的SIP开源库。


### Android SIP开源库介绍

###### Android原生API

这是Android 2.3版本推出的用于支持SIP通信的API，并且有详细的[说明文档](https://developer.android.google.cn/guide/topics/connectivity/sip.html)，根据文档描述，这个API包含完整的SIP协议栈，并且集成到了通话管理服务中。

优点：集成使用简单方便；该服务运行于通话管理服务中，不可能被系统回收或杀掉，避免了应用长时间未使用被系统强制断开网络连接或直接杀掉而导致无法接收来电通知的情况。

缺点：功能单一，仅支持语音通话，不可扩展；该功能在绝大多数手机上被阉割或只能在WIFI条件下使用，笔者试了小米、OPPO、VIVO等几款手机均无法正常使用。

如果我们需要做一款针对特定Android设备、只需要语音通话功能的软电话应用，且该设备完整支持该API，那么该方案无疑是最佳选择；但是在绝大多数其他场景下，这套API只能作为一个参考。

###### PJSIP

[PJSIP](https://www.pjsip.org/)是一个开源的SIP库，支持SIP，SDP，RTP，STUN，TURN，ICE等协议，支持音视频通信及信息收发，功能比较全，但是[Android的参考文档](https://trac.pjsip.org/repos/wiki/Getting-Started/Android)相对比较少。

Android开源项目：

[CSipSimple（APK的DEMO项目）](https://github.com/r3gis3r/CSipSimple)：该项目目前已经停止更新维护

###### MjSip

MjSip是基于java的SIP开源栈，完整地支持了SIP协议，但是已经于2012年停止维护，目前只有参考价值，实用意义不大。

Android开源项目:

[Sipdroid](https://github.com/i-p-tel/sipdroid)：目前已经停止维护。

[Lumicall](https://github.com/opentelecoms-org/lumicall)：基于Sipdroid开发的，支持ZRTP，但目前也已经停止维护。

###### Belle-SIP

[Belle-sip](https://github.com/BelledonneCommunications/belle-sip)也是一个基础的SIP库，支持的功能比较多，Linphone也是基于该库开发的，目前持续维护中。

Android开源项目：

[linphone-android](https://github.com/BelledonneCommunications/linphone-android)

###### baresip

[baresip](https://github.com/alfredh/baresip)也是一个支持功能比较多的SIP开源库，目前也在持续更新和维护中，可用于实际应用开发.

Android开源项目：

[baresip-studio](https://github.com/juha-h/baresip-studio)