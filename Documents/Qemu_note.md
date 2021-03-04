# Qemu学习



## 一 概念介绍

 Qemu架构：

​       Qemu是纯软件实现的虚拟化模拟器，几乎可以模拟任何硬件设备。我们最熟悉的就是能够模拟一台能够队里运行操作系统的虚拟机。 

​       虚拟机认为自己和硬件打交道，但其实是和Qemu模拟出来的硬件打交道，Qemu将这些指令转译给真正的硬件。

​      正因为Qemu是纯软件实现的，所有的指令都要经 Qemu 过一手，性能非常低，所以，在生产环境中，大多数的做法都是配合 KVM 来完成虚拟化工作，因为 KVM 是硬件辅助的虚拟化技术，主要负责 比较繁琐的 CPU 和内存虚拟化，而 Qemu 则负责 I/O 虚拟化，两者合作各自发挥自身的优势，相得益彰。

 

KVM介绍

 KVM即Kernel-Based Virtual Machine 基于内核的虚拟机，是Linux内核的一个可加载模块，通过调用Linux本身内核功能，实现对CPU的底层虚拟化和内存的虚拟化，使Linux内核成为虚拟化层，需要x86架构的，支持虚拟化功能的硬件支持（比如Intel VT，AMD-V），是**一种全虚拟化架构**。KVM在2007年年2月被导入Linux 2.6.20内核中。从存在形式来看，它包括两个内核模块：kvm.ko 和 kvm_intel.ko（或kvm_amd.ko），本质上，KVM是管理虚拟硬件设备的驱动，该驱动使用字符设备/dev/kvm（由KVM本身创建）作为管理接口，主要负责vCPU的创建，虚拟内存的分配，vCPU寄存器的读写以及vCPU的运行。





libvirt

顺带提一提libvirt，这是RedHat开始支持KVM后，大概是觉得QEMU+KVM方案中的用户空间虚拟机管理工具不太好用或者通用性不强，所以干脆搞了个libvirt出来，一个针对各种虚拟化平台的虚拟机管理的API库，一些常用的虚拟机管理工具如virsh（类似vim编辑器），virt-install，virt-manager等和云计算框架平台（如OpenStack，OpenNebula，Eucalyptus等）都在底层使用libvirt提供的应用程序接口。

libvirt主要由三个部分组成：API库，一个守护进程 libvirtd 和一个默认命令行管理工具 virsh。





ARM express 开发板简介

Vexpress系列开发板

（1）全称versatile express family, ARM公司自己推出的开发板。

（2） 主要用于SOC厂商设计、验证和测试自己的SOC芯片。

（3） 采用主板+子板设计，主板提供各种外围接口，子板提供CPU运算。

Vexpress系列支持的CPU

（1）Cortex-A9：处理器子板 Express A9x4 (V2P-CA9x4)

（2）Cortex-A5：处理器子板 Express A5x2 (V2P-CA5x2s)

（3）Cortex-R5：

（4）Cortex-A15：处理器子板 Express A15x2 (V2P-CA15x2)





![img](https://i.loli.net/2021/02/23/U8r4ONZIGHm7euV.png)

开发板的内存映射



![img](https://i.loli.net/2021/02/23/f9TOCQv1FG46nWP.png)

最小系统概念

（1）嵌入式最小系统

（2）CPU+DDR/SDRAM

（3）Flash、SD

（4）串口+LCD

基本配置

（1）内存

（2）LCD

（3）串口





## 二 实验方案：

主机：Ubuntu1804 64位版本

模拟器：Qemu-2.8.0

Uboot版本：u-boot-2021.01.tar.bz2

Linux内核版本：linux-5.11.tar.xz

BusyBox版本：busybox-1.33.0.tar.bz2

交叉编译工具链：gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi.tar.xz

编译目标： vexpress 的arm v7 的 Cotex A9   即vexpress_ca9x4_defconfig 



mkdir -p qemu/test1/



### 2.1 下载Qemu

http://www.qemu-project.org

编译依赖比较多的库与软件

编译完成可以通过

```shell
qemu-system-arm -M help
Supported machines are: 
akita                Sharp SL-C1000 (Akita) PDA (PXA270)                                
ast2500-evb          Aspeed AST2500 EVB (ARM1176)                                       
ast2600-evb          Aspeed AST2600 EVB (Cortex A7)                                     
borzoi               Sharp SL-C3100 (Borzoi) PDA (PXA270)                               
canon-a1100          Canon PowerShot A1100 IS                                           
cheetah              Palm Tungsten|E aka. Cheetah PDA (OMAP310)                         
collie               Sharp SL-5500 (Collie) PDA (SA-1110)                               
connex               Gumstix Connex (PXA255)                                            
cubieboard           cubietech cubieboard (Cortex-A8)                                   
emcraft-sf2          SmartFusion2 SOM kit from Emcraft (M2S010)                         
highbank             Calxeda Highbank (ECX-1000)                                        
imx25-pdk            ARM i.MX25 PDK board (ARM926)                                      
integratorcp         ARM Integrator/CP (ARM926EJ-S)                                     
kzm                  ARM KZM Emulation Baseboard (ARM1136)                              
lm3s6965evb          Stellaris LM3S6965EVB                                              
lm3s811evb           Stellaris LM3S811EVB                                               
mainstone            Mainstone II (PXA27x)                                              
mcimx6ul-evk         Freescale i.MX6UL Evaluation Kit (Cortex A7)                       
mcimx7d-sabre        Freescale i.MX7 DUAL SABRE (Cortex A7)                             
microbit             BBC micro:bit                                                      
midway               Calxeda Midway (ECX-2000)                                          
mps2-an385           ARM MPS2 with AN385 FPGA image for Cortex-M3                       
mps2-an386           ARM MPS2 with AN386 FPGA image for Cortex-M4                       
mps2-an500           ARM MPS2 with AN500 FPGA image for Cortex-M7                       
mps2-an505           ARM MPS2 with AN505 FPGA image for Cortex-M33                      
mps2-an511           ARM MPS2 with AN511 DesignStart FPGA image for Cortex-M3           
mps2-an521           ARM MPS2 with AN521 FPGA image for dual Cortex-M33                 
musca-a              ARM Musca-A board (dual Cortex-M33)                                
musca-b1             ARM Musca-B1 board (dual Cortex-M33)                               
musicpal             Marvell 88w8618 / MusicPal (ARM926EJ-S)                            
n800                 Nokia N800 tablet aka. RX-34 (OMAP2420)                            
n810                 Nokia N810 tablet aka. RX-44 (OMAP2420)                            
netduino2            Netduino 2 Machine                                                 
netduinoplus2        Netduino Plus 2 Machine                                            
none                 empty machine                                                      
npcm750-evb          Nuvoton NPCM750 Evaluation Board (Cortex A9)                       
nuri                 Samsung NURI board (Exynos4210)                                    
orangepi-pc          Orange Pi PC                                                       
palmetto-bmc         OpenPOWER Palmetto BMC (ARM926EJ-S)                                
quanta-gsj           Quanta GSJ (Cortex A9)                                             
raspi0               Raspberry Pi Zero (revision 1.2)                                   
raspi1ap             Raspberry Pi A+ (revision 1.1)                                     
raspi2               Raspberry Pi 2B (revision 1.1) (alias of raspi2b)                  
raspi2b              Raspberry Pi 2B (revision 1.1)                                     
realview-eb          ARM RealView Emulation Baseboard (ARM926EJ-S)                      
realview-eb-mpcore   ARM RealView Emulation Baseboard (ARM11MPCore)                     
realview-pb-a8       ARM RealView Platform Baseboard for Cortex-A8                      
realview-pbx-a9      ARM RealView Platform Baseboard Explore for Cortex-A9              
romulus-bmc          OpenPOWER Romulus BMC (ARM1176)                                    
sabrelite            Freescale i.MX6 Quad SABRE Lite Board (Cortex A9)                     
smdkc210             Samsung SMDKC210 board (Exynos4210)                                   
sonorapass-bmc       OCP SonoraPass BMC (ARM1176)                                          
spitz                Sharp SL-C3000 (Spitz) PDA (PXA270)                                   
supermicrox11-bmc    Supermicro X11 BMC (ARM926EJ-S)                                       
swift-bmc            OpenPOWER Swift BMC (ARM1176)                                         
sx1                  Siemens SX1 (OMAP310) V2                                              
sx1-v1               Siemens SX1 (OMAP310) V1                                              
tacoma-bmc           OpenPOWER Tacoma BMC (Cortex A7)                                      
terrier              Sharp SL-C3200 (Terrier) PDA (PXA270)                                 
tosa                 Sharp SL-6000 (Tosa) PDA (PXA255)                                     
verdex               Gumstix Verdex (PXA270)                                               
versatileab          ARM Versatile/AB (ARM926EJ-S)                                         
versatilepb          ARM Versatile/PB (ARM926EJ-S)                                         
vexpress-a15         ARM Versatile Express for Cortex-A15                                  
vexpress-a9          ARM Versatile Express for Cortex-A9                                   
virt-2.10            QEMU 2.10 ARM Virtual Machine                                         
virt-2.11            QEMU 2.11 ARM Virtual Machine                                         
virt-2.12            QEMU 2.12 ARM Virtual Machine                                         
virt-2.6             QEMU 2.6 ARM Virtual Machine                                          
virt-2.7             QEMU 2.7 ARM Virtual Machine                                          
virt-2.8             QEMU 2.8 ARM Virtual Machine                                          
virt-2.9             QEMU 2.9 ARM Virtual Machine                                          
virt-3.0             QEMU 3.0 ARM Virtual Machine                                          
virt-3.1             QEMU 3.1 ARM Virtual Machine                                          
virt-4.0             QEMU 4.0 ARM Virtual Machine                                          
virt-4.1             QEMU 4.1 ARM Virtual Machine                                          
virt-4.2             QEMU 4.2 ARM Virtual Machine                                          
virt-5.0             QEMU 5.0 ARM Virtual Machine                                          
virt-5.1             QEMU 5.1 ARM Virtual Machine                                          
virt                 QEMU 5.2 ARM Virtual Machine (alias of virt-5.2)                      
virt-5.2             QEMU 5.2 ARM Virtual Machine                                          
witherspoon-bmc      OpenPOWER Witherspoon BMC (ARM1176)                                   
xilinx-zynq-a9       Xilinx Zynq Platform Baseboard for Cortex-A9                          
z2                   Zipit Z2 (PXA27x)                                                     
```

![image-20210223095714372](https://i.loli.net/2021/02/23/LByTzn2gIblQwue.png)





### 2.2 下载u-boot



https://ftp.denx.de/pub/u-boot/

用到编译命令

 ```makefile
export ARCH=arm  
export CROSS_COMPILE=arm-linux-gnueabi- 
make vexpress_ca9x4_defconfig 
make -j8

 ```







### 2.3 下载kernel

https://www.kernel.org

用到编译命令

```makefile
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabi-
make vexpress_defconfig
make zImage -j8
make modules -j8
make LOADADDR=0x60003000 uImage -j8
make dtbs

```



### 2.4 下载busybox:

https://busybox.net/downloads/

用到编译命令

```makefile
export ARCH=armexport ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabi-
make defconfig
make menuconfig
make -j8
make install
```



### 2.5下载工具链：

清华开源软件镜像站

https://mirrors.tuna.tsinghua.edu.cn/armbian-releases/_toolchain/

arm64位的：gcc-linaro-aarch64-linux-gnu-4.9-2014.07_linux.tar.xz

arm32位的**softfp**: gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi.tar.xz

arm32位的hard: gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf.tar.xz

注：

softfp: armel架构(对应的编译器为gcc-arm-linux-gnueabi)采用的默认值，用fpu计算，但是传参数用普通寄存器传，这样中断的时候，只需要保存普通寄存器，中断负荷小，但是参数需要转换成浮点的再计算。

hard:  armhf架构(对应的编译器gcc-arm-linux-gnueabihf)采用的默认值，用fpu计算，传参数也用fpu中的浮点寄存器传，省去了转换, 性能最好，但是中断负荷高。



本文选择使用

arm32位的**softfp**: gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi.tar.xz



先建立一个文件夹：

mkdir -p  test1



## 三 编译Qemu

 进入编译流程

```shell
cd test1/
tar -xvf  qemu-5.2.0.tar.xz
cd  qemu-5.2.0
ls
```



![image-20210219141942865](https://i.loli.net/2021/02/20/RxfU4Yq8jp5uWOH.png)



编译命令：

```shell
mkdir -p build
mkdir -p /opt/qemu/ #out
cd build
../configure --prefix=/opt/qemu/ --target-list=arm-softmmu,i386-softmmu,x86_64-softmmu,aarch64-linux-user,arm-linux-user,i386-linux-user,x86_64-linux-user,aarch64-softmmu --audio-drv-list=alsa --enable-virtfs --enable-debug
make 
make install  ##如果失败可能是权限不够 需要sudo  make install
#其中--prefix是安装的位置，在执行make install的时候
```

其中--target-list指定需要编译的target(guest)，arm-softmmu表示要编译system mode的QEMU，arm-linux-user表示要编译user mode的QEMU。

显示编译错误1 ：Cannot find Ninja

![image-20210219143944730](https://i.loli.net/2021/02/20/OiRTSvCetIEBrna.png)

安装指令：

```shell
git clone git://github.com/ninja-build/ninja.git
./configure.py --bootstrap
sudo cp ninja /usr/bin
```

![image-20210219144142975](https://i.loli.net/2021/02/20/OqbnvMR3si5S9Wp.png)

显示编译错误2：ERROR: alsa check failed 

![image-20210219144335622](https://i.loli.net/2021/02/20/RvlcISXH7gZCPOm.png)

下载alsa-lib-1.0.26.tar.bz2

https://pan.baidu.com/share/link?shareid=470635&uk=1209563959

```shell
tar -xvf alsa-lib-1.0.26.tar.bz2  
cd alsa-lib-1.0.26/ 
./configure 
make  
sudo make install 
```



显示编译错误3：ERROR: glib-2.48 gthread-2.0 is required to compile QEMU

![image-20210219150515627](https://i.loli.net/2021/02/20/4VWSr67dPqTbfA1.png)



```shell
apt-get install build-essential zlib1g-dev pkg-config libglib2.0-dev binutils-dev libboost-all-dev autoconf libtool libssl-dev libpixman-1-dev libpython-dev python-pip python-capstone virtualenv

```

本地机缺少了：pkg-config libglib2.0-dev binutils-dev  libboost-all-dev autoconf  libpixman-1-dev python-pip python-capstone virtualenv 





显示编译错误4： ERROR:VirtFS requires libcap-ng devel and libattr devel

![image-20210219151921739](https://i.loli.net/2021/02/20/lqwsNbcfZa1EQKR.png)

```shell
sudo apt-get install libcap-dev
sudo apt-get install libcap-ng-dev
```



完成配置：

![image-20210219154322382](https://i.loli.net/2021/02/20/apIHLBs5CJAZX8j.png)

make 进行编译

![image-20210219155502518](https://i.loli.net/2021/02/20/mXALrq926gKc1Gp.png)



make install 安装：

ls /opt/qemu/





## 四 编译u-boot

cd  test1/

tar -xvf u-boot-2021.01.tar.bz2

cd u-boot-2021.01

```shell
export ARCH=arm
export CROSS_COMPILE=$(CURDIR)/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-
make vexpress_ca9x4_defconfig
make menuconfig
make  
```



![image-20210219182815130](https://i.loli.net/2021/02/20/Oi15bhHayVJpUZ2.png)



vexpress-ca9x4是arm公司的模拟开发板ARMv7 版本的 Cotex-A9 

(注：ARMv8的版本例如Contex-A53，其他的 ARMv7  Cotex-A7 Cotex-A8 )

https://developer.arm.com/documentation/dui0448/i/

在完成配置后：make vexpress_ca9x4_defconfig

可以 

vim  ./u-boot-2021.01/.config 配置文件

![image-20210219190539304](https://i.loli.net/2021/02/20/D46zin2eQUGtHqR.png)



参考代码位置：

./u-boot-2021.01/board/armltd

![image-20210219190633137](https://i.loli.net/2021/02/20/ZbORugQ5t7LkyIa.png)

vexpress/Kconfig/

```makefile
if TARGET_VEXPRESS_CA15_TC2

config SYS_BOARD
	default "vexpress"

config SYS_VENDOR
	default "armltd"

config SYS_CONFIG_NAME
	default "vexpress_ca15_tc2"

endif

if TARGET_VEXPRESS_CA5X2

config SYS_BOARD
	default "vexpress"

config SYS_VENDOR
	default "armltd"

config SYS_CONFIG_NAME
	default "vexpress_ca5x2"

endif

if TARGET_VEXPRESS_CA9X4

config SYS_BOARD
	default "vexpress"

config SYS_VENDOR
	default "armltd"

config SYS_CONFIG_NAME
	default "vexpress_ca9x4"

endif

```

在u-boot-2021.01\arch\arm

Kconfig

```makefile
...

config TARGET_VEXPRESS_CA9X4
	bool "Support vexpress_ca9x4"
	select CPU_V7A
	select PL011_SERIAL
	
....
```

Makefile

```

```

主要代码使用

u-boot-2021.01\arch\arm\cpu\armv7

![image-20210219191911334](https://i.loli.net/2021/02/20/9Bac4qKJ8Qn6tGD.png)

注：目前来看猜测使用64位编译应该是

make vexpress64_ca9x4_defconfig

即 make $(borad)\_$(arch_name)\_deconfig



验证测试：

参考命令：

```shell
sudo qemu-system-arm -M vexpress-a9 -m 256 -kernel ./u-boot -nographic
```

由于没有设置环境变量，即/opt/qemu/bin/qemu-system-arm

```shell
/opt/qemu/bin/qemu-system-arm -M vexpress-a9 -m 256 -kernel ./u-boot -nographic
```

注：

-nographic 标识非图形化启动，使用串口作为控制台

参考：https://www.zhaixue.cc/qemu/qemu-param.html

![image-20210219194003148](https://i.loli.net/2021/02/20/DUCRYfw4l1I52dK.png)

检查完成

输入 **ctrl + A 后按 X**  退出 QEMU



![image-20210220130202123](https://i.loli.net/2021/02/20/CbVIhgwaOME4HNv.png)

上面的bootcmd=run distro_bootcmd; run bootflash

![image-20210220131044372](https://i.loli.net/2021/02/20/1kEOLgV9QYT6hub.png)



由上面的情况可以知道

后续修改的位置为

CONFIG_BOOTCOMMAND="run distro_bootcmd; run bootflash"

修改配置的方法有两种

方法一：

```shell
export ARCH=arm
export CROSS_COMPILE=$(CURDIR)/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-
make vexpress_ca9x4_defconfig
make menuconfig
```

直接修改



方法二：

```shell
vim .config
修改
CONFIG_BOOTCOMMAND="run distro_bootcmd; run bootflash"
```



修改引导内核启动的方案有两种（或许不止）：

1 使用nfs：network filesystem ，即uboot通过网络下载kernel和文件系统rootfs（可以整合成一个镜像）

2 使用sd：下载内核镜像和文件系统（或者整合成一个镜像）

后学第七部分制作的时候具体完成。



## 五 编译内核

qemu/test1/linux-5.11/arch/arm/configs

![image-20210219210114384](https://i.loli.net/2021/02/20/8C1yqVkErDIKdTf.png)



```Shell
make vexpress_defconfig ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
```

![image-20210219210415755](https://i.loli.net/2021/02/20/rhyVuksFH1zB2CK.png)



注意:使用make menuconfig 开启

![image-20210219210710798](https://i.loli.net/2021/02/20/4VCk1FdWuewHtSZ.png)

查看 

vi .config

![image-20210219210944049](https://i.loli.net/2021/02/20/M2GuaT9Fib1z43q.png)



make menuconfig

![image-20210219211220797](https://i.loli.net/2021/02/20/eN4HkQlcMo5DzTU.png)

使用网络加载内核镜像

vi .config 

![image-20210219211318877](https://i.loli.net/2021/02/20/2UWZKSDAauGiLpg.png)





进入编译阶段

```shell
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
```

显示编译错误1：

fatal error: gmp.h: No such file or directory

![image-20210219212915508](https://i.loli.net/2021/02/20/KzqvNFV4jtkoR6U.png)



lib/gcc/arm-linux-gnueabi/7.4.1/plugin/include/system.h:687:10: fatal error: gmp.h: No such file or directory

參考：

https://blog.csdn.net/qq_41894567/article/details/89407963?utm_medium=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.control&dist_request_id=03f35d24-fce6-4df6-b622-f485bc6f579a&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.control

sudo apt-get install m4

sudo apt-get install lzip

下载：

https://gmplib.org

![image-20210219215820502](https://i.loli.net/2021/02/20/xORsKXWjJ6h8ioG.png)

tar -xvf gmp-6.2.1.tar.xz

解压gmp，编译软件，并且安装。

./configure

![image-20210219220248047](https://i.loli.net/2021/02/20/mLVwXMberjF3PAy.png)

![image-20210219220308910](https://i.loli.net/2021/02/20/GTao9VAPQ7dm1Lr.png)

make

![image-20210219220503679](https://i.loli.net/2021/02/20/I6lo9wZWCegR14j.png)

make check //检查

![image-20210219220625040](https://i.loli.net/2021/02/20/3nrdhHM2UKAmoaX.png)

sudo make install

![image-20210219220724280](https://i.loli.net/2021/02/20/BcRwi6gfS7l1Con.png)

ls /usr/local/lib/

![image-20210219220754791](https://i.loli.net/2021/02/20/EFTb5VXjclNzZeI.png)

显示编译错误2：

![image-20210219220852614](https://i.loli.net/2021/02/20/H3mhQRZxS48wJ6b.png)

fatal error: mpc.h: No such file or directory

使用命令安装：

```shell
sudo apt-get install libmpc-dev
```



编译完成：

![image-20210220091237593](https://i.loli.net/2021/02/20/QKnCJSPBGTqYWrE.png)



执行测试

```shell
/opt/qemu/bin/qemu-system-arm -M vexpress-a9 -m 512M -kernel arch/arm/boot/ -dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic -append "console=ttyAMA0"
```



![image-20210220094339143](https://i.loli.net/2021/02/20/42pMhuxzZDyeRdI.png)





## 六 编译busybox制作文件系统

编译：

```shell
make defconfig
make menuconfig 
```

在make menuconfig中选择：Setting->Build Static binary（no shared libs）静态库 不要共享动态库

![image-20210220101301643](https://i.loli.net/2021/02/20/uz4GT7DQijtU1S3.png)

```shell
make 
```

当前目录下：

![image-20210220101904008](https://i.loli.net/2021/02/20/SegcTKDl261yZjW.png)



```
make install
```

![image-20210220101807410](https://i.loli.net/2021/02/20/b3X2Q8ROj7C9WeZ.png)



参考：https://blog.csdn.net/leacock1991/article/details/113703897

在busybox-1.33.0根目录创建文件，制作make_rootfs.sh文件

制作rootfs文件夹

```shell

#    File Name:  make_rootfs.sh
##  
#!/bin/sh
base=`pwd`
tmpfs=${base}/_tmpfs

# 如果存在删除
rm -rf rootfs
rm -rf ${tmpfs}
rm -f a9rootfs.ext3

mkdir rootfs
# 拷贝 _install 中文件 到 rootfs
cp _install/*  rootfs/ -raf

#sudo mkdir -p rootfs/{lib,proc,sys,tmp,root,var,mnt}
cd rootfs && sudo mkdir -p lib proc sys tmp root var mnt && cd ${base}

# 根据自己的实际情况, 找到并 拷贝 arm-gcc 中的 libc中的所有.so 库
cp -arf /opt/arm-linux-gcc/arm-linux-gnueabihf/lib/*  rootfs/lib

cp examples/bootfloppy/etc rootfs/ -arf

sed -r  "/askfirst/ s/.*/::respawn:-\/bin\/sh/" rootfs/etc/inittab -i
mkdir -p rootfs/dev/
mknod rootfs/dev/tty1 c 4 1
mknod rootfs/dev/tty2 c 4 2pro
mknod rootfs/dev/tty3 c 4 3
mknod rootfs/dev/tty4 c 4 4
mknod rootfs/dev/console c 5 1
mknod rootfs/dev/null c 1 3
dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=100
# 如果提示 "No space left on device" 证明 dd 命令中 count 的大小不够，可以先进行瘦身

mkfs.ext3 a9rootfs.ext3
mkdir -p ${tmpfs}
chmod 777 ${tmpfs}
mount -t ext3 a9rootfs.ext3 ${tmpfs}/ -o loop
cp -r rootfs/*  ${tmpfs}/
umount ${tmpfs}
chmod 777 a9rootfs.ext3

```

sudo ./make_rootfs.sh

生成镜像

![image-20210220104251039](https://i.loli.net/2021/02/20/GasY4Oh9wUE82WT.png)



验证：

在linux和busybox的公共父目录test1中验证

```shell
/opt/qemu/bin/qemu-system-arm -M vexpress-a9 -m 512M -kernel linux-5.11/arch/arm/boot/zImage -dtb linux-5.11/arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic -append "root=/dev/mmcblk0 rw console=ttyAMA0" -sd busybox-1.33.0/a9rootfs.ext3 
```



遇到问题：

![image-20210220105358214](https://i.loli.net/2021/02/20/wgaY9pOHyDBoTtG.png)

看情况是100M给的太小根据上面make_rootfs.sh的结果来看似乎rootfs不够

解决办法1：

直接修改100M为128M

make_rootfs.sh文件

```shell
dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=128
```



![image-20210220105944965](https://i.loli.net/2021/02/20/6wBHQkm3SqoTOMA.png)

完成

![image-20210220105805164](https://i.loli.net/2021/02/20/OmxHrVYfod2ZhJG.png)

方法2：(尝试没有生效,不知道为啥)

strip优化程序来去掉多余符号

在make_rootfs.sh文件中加入

```shell
gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnuebi-strip ./rootfs/lib/*
....
dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=128
```







## 七 制作之NFS下载模式启动

使用Qemu将u-boot 和 zImage以及rootfs一起加载完成。







### 7.1   分析方案：

使用Nfs方式在u-boot模式下启动

1 将qemu虚拟机的网络与主机Ubuntu的网络打通：

两种模式：

1）用户模式网络（user mode network）

这种实现虚拟上网简单，类似VMware的NAT  启动时加入参数-user-net参数。

虚拟机里使用dhcp方式，即可与互联网通信，但是这种方式虚拟机与主机的通信不方便。



2）隧道网络（tap/tun network）本文采用这个方式 

重点：

从3.0开始，不再支持vlan，需要改为如下的方式。



安装工具包

```shell
sudo apt-get install uml-utilities bridge-utils 
```

会看到：

![image-20210222104512275](https://i.loli.net/2021/02/22/oFYyABliPthTG9H.png)



### 7.2 Ubuntu上添加网口

```shell
vim /etc/network/interface

```

添加br0的桥,之后网络设置

#### 7.2.1 网桥br0使用dhcp自动获取地址

本次实践使用该方案

```shell
# interfaces(5) file used by ifup(8) and ifdown(8)             
auto lo                                                        
iface lo inet loopback                                         
                                                               
auto br0                  #br0接口                                     
iface br0 inet dhcp       #br0是dhcp方式获取ip地址                              
bridge_ports ens33        #桥下接口网卡ens33                                     
                                                               
#auto ens33                                                    
#iface ens33 inet static                                       
#address 192.168.137.42                                        
#netmask 255.255.255.0                                         
#gateway 192.168.137.1                                         
                                                               
                                                               
                                                               
#dns-nameserver 192.168.137.1                                  
```



#### 7.2.2 网桥br0使用static自动配置地址

重启虚拟机后IP地址变化，遂再重启虚拟机后选择这个方案。

```shell
# interfaces(5) file used by ifup(8) and ifdown(8) 
auto lo                                            
iface lo inet loopback                             
                                                   
#auto br0                                          
#iface br0 inet dhcp                               
                                                   
                                                   
auto ens33                                         
iface ens33 inet manual                            
                                                   
auto br0                                           
iface br0 inet static                              
    address 192.168.137.42                         
    network 192.168.137.0                          
    netmask 255.255.255.0                          
    gateway 192.168.137.1                          
    broadcast 192.168.137.255                      
    dns-nameserver 192.168.137.1                   
    bridge_ports ens33                             
    bridge_stp off                                 
    bridge_fd 0                                    
    bridge_maxwait 0                               
    
```

```shell
sudo /sbin/ifup br0
```



虚拟机如果上不了网,则是少了默认路由。

```shell
sudo route add default gw 192.168.137.1
```





#### 7.2.3 测试情况

后续的实践都是使用DHCP方案，即tftp服务器的地址是192.168.137.221

如果使用静态方法，则tftp服务器的地址都是192.168.137.42



```shell
sudo service networking restart
```

则得到

brctl show

![image-20210223101703955](C:/Users/liqiang6/AppData/Roaming/Typora/typora-user-images/image-20210223101703955.png)



添加自动调用脚本

原因：

在使用命令

```shell
/opt/qemu/bin/qemu-system-arm -M vexpress-a9 -m 256 -kernel ./u-boot-2021.01/u-boot  -nographic -net nic -net tap,ifname=tap0 -sd ./a9rootfs.ext3
```

会去调用/opt/qemu/etc/qemu-ifup (同理，停止的时候，会调用/opt/qemu/etc/qemu-ifdown )

所以

```shell
mkdir -p /opt/qemu/etc/
sudo vi /opt/qemu/etc/qemu-ifup
```



```shell
#!/bin/sh

# tunctl创建隧道
echo sudo tunctl -u $(id -un) -t $1
sudo tunctl -u $(id -un) -t $1

# 
echo sudo ifconfig $1 0.0.0.0 promisc up
sudo ifconfig $1 0.0.0.0 promisc up

#将网卡加入到桥
echo sudo brctl addif br0 $1
sudo brctl addif br0 $1

#显示bridge 桥状态
echo brctl show
brctl show

#设置IP地址
sudo ifconfig br0 192.168.137.101

```



同理 

```shell
sudo vi /opt/qemu/etc/qemu-ifdown
```

```shell

#!/bin/sh

echo sudo brctl delif br0 $1
sudo brctl delif br0 $1
echo sudo tunctl -d $1
sudo tunctl -d $1
echo brctl show
brctl show

```









### 7.3 安装tftpd-hpa 即tftp服务器

设置服务器的参数：

```shell
# /etc/default/tftpd-hpa                      
                                  
TFTP_USERNAME="tftp"                          
TFTP_DIRECTORY="/home/xxxx/qemu/tftp_dir"  #选择一个目录作为服务器的tftp上传与下载的主目录路径
TFTP_ADDRESS=":69"                            
TFTP_OPTIONS="-l -c -s"                       
                               
```

sudo /etc/init.d/tftpd-hpa  restart



### 7.4 命令测试NFS

启动uboot

```shell
/opt/qemu/bin/qemu-system-arm -M vexpress-a9 -m 256 -kernel ./u-boot-2021.01/u-boot -nographic -net nic -net tap,ifname=tap0 -sd ./a9rootfs.ext3
```



使用手动

```shell
setenv ipaddr=192.168.137.103

setenv serverip=192.168.137.221

setenv netmask=255.255.255.0


tftp 0x60003000 uImage;
```



![image-20210223110142539](https://i.loli.net/2021/02/23/YC7q512K96ytUpm.png)

```shell
tftp 0x60500000 vexpress-v2p-ca9.dtb; 
```

![image-20210223110502671](https://i.loli.net/2021/02/23/MlYuPih1FXecrpD.png)



```shell
setenv bootargs 'root=/dev/mmcblk0 console=ttyAMA0' 
bootm 0x60003000 - 0x60500000
```

![image-20210223110937467](https://i.loli.net/2021/02/23/nUsoOkTZPuHwRB4.png)





### 7.5 修改代码自动NFS加载

使用NFS有两个挂载方式：

1 NFS挂载内核后，通过SD挂载格式化文件系统镜像，命令如下：

```shell
/opt/qemu/bin/qemu-system-arm -M vexpress-a9 -m 256 -kernel ./u-boot-2021.01/u-boot -nographic -net nic -net tap,ifname=tap0 -sd ./a9rootfs.ext3
```



2 NFS挂载内核后，通过NFS共享文件系统目录，方法是修改CONFIG_BOOTCOMMAND

```shell
vim .config
修改
CONFIG_BOOTCOMMAND="run distro_bootcmd; run bootflash"
为
CONFIG_BOOTCOMMAND="tftp 0x60003000 uImage;tftp 0x60500000 vexpress-v2p-ca9.dtb; setenv bootargs 'root=/dev/nfs rw  nfsroot=192.168.137.221:/home/路径自己填写xxx/qemu/test1/rootfs,proto=tcp,nfsvers=4,nolock ip=192.168.3.103 console=ttyAMA0'; bootm 0x60003000 - 0x60500000"

#CONFIG_IPADDR=192.168.137.103
#CONFIG_NETMASK=255.255.255.0
#CONFIG_SERVERIP=192.168.137.221

```



#### 7.5.1 nfs挂载内核，sd卡挂载文件系统rootfs的。

关键命令卸载前面：

```shell
/opt/qemu/bin/qemu-system-arm -M vexpress-a9 -m 256 -kernel ./u-boot-2021.01/u-boot -nographic -net nic -net tap,ifname=tap0 -sd ./a9rootfs.ext3
```



希望自动加载NFS下的uImage的方式：

修改代码

```shell
vim .config
修改
CONFIG_BOOTCOMMAND="run distro_bootcmd; run bootflash"
为
CONFIG_BOOTCOMMAND="tftp 0x60003000 uImage;tftp 0x60500000 vexpress-v2p-ca9.dtb; setenv bootargs 'root=/dev/mmcblk0 console=ttyAMA0'; bootm 0x60003000 - 0x60500000"
#CONFIG_IPADDR=192.168.137.103
#CONFIG_NETMASK=255.255.255.0
#CONFIG_SERVERIP=192.168.137.221
```

其中

dev/mmcblk0:通知内核文件系统加载文件系统的设备





u-boot-2021.01\include\configs\vexpress_common.h

```c

#define CONFIG_IPADDR 192.168.137.103
#define CONFIG_NETMASK 255.255.255.0
#define CONFIG_SERVERIP 192.168.137.221

```



编译新uboot

```shell
cd u-boot-2021.01
make 

```

启动

![image-20210223174911721](https://i.loli.net/2021/02/23/NtgkQoM8a5wZO7u.png)



由于在include定义的时候，在notepad++编辑造成

```c
#define CONFIG_SERVERIP 192.168.137.221
```

​    定义后面带了一个符号，在vim下   include/autoconf.mk中serverip会显示符号，但是在include\configs\vexpress_common.h没有显示出来符号。

  重新编辑

正确输出：

![image-20210223181416377](https://i.loli.net/2021/02/23/nW2yjrJI4AostKL.png)



![image-20210223181448344](https://i.loli.net/2021/02/23/4GpfuDEgv3kiFVK.png)





#### 7.5.2 NFS共享文件系统目录



关键修改：

````shell
vim .config
修改
CONFIG_BOOTCOMMAND="run distro_bootcmd; run bootflash"
为
CONFIG_BOOTCOMMAND="tftp 0x60003000 uImage;tftp 0x60500000 vexpress-v2p-ca9.dtb; setenv bootargs 'root=/dev/nfs rw  nfsroot=192.168.137.221:/home/路径自己填写xxx/qemu/test1/rootfs,proto=tcp,nfsvers=4,nolock init=/linuxrc ip=192.168.3.103 console=ttyAMA0'; bootm 0x60003000 - 0x60500000"

#CONFIG_IPADDR=192.168.137.103
#CONFIG_NETMASK=255.255.255.0
#CONFIG_SERVERIP=192.168.137.221


````

其中nfsvers=3表示Linux内核需要支持nfs的版本3

![image-20210224105525379](https://i.loli.net/2021/02/24/VCsGX5K9PW6jhz7.png)

如果需要



安装软件支持：

支持NFS服务

```shell
sudo apt-get install nfs-kernel-server nfs-common
```

![image-20210224084252838](https://i.loli.net/2021/02/24/LThW2vNSCfYjRcu.png)



软件状态查看

![image-20210224093751405](https://i.loli.net/2021/02/24/bjeKd9NZyJ8LHUr.png)

vi /etc/exports

添加跟文件系统文件夹路径作为nfs的路径

```shell


/home/路径自己填写xxx/qemu/test1/rootfs *(rw,sync,no_subtree_check,no_root_squash)

```

重启软件

```shell
/etc/init.d/rpcbind restart
/etc/init.d/nfs-kernel-server restart
```

环境布置完成



修改代码如上面一开始的样子

关键修改：

````shell
vim .config
修改
CONFIG_BOOTCOMMAND="run distro_bootcmd; run bootflash"
为
CONFIG_BOOTCOMMAND="tftp 0x60003000 uImage;tftp 0x60500000 vexpress-v2p-ca9.dtb; setenv bootargs 'root=/dev/nfs rw  nfsroot=192.168.137.221:/home/路径自己填写xxx/qemu/test1/rootfs,proto=tcp,nfsvers=3,nolock init=/linuxrc ip=192.168.3.103 console=ttyAMA0'; bootm 0x60003000 - 0x60500000"

#CONFIG_IPADDR=192.168.137.103
#CONFIG_NETMASK=255.255.255.0
#CONFIG_SERVERIP=192.168.137.221

````

如此我们就将

/home/路径自己填写xxx/qemu/test1/rootfs

作为

qemu启动的文件系统rootfs

```shell
/opt/qemu/bin/qemu-system-arm -M vexpress-a9 -m 256 -kernel $1/$2 -nographic -net nic -net tap,ifname=tap0 
```



![image-20210224110810378](C:/Users/liqiang6/AppData/Roaming/Typora/typora-user-images/image-20210224110810378.png)





测试NFS的效果：

在Ubuntu写一个测试程序

进入/home/路径自己填写xxx/qemu/test1/rootfs

vi test.c文件

```c
                                             
#include <stdio.h>                           
#include <stdlib.h>                          
                                             
int main(int argc, char * argv[])            
{                                            
    printf("hello world !\n");               
    system("echo \"test\" > /dev/console "); 
    system("ls");                            
    return 0;                                
}                                            
~                                            
~                                            
```

执行交叉编译

直接在tmp下可以看到文件

执行./test出现错误 not found

![image-20210224113559292](https://i.loli.net/2021/02/24/iHqZ9RkJIbaSlw4.png)



原因是因为我们缺少一些动态库（这个相关性是我们只做busybox选择静态库）

将交叉编译工具链中的库ld-linux.so.3放到文件系统rootfs/lib/下

![image-20210224113818797](https://i.loli.net/2021/02/24/eaHBUlyPDLfmx1r.png)

执行效果：

![image-20210224113939112](https://i.loli.net/2021/02/24/a6NelR9OZwFTLbf.png)

如此接着拷贝交叉编译工具链里的库

![image-20210224114124915](https://i.loli.net/2021/02/24/rWjeQcLF3sIZmhY.png)



OK完成了











## 八 自作镜像系统img



https://wenku.baidu.com/view/c343f68bb9d528ea81c77912.html

```shell
mkimage -A arm -C none -O linux -T kernel -d zImage -a 0x00010000 -e 0x00010000 zImage.uimg
mkimage -A arm -C none -O linux -T ramdisk -d rootfs.img.gz -a 0x00800000 -e 0x00800000 rootfs.uimg
dd if=/dev/zero of=flash.bin bs=1 count=6M
dd if=u-boot.bin of=flash.bin conv=notrunc bs=1 
dd if=zImage.uimg of=flash.bin conv=notrunc bs=1 seek=2M
dd if=rootfs.uimg of=flash.bin conv=notrunc bs=1 seek=4M

#将flash.bin文件加载到qemu下运行
qemu-system-arm -M versatilepb -m 128M -kernel flash.bin -searial stdio

#如果没有自动加载内核，在虚拟机终端下：
bootm 0x210000 0x410000

#如果失败
qemu-system-arm -M versatilepb -m 128M -kernel zImage -initrd rootfs.img.gz -append "root=/dev/ram mem=128M init=/sbin/init" -serial stdio



```







make_img.sh

```shell
#!/bin/bash

if [ "$1" ];then
    echo $1
else
    echo "请传入根文件系统压缩包"
    exit 1
fi

mkdir -p ./tmp

# 目录与文件名
xdir='./tmp/sdir'
p1='./tmp/p1'
p2='./tmp/p2'
rootfs='rootfs.ext4'

# 先删除
sudo rm -f $rootfs
sudo rm -rf $xdir
sudo rm -rf $p1
sudo rm -rf $p2

mkdir -p $xdir $p1 $p2

# 根据实际情况指定文件 解压
sudo tar -xf $1 -C $xdir/
# 创建镜像 由于是 ext4 所以 bs*count 需要是2的n次方
# 大小 视 根文件系统大小而定
dd if=/dev/zero of="$rootfs" bs=1M count=256

# 分区 创建两个分区（一个用来存放kernel和设备树，另一个存放根文件系统）
sgdisk -n 0:0:+10M -c 0:kernel $rootfs
sgdisk -n 0:0:0 -c 0:rootfs $rootfs

LOOPDEV=`losetup -f`   # 查找空闲的loop设备
echo $LOOPDEV
sudo losetup $LOOPDEV  $rootfs
sudo partprobe $LOOPDEV
sudo losetup -l
ls /dev/loop*

# 格式化 
sudo mkfs.ext4 /dev/loop0p1
sudo mkfs.ext4 /dev/loop0p2

# 挂载
sudo mount -t ext4 /dev/loop0p1 $p1   # 存放kernel和设备树
sudo mount -t ext4 /dev/loop0p2 $p2   # 存放根文件系统
# 查看挂载情况
df -h


# 将 zImage 和 dtb 拷贝到 p1  
# 之前编译内核的内核目录（linux-5.4.95 文件夹中）
sudo cp ./$KERNEL_DIR/arch/arm/zImage $p1/
sudo cp ./$KERNEL_DIR/arch/arm/boot/vexpress-v2p-ca9.dtb $p1/
# 将 文件系统中的文件拷贝到 p2
sudo cp -arf $xdir/* $p2/

# 去掉 root 登录密码
sudo sed -i 's/root:x:0:0:root:/root::0:0:root:/' $p2/etc/passwd

sudo umount $p1 $p2
sudo losetup -d $LOOPDEV
sudo rm -rf $xdir
sudo rm -rf $p1
sudo rm -rf $p2

printf "创建 %s/%s 成功\n\n" "$(pwd)" $rootfs
exit 0
```





创建空白img文件：

```shell
dd if=/dev/zero of=test.img bs=4M count=1024
```



参数说明

key=[value]

if=文件名：输入文件名称（input file） 默认为标准输入。即指定源文件。

of=文件名：输出文件名称（output file） 默认为标准输出。即指定目的文件。

bs=bytes: 同事设置读入/输出块的大小bytes个字节。

count=blocks:仅拷贝blocks个块，块大小等于ibs（一次读入bytes个字节）指定字节数。

新建img大小为bs*count;这里是4096M=4GiB（1024） =4.3GB（1000）

/dev/zero:虚拟盘的名字，可无限提供空字符。

test.img:镜像文件，目前是空的

bs：4M

count：1024，镜像的大小及4*1024=4G



```shell
sudo mkfs.ext4 test.img
```

制作镜像格式为ext4





```shell
sudo mount test.img rootfs
```

挂载镜像到 rootfs文件夹











## 九 SD卡启动方式





## 十 制作交叉编译工具链

http://www.elecfans.com/emb/20190402899146.html

​     

### 10.1 交叉编译工具链介绍

arm-none-eabi-gcc

（ARM architecture，no vendor，not target an opera[TI](http://bbs.elecfans.com/zhuti_715_1.html)ng system，complies with the ARM EABI）





参考：https://blog.csdn.net/ongoingcre/article/details/52247754



### 10.2 制作交叉编译工具链



http://crosstool-ng.github.io

```shell
tar -xvf wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.22.0.tar.bz2
mkdir -p crosstool-ng
ls
#显示：crosstool-ng  crosstool-ng-1.24.0  crosstool-ng-1.24.0.tar.bz2
cd crosstool-ng
../crosstool-ng-1.24.0/configure --prefix=/home/xxxx/qemu/test1/cross-ng/crosstool-ng/out

```



出现错误：

![image-20210304142137633](https://i.loli.net/2021/03/04/kePKpHqJwbf9oVC.png)

但是实际上已经安装过了

需要安装libtool-bin软件

sudo apt-get install libtool-bin

执行完成：

![image-20210304142409577](https://i.loli.net/2021/03/04/eibvcY6wgE9p5tx.png)



```shell
make
make install
```

![image-20210304142703847](C:/Users/liqiang6/AppData/Roaming/Typora/typora-user-images/image-20210304142703847.png)

```shell
cd .. ##回到主目录即cross-ng目录
mkdir x86_64-cross
cd x86_64-cross
../crosstool-ng/out/bin/ct-ng list-samples#上一步编译的产物
```

可以看到一系列的已知工具链的名称

![image-20210304143229100](https://i.loli.net/2021/03/04/ScDimVk1LYwOoBM.png)





```shell
../crosstool-ng/out/bin/ct-ng show-x86_64-unknown-linux-gnu
```



![image-20210304143515984](https://i.loli.net/2021/03/04/wQiJprksYBxoAe6.png)

开始制作

```shell
../crosstool-ng/out/bin/ct-ng x86_64-unknown-linux-gnu
```

![image-20210304144017912](https://i.loli.net/2021/03/04/XoiyG8sC3DcAqIQ.png)

生成.config 文件

![image-20210304144118431](https://i.loli.net/2021/03/04/VJlMXhoKCZqGrYc.png)

```shell
../crosstool-ng/out/bin/ct-ng menuconfig
```

进行配置

![image-20210304144505987](https://i.loli.net/2021/03/04/CsAjbLzvpZNGkfq.png)

```shell
../crosstool-ng/out/bin/ct-ng build
```

![image-20210304144653954](https://i.loli.net/2021/03/04/5XwETUbAVQSCMzx.png)



需要下载各个tar包到指定位置：

由于下载内核比较慢：即此实验中的下载linux-4.20.8.tar.xz比较慢，所以使用浏览器直接下载

https://www.kernel.org

然后放到./build/tarballs/下

再执行

```shell
../crosstool-ng/out/bin/ct-ng build
```



![image-20210304172358331](https://i.loli.net/2021/03/04/pyah3JSXTv6js5K.png)

ls .build/tarballs 

![image-20210304172314904](https://i.loli.net/2021/03/04/CmSa26bKTh4VnD1.png)

完成下载

![image-20210304173239639](https://i.loli.net/2021/03/04/nFWJXSUq8OkCchG.png)



进入解压运行部分：

解压后的位置 .build/src下





## QNX系統



QNXNeutrino650Target





## HarmonyOS



https://gitee.com/openharmony/kernel_liteos_a



![image-20210304104701146](https://i.loli.net/2021/03/04/MUEkcZAvCIoORzQ.png)



#### 

kernel_liteos_a

Cortex-A 内核



编译：











## RT-Thread启动





https://www.rt-thread.org/document/site/tutorial/qemu-network/qemu_setup/qemu_setup/









## Android启动



https://www.cnblogs.com/Rain2017/p/5432879.html





https://www.cnblogs.com/slgkaifa/p/6826999.html





https://blog.csdn.net/leopard21/article/details/21715905?utm_medium=distribute.pc_relevant.none-task-blog-baidujs_baidulandingword-2&spm=1001.2101.3001.4242





https://blog.csdn.net/ztguang/article/details/51655486?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control&dist_request_id=ebeb19b8-d115-432a-89da-c786473ef38c&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control







https://xuexuan.blog.csdn.net/article/details/86354616?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control&dist_request_id=d130f1ab-3f73-47a8-abc1-ae132eebcfb7&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control





https://blog.csdn.net/nwpushuai/article/details/82463810?ops_request_misc=&request_id=&biz_id=102&utm_term=Android系统下载编译&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-8-82463810.pc_search_result_before_js





## buildroot学习



https://www.cnblogs.com/arnoldlu/p/9553995.html





## 调试方式

1 打印



2 trace

http://blog.chinaunix.net/uid-11196893-id-277109.html



3 coredump





4 

信号来回调打印

signal(SIG_TERM,callback);



5 gdb







## 虚拟机仿真







## 扩展-实现SuZhen框架



建立工程 目录结构：

localtest/ #测试架构脚本使用，没有特别用图

model/   

toolchain/

u-boot/

kernel/

busybox/

qemu/

Makefile

rules.mk

工程过程：

1 make MODEL=V1 u-boot



Makefile

```makefile
COMPILE_DIR=$(CURDIR)

include $(CURDIR)/rules.mk
include $(CURDIR)/MODEL/$(MODEL)/qemu_config


.PHONY:all

all: helloworld u-boot kernel  busybox
	echo "############ do the qemu+u-boot+kernel+busybox  #########"
	echo "############ end ok ################ "

prepare:u-boot_menuconfig kernel_menuconfig busybox_menuconfig
	echo "prepare menuconfig"
	echo "end prepare menuconfig "
	

helloworld:
	echo "############ make test ${LOCAL_TEST_DIR}  ###################"
	mkdir -p $(LOCAL_TEST_DIR)
	make -C $(LOCAL_TEST_DIR) clean
	make -C $(LOCAL_TEST_DIR)
	echo "################### end ${LOCAL_TEST_DIR} ########################"

u-boot_menuconfig:
	echo "############ do u-boot compile #######"
	make -C $(UBOOT_DIR) $(UBOOT_CONF) 
	#make -C $(UBOOT_DIR) 	
	echo "############ u-boot end #########"

u-boot:
	echo "############ do u-boot compile #######"
	#make -C $(UBOOT_DIR) $(UBOOT_CONF) 
	make -C $(UBOOT_DIR) 	
	echo "############ u-boot end #########"

kernel_menuconfig:
	echo "########## make kernel_menuconfig ##############"
	make -C $(KERNEL_DIR) $(KERNEL_CONF)
	make -C $(KERNEL_DIR) menuconfig 
	echo "########## make kernel_menuconfig end ###############"

kernel:
	echo "########## make kernel ##############"
	make -C $(KERNEL_DIR)
	echo "########## kernel end ###############"

busybox_menuconfig:
	echo "########## make busybox_menuconfig ##############"
	make -C $(BUSYBOX_DIR) defconfig
	make -C $(BUSYBOX_DIR) menuconfig 
	echo "########## make busybox_menuconfig end ###############"

busybox:
	echo "########## make busybox ##############"
	make -C $(BUSYBOX_DIR)
	echo "########## busybox end ###############"

busybox_install:
	echo "########## make busybox_install ##############"
	make -C $(BUSYBOX_DIR) install
	echo "########## busybox_install end ###############"

```

rules.mk

```Makefile
export UBOOT_DIR=$(CURDIR)/u-boot-2021.01
export KERNEL_DIR=$(CURDIR)/linux-5.11
export QEMU_DIR=$(CURDIR)/qemu-5.2.0
export BUSYBOX_DIR=$(CURDIR)/busybox-1.33.0
export LOCAL_TEST_DIR=$(CURDIR)/localtest
```



MODEL/V1/qemu.conf

```shell


export ARCH=arm
export CROSS_COMPILE=$(CURDIR)/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-

export UBOOT_DIR=$(CURDIR)/u-boot-2021.01
export KERNEL_DIR=$(CURDIR)/linux-5.11
export QEMU_DIR=$(CURDIR)/qemu-5.2.0
export BUSYBOX_DIR=$(CURDIR)/busybox-1.33.0

export UBOOT_CONF=vexpress_ca9x4_defconfig 
export KERNEL_CONF=vexpress_defconfig

```





测试文件：

localtest\helloworld.c

```c
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char ** argv)
{
    printf("hello world !!! \n");
    return 0;
}


```



localtest\Makefile

```makefile
#CFLAGS  += -I./
#LDFLAGS +=  

CROSS_COMPILE ?=

CC = $(CROSS_COMPILE)gcc

app=helloworld
appdep=$(app).c

all:$(app)

$(app):$(appdep)
	$(CC) -o $(app) $(appdep) $(LDFLAGS) $(CFLAGS)

clean:
	rm -f $(app).o
	rm -r $(app)
```



MODEL/V1/qemu_config

```SHELL
export ARCH=arm
export CROSS_COMPILE=$(CURDIR)/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-
export UBOOT_CONF=vexpress_ca9x4_defconfig
export KERNEL_CONF=vexpress_defconfig

```





run.sh

```shell

#!/bin/sh
PWD=$(pwd)

#UBOOT_DIR=${PWD}/u-boot-2021.01
#KERNEL_DIR=${PWD}linux
#QEMU_DIR=${PWD}/qemu-5.2.0
#LOCAL_TEST_DIR=${PWD}/localtest


QEMU_CMD_ARM=/opt/qemu/bin/qemu-system-arm

#if [ $1 == "uboot" ]; then
#    echo "emultar uboot "
#    ${QEMU_CMD_ARM} -M vexpress-a9 -m 256 -kernel ${UBOOT_DIR}/u-boot -nographic
#fi


run_uboot(){
	echo "emultar $1 "
	${QEMU_CMD_ARM} -M vexpress-a9 -m 256 -kernel $1/$2 -nographic
}

run_kernel(){
	echo "emultar $1 "
	${QEMU_CMD_ARM} -M vexpress-a9 -m 512M -kernel $1/$2 -dtb $1/$3 -nographic -append "console=ttyAMA0"
}


run_rootfs(){
	echo "emultar $1 "
	${QEMU_CMD_ARM} -M vexpress-a9 -m 512M -kernel $1/$2 -dtb $1/$3 -nographic -append "root=/dev/mmcblk0 rw console=ttyAMA0" -sd $4 
}

usage(){
	echo "###################"
	echo "./run.sh image_path image"
	echo "###################"
	echo "for example:"
	echo " ./run.sh uboot u-boot-2021.01 u-boot"
	echo " ./run.sh kernel linux-5.11/arch/arm/boot/ zImage dts/vexpress-v2p-ca9.dtb"
	echo " ./run.sh rootfs linux-5.11/arch/arm/boot/ zImage dts/vexpress-v2p-ca9.dtb ./a9rootfs.ext3"
}

echo "$1"
echo "$2"

case "$1" in
	uboot) shift 1; run_uboot $@;;
	kernel) shift 1; run_kernel $@;;
	rootfs) shift 1; run_rootfs $@;;
	*) usage ;;
esac
```



make_rootfs.sh

```shell
#    File Name:  make_rootfs.sh
##  
#!/bin/sh
base=`pwd`
tmpfs=${base}/_tmpfs
BUSYBOX_DIR=${base}/busybox-1.33.0
CROSS_COMPILE_DIR=${base}/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi

# 如果存在删除
rm -rf rootfs
rm -rf ${tmpfs}
rm -f a9rootfs.ext3

mkdir rootfs
# 拷贝 _install 中文件 到 rootfs
cp -raf ${BUSYBOX_DIR}/_install/*  rootfs/ 

#sudo mkdir -p rootfs/{lib,proc,sys,tmp,root,var,mnt}
#cd rootfs && sudo mkdir -p lib proc sys tmp root var mnt && cd ${base}
mkdir -p rootfs/lib
mkdir -p rootfs/proc
mkdir -p rootfs/sys
mkdir -p rootfs/tmp
mkdir -p rootfs/root
mkdir -p rootfs/var
mkdir -p rootfs/mnt

# 根据自己的实际情况, 找到并 拷贝 arm-gcc 中的 libc中的所有.so 库
cp -arf ${CROSS_COMPILE_DIR}/lib/*  rootfs/lib

cp -arf ${BUSYBOX_DIR}/examples/bootfloppy/etc rootfs/ 

sed -r  "/askfirst/ s/.*/::respawn:-\/bin\/sh/" rootfs/etc/inittab -i
mkdir -p rootfs/dev/
mknod rootfs/dev/tty1 c 4 1
mknod rootfs/dev/tty2 c 4 2pro
mknod rootfs/dev/tty3 c 4 3
mknod rootfs/dev/tty4 c 4 4
mknod rootfs/dev/console c 5 1
mknod rootfs/dev/null c 1 3

${CROSS_COMPILE_DIR}/bin/arm-linux-gnuebi-strip rootfs/lib/*

#分配空间 128M
dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=128
# 如果提示 "No space left on device" 证明 dd 命令中 count 的大小不够，可以先进行瘦身

#关键一步制作镜像
mkfs.ext3 a9rootfs.ext3
mkdir -p ${tmpfs}
chmod 777 ${tmpfs}
mount -t ext3 a9rootfs.ext3 ${tmpfs}/ -o loop
cp -r rootfs/*  ${tmpfs}/
umount ${tmpfs}
chmod 777 a9rootfs.ext3
```











## 后记

qemu支持的target-list

````shell
i386-softmmu
x86_64-softmmu
arm-softmmu
cris-softmmu
m68k-softmmu
microblaze-softmmu
mips-softmmu
mipsel-softmmu
mips64-softmmu
mips64el-softmmu
ppc-softmmu
ppcemb-softmmu
ppc64-softmmu
sh4-softmmu
sh4eb-softmmu
sparc-softmmu
sparc64-softmmu
i386-linux-user
x86_64-linux-user
alpha-linux-user
arm-linux-user
armeb-linux-user
cris-linux-user
m68k-linux-user
microblaze-linux-user
mips-linux-user
mipsel-linux-user
ppc-linux-user
ppc64-linux-user
ppc64abi32-linux-user
sh4-linux-user
sh4eb-linux-user
sparc-linux-user
sparc64-linux-user
sparc32plus-linux-user
````





参考：

https://blog.csdn.net/u010344264/article/details/82949143



https://edu.51cto.com/course/10445.html



https://wenku.baidu.com/view/c343f68bb9d528ea81c77912.html



重点and优秀：

https://blog.csdn.net/leacock1991/article/details/113735396

https://blog.csdn.net/leacock1991/article/details/113703897



https://www.jianshu.com/p/040459d94e2a?utm_campaign=maleskine&amp;utm_content=note&amp;utm_medium=seo_notes&amp;utm_source=recommendation



https://www.cnblogs.com/pengdonglin137/p/6431234.html



https://wenku.baidu.com/view/c343f68bb9d528ea81c77912.html



https://lyy-0217.blog.csdn.net/article/details/79053855?utm_medium=distribute.pc_relevant.none-task-blog-OPENSEARCH-3.control&dist_request_id=ba8d8b10-a551-45fe-9ac8-175618a06d9f&depth_1-utm_source=distribute.pc_relevant.none-task-blog-OPENSEARCH-3.control



qemu的参数大全

https://www.zhaixue.cc/qemu/qemu-param.html



gnueabi相关的两个交叉编译器: gnueabi和gnueabihf 区别

https://www.cnblogs.com/986YAO/p/9856419.html



其他xshell快捷键

ctrl+s: 锁屏

ctrl+q: 退出锁屏

边缘计算

https://gitee.com/tsiiot/tsiiot/tree/master



MODEL/V3

verstilepb

修改代码

https://wenku.baidu.com/view/c343f68bb9d528ea81c77912.html





上传图片

https://www.cnblogs.com/CF1314/p/13233358.html





openwrt的配置仿真

https://openwrt.org/zh/docs/guide-developer/test-virtual-image-using-armvirt?do=edit





u-boot移植5 裁剪和修改默认参数

https://blog.csdn.net/WangHuiShou/article/details/102415785?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-17.control&dist_request_id=35ebecf7-3a9c-444c-b8f4-aac434b03a1b&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-17.control



制作镜像以及烧写



https://blog.csdn.net/qq_29350001/article/details/52222949?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522161408088516780269860489%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=161408088516780269860489&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_v2~rank_v29-14-52222949.pc_search_result_before_js&utm_term=制作flash.bin的文件的方法



https://blog.csdn.net/zc21463071/article/details/106751361?utm_medium=distribute.pc_relevant.none-task-blog-baidujs_title-3&spm=1001.2101.3001.4242





https://blog.csdn.net/Zhu_Zhu_2009/article/details/80378690?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-18.control&dist_request_id=a1ffd7c2-26af-4590-8656-26807693e623&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-18.control



制作NFS镜像

https://blog.csdn.net/leacock1991/article/details/113704225





https://blog.csdn.net/leacock1991/article/details/113704225







https://blog.csdn.net/a568713197/article/details/87736943?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control&dist_request_id=e638fbd2-e30e-4f8b-a93b-d53e02be3ee0&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control



https://blog.csdn.net/konga/article/details/79595119?utm_medium=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.control&dist_request_id=1ca8c770-f644-42a1-9755-e45ae85f2a58&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.control



https://www.jianshu.com/p/02661a0fe438



https://blog.csdn.net/kunkliu/article/details/79816397?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522161413739516780264087119%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=161413739516780264087119&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~baidu_landing_v2~default-2-79816397.pc_search_result_before_js&utm_term=-%2Fbin%2Fsh%3A+.%2Ftest%3A+not+found





移植：

https://blog.csdn.net/u011011827/article/details/69786828



targets-list的内容

kvm_targets = ['mips-softmmu', 'mipsel-softmmu', 'mips64-softmmu', 'mips64el-softmmu']  



## 结尾







