## FreeSWITCH与Android终端的通信

### 前言

FreeSWITCH是软交换平台系统，Android是终端设备的操作系统，表面上看，两者并没有直接联系，是完全独立两个系统。然而，FreeSWITCH近年来发展迅速，已经成为主流的电话软交换解决方案；而Android在占据了超过80%智能手机市场份额的同时，由于其高度的开源和可扩展性，也在各类终端设备上（平板、电视、车载、可穿戴、机器人、游戏机...）迅速普及开来。因此，以Android操作系统为基础开发SIP终端可谓是大势所趋，Android与FreeSWITCH之间如何进行音视频通信是FreeSWITCH终端开发人员所必须要面对的问题。

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


### BareSIP

由于开源栈较多，就不详细介绍了，感兴趣的可以自行研究，我们这里主要描述下如何基于BareSIP编写Android软电话应用。

BareSIP官方虽然也有和Android相关的文档说明，其对Android开发者而言相当不友好，虽然也有简单的Demo，但是文档描述很少，也很难应用到生产环境中，如果想基于此快速将BareSIP整合到应用中并进行二次开发，也是比较困难的。因此，这里会一步一步讲述如何基于BareSIP来编写一个Android软电话应用。

##### 新建项目

首先，在Android Studio中新建带有Native C++的项目，这样创建完成后，IDE会自动生成原生代码的Demo和一个简单的JNI框架。

##### 项目引入BareSIP

通过BareSIP官网可以了解到，在编译BareSIP时，必须先构建re、rem、openssl三个库。

将BareSIP引入到项目中有两种方式，一种是直接引入所有需要的静态库，另一种是直接引入源代码并通过Android Studio进行编译，为了方便后期浏览源代码并基于BareSIP进行二次开发，我们选择后者的形式将相关库引入到项目中。

目前Android Studio编译原生代码普遍采用CMake进行构建，因此一下会涉及到一些CMake相关知识，没有接触过CMake的读者可以先自行阅读下[Android NDK的CMake文档](https://developer.android.google.cn/ndk/guides/cmake)或者访问[CMake官网](https://cmake.org)来了解一下。

###### 获取源代码

baresip：https://github.com/alfredh/baresip

re：https://github.com/creytiv/re

rem：https://github.com/creytiv/rem

openssl：https://github.com/openssl/openssl

###### 引入代码和静态库到项目中

源代码可以直接复制到项目中，最终目录类似下面的形式：

```
app
  -src
    -main
      -cpp
        -baresip (baresip源代码)
        -re (re源代码)
        -rem (rem源代码)
        -openssl (openssl源代码)
        -baresiplib (JNI接口本地实现，衔接baresip和上层应用，也可以用其他方式实现)
        -CMakeLists.txt （根目录的CMake构建脚本）
```

先在根目录下的CMakeLists.txt引入子目录

```
cmake_minimum_required(VERSION 3.4.1)

add_subdirectory(openssl)
add_subdirectory(re)
add_subdirectory(rem)
add_subdirectory(baresip)
add_subdirectory(baresiplib)
```

之后在cpp下的每个子模块下分别创建CMakeLists.txt文件并编写构建规则，如下
```
app
  -src
    -main
      -cpp
        -baresip (baresip源代码)
          -CMakeLists.txt
        -re (re源代码)
          -CMakeLists.txt
        -rem (rem源代码)
          -CMakeLists.txt
        -openssl
          -CMakeLists.txt
        -baresiplib (JNI接口本地实现，衔接baresip和上层应用，也可以用其他方式实现)
          -CMakeLists.txt
        -CMakeLists.txt （根目录的CMake构建脚本）
```
然后在编写每个子模块下的CMakeLists.txt

**openssl**

openssl源代码是Makefile方式构建，因此我们需要手动编写CMakeLists.txt

```
cmake_minimum_required(VERSION 3.4.1)

include_directories(include)

file(GLOB_RECURSE SRC_FILES "*.c")
file(GLOB_RECURSE HEADER_FILES "*.h")

add_library(libopenssl STATIC ${SRC_FILES} ${HEADER_FILES})
```

**re**

在re源代码的mk目录下有CMakeLists.txt文件，但是直接引用可能无法在Android Studio中进行编译，因此我们需要修改或者直接新建一个CMakeLists.txt，注意编译re需要引用openssl头文件


```
cmake_minimum_required(VERSION 3.4.1)

include_directories(include)
include_directories(../openssl/include)

file(GLOB_RECURSE SRC_FILES "src/*.c")
file(GLOB_RECURSE HEADER_FILES src/*.h include/*.h)

# 移除在Android系统上不需要的源文件
LIST(REMOVE_ITEM SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/aes/apple/aes.c")
LIST(REMOVE_ITEM SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/dns/darwin/srv.c")
LIST(REMOVE_ITEM SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/dns/win32/srv.c")
LIST(REMOVE_ITEM SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/dns/res.c")
LIST(REMOVE_ITEM SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/hmac/apple/hmac.c")
LIST(REMOVE_ITEM SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/lock/win32/lock.c")
LIST(REMOVE_ITEM SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/mod/win32/dll.c")
LIST(REMOVE_ITEM SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/mqueue/win32/pipe.c")
LIST(REMOVE_ITEM SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/net/win32/wif.c")

add_library(re STATIC ${SRC_FILES} ${HEADER_FILES})
```

**rem**

编译rem需要引用re的头文件


```
include_directories(include)
include_directories(../re/include)

file(GLOB_RECURSE SRC_FILES "src/*.c")
file(GLOB_RECURSE HEADER_FILES src/*.h include/*.h)

add_library(rem STATIC ${SRC_FILES} ${HEADER_FILES})
```

**baresip**

编译baresip需要引用re、rem的头文件，这里没有引入baresip中的模块代码


```
cmake_minimum_required(VERSION 3.4.1)

include_directories(include)
include_directories(../re/include)
include_directories(../rem/include)

file(GLOB_RECURSE SRC_FILES "src/*.c")
file(GLOB_RECURSE HEADER_FILES src/*.h include/*.h)

add_library(baresip STATIC ${SRC_FILES} ${HEADER_FILES})
```

**baresiplib**

上述的几个模块都编译为静态库，而baresiplib是我们提供给上层APP在运行时使用的接口模块，因此要编译成动态库，且链接上述编译的几个静态库


```
cmake_minimum_required(VERSION 3.4.1)

include_directories(../baresip/re)
include_directories(../baresip/rem)
include_directories(../baresip/include)

add_library(
        baresip-lib
        SHARED
        baresip-lib.cpp)

target_link_libraries(
        baresip-lib
        log
        libcrypto
        libssl
        re
        rem
        baresip)
```

###### 编译

CMake脚本编写完成后可直接编译，如果有编译错误问题可以根据具体问题进行修改，编译成功后可以在编译输出文件的目录下找到编译好的baresip、openssl、re、rem等静态库，如下：

```
app
  -.externalNativeBuild
    -cmake
      -debug
        -arm64-v8a
          -baresip
            -libbaresip.a
            ...
            ...
            ...
```

### 色彩模式和视频编解码

---

FreeSWITCH可以使用视频通信功能，一个简单的视频会议的处理流程如下：

```
客户端调用摄像头获取视频画面 → 视频编码压缩 → 视频打包传输至服务器
→ 服务器处理所有客户端发送来的画面（融屏、字幕、重新编码等）→ 服务器下发视频数据流
→ 客户端缓冲视频数据 → 视频解码 → 播放视频
```

在整个流程中，获取视频画面、编解码、播放视频这些工作BareSIP并没有提供现成的或者完整的接口，需要我们自己处理，因此，首先需要了解一些色彩模式和视频编解码的基础知识，如果已经充分了解的读者可以略过本章节。

#### 色彩模式

在Android中，常用的色彩模式有RGB和YUV两大类，RGB相对来说比较简单也容易理解，R表示红色Red，G表示绿色Green，B表示蓝色Blue，三个颜色通道叠加后可以组成各种各样的颜色；YUV来源于RGB，Y表示亮度，UV表示色度，也就是像素的颜色，YUV细分的话有Y'UV，YUV，YCbCr，YPbPr等格式，目前在计算机上使用的主要是YCbCr，因此说起YUV时主要指的是YCbCr（本文后续均称YUV），Cb表示蓝色浓度偏移量，Cr表示红色浓度偏移量。

##### RGB

因此RGB比较好理解，因此我们先来介绍下android.graphics.Bitmap的Config枚举中定义的几个颜色通道

- RGB_565：每个像素点由2个字节（16位）组成，其中前5位表示红色，中间16为表示绿色，后5位表示蓝色

- ARGB_4444：每个像素点由2个字节（16位）组成，其中前4位为透明度(Alpha)，后面4位为红色，接着4位为绿色，最后4位蓝色。由于图像质量低，目前已被标记为弃用

- ARGB_8888：每个像素点由4个字节（32位）组成，组成方式和ARGB_4444类似，只是每个变量均有8位

除了以上三种之外，android.graphics.PixelFormat中还有一种常见的RGB模式

- RGB_888：每个像素点由3个字节（24位）组成，红绿蓝各占8位

##### YUV

YUV模式是利用人眼对亮度敏感而对色度相对不敏感的特点，通过缩减色度采样以减少数据量，并且图像质量不会明显下降的色彩模式，其在采样时会保留每个像素的Y分量，但会适当丢弃UV分量，数据量通常会比RGB要小，因此常用于视频传输。YUV按照采样方式通常分为YUV444、YUV422、YUV420、YUV411，按照存储方式可分为Planar、Packed、SemiPlanar，而Y、U、V每个通道变量通常可以为8位、10位、16位，不同的组合方式也使YUV出现了各种各样的类型。

采样模式

- YUV444：没有缩减色度采样，每4个像素中有4个Y分量、4个U分量、4个V分量；平均每个像素3个字节（24位），相比于RGB几乎没有压缩

- YUV422：每4个像素中有4个Y分量、2个U分量、2个V分量，在采样时相邻两个像素一个丢弃U分量，一个丢弃V分量；平均每个像素2个字节（16位）

- YUV420：每4个像素中有4个Y分量、1个U分量、1个V分量，在采样时相邻两个元素丢弃一个U分量，下一行的该位置的两个元素丢弃一个V分量；平均每个像素大小为1.5个字节（12位）

- YUV411：和YUV420一样，每4个像素中有4个Y分量、1个U分量、1个V分量，在采样时每行相邻4个元素丢弃3个U分量和3个V分量；大小和YUV420相同，使用该模式的很少因此后面不再赘述

存储方式

- Packed：连续存储每个像素点的Y、U、V分量，丢弃的分量不存储
    - YUV422形如YUYV YUYV YUYV YUYV
    - YUV420形如YUYYUY YVYYVY
- Planar：先存储所有像素点的Y分量，再存储所有像素点的U分量，最后存储所有像素点的V分量，
    - YUV422形如YYYYYYYY UUUU VVVV 
    - YUV420形如YYYYYYYY UU VV
- SemiPlanar：先存储所有像素点的Y分量，再交错存储U、V分量
    - YUV422形如YYYYYYYY UVUVUVUV
    - YUV420形如YYYYYYYY UVUV

PS：微软文档中只看到了Planar和Packed，Android中有见到SemiPlanar，出处暂时不得而知，这里暂时将其加入到存储模式分类中

###### YUV色彩模式汇总

色彩模式 | 采样方式 | 存储方式 | 单通道占据位数 | 示意
:-:|:-:|:-:|:-:|:-:
AYUV | 4:4:4 | Packed | 8
Y410 | 4:4:4 | Packed | 10
Y416 | 4:4:4 | Packed | 16
YUY2 | 4:2:2 | Packed | 8
Y210 | 4:2:2 | Packed | 10
Y216 | 4:2:2 | packed | 16
P210 | 4:2:2 | Planar | 10
P216 | 4:2:2 | Planar | 16
I422(YUV422P) | 4:2:2 | Planar | 8 | YYYY UU VV
YV16 | 4:2:2 | Planar | 8 | YYYY VV UU
NV16(YUV422SP) | 4:2:2 | SemiPlanar | 8 | YYYY UV UV
NV61 | 4:2:2 | SemiPlanar | 8 | YYYY VU VU
NV11 | 4:1:1 | Planar | 8
P010 | 4:2:0 | Planar | 10
P016 | 4:2:0 | Planar | 16
YU12(I420/YUV420P) | 4:2:0 | Planar | 8 | YYYYYYYY UU VV
YV12 | 4:2:0 | Planar | 8 | YYYYYYYY VV UU
NV12(YUV420SP) | 4:2:0 | SemiPlanar | 8 | YYYYYYYY UV UV
NV21 | 4:2:0 | SemiPlanar | 8 | YYYYYYYY VU VU

##### 小结

在android.media.MediaCodecInfo中的CodecCapabilities定义了很多硬编解码时需要用到的RGB和YUV色彩模式，了解了以上RGB和YUV知识后，再看CodecCapabilities中的色彩模式定义应该也不会那么陌生了。