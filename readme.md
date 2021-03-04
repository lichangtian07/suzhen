# suzhen 结构



​      BaiSuzhen is a amazing fair Lady , who comes from QingChengShan, SiChuan. She helps his husband and saves people . 

​      帮助初学者使用Qemu进行仿真u-boot启动Linux内核到加载文件系统。模拟嵌入式环境。

​     为了减小对硬件依赖，（买不起板子，暂时不想买板子）



以V1机型为例



```shell
make MODEL=V1 prepare 
make MODEL=V1 qemu_build
make MODEL=V1 u-boot_menuconfig
make MODEL=V1 u-boot
make MODEL=V1 kernel_menuconfig
make MODEL=V1 kernel
make MODEL=V1 busybox_menuconfig
make MODEL=V1 busybox
make MODEL=V1 busybox_install
```



```shell
cd build_dir/V1/

./make_rootfs.sh #生成文件系统a9rootfs.ext3

#仿真命令一，检查u-boot启动是否正常
./run.sh uboot u-boot-2021.01 u-boot                                                     

#仿真命令二，需要对U-boot代码进行一些修改。
./run.sh uboot_nfs_fs u-boot-2021.01 u-boot  ./a9rootfs.ext3                                             

#仿真命令三，需要对u-boot代码进行修改
./run.sh uboot_nfs u-boot-2021.01 u-boot                                                  
#仿真命令四，检查内核启动效果
./run.sh kernel linux-5.11/arch/arm/boot/ zImage dts/vexpress-v2p-ca9.dtb                 

#仿真命令无，检查文件系统情况
./run.sh rootfs linux-5.11/arch/arm/boot/ zImage dts/vexpress-v2p-ca9.dtb ./a9rootfs.ext3 

```







