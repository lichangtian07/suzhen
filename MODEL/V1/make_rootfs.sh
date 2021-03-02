
#    File Name:  make_rootfs.sh
##  
#!/bin/sh

#. ${TOP_DIR}/MODEL/${MODEL}/qemu_conf

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

dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=128
# 如果提示 "No space left on device" 证明 dd 命令中 count 的大小不够，可以先进行瘦身

mkfs.ext3 a9rootfs.ext3
mkdir -p ${tmpfs}
chmod 777 ${tmpfs}
mount -t ext3 a9rootfs.ext3 ${tmpfs}/ -o loop
cp -r rootfs/*  ${tmpfs}/
umount ${tmpfs}
chmod 777 a9rootfs.ext3



