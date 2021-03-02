
#!/bin/sh
# Suzhen is a pretty and amazing lady  from Mount QingCheng(in Sichuan, China)
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

run_uboot_nfs(){
	echo "emultar $1 "
	#${QEMU_CMD_ARM} -M vexpress-a9 -m 256 -kernel $1/$2 -nographic -device virtio-net-device,netdev=tap0 -netdev tap,id=tap0,ifname=tap0 -sd ./a9rootfs.ext3
	${QEMU_CMD_ARM} -M vexpress-a9 -m 256 -kernel $1/$2 -nographic -net nic -net tap,ifname=tap0 
}

run_uboot(){
	echo "emultar $1 "
	#${QEMU_CMD_ARM} -M vexpress-a9 -m 256 -kernel $1/$2 -nographic -device virtio-net-device,netdev=tap0 -netdev tap,id=tap0,ifname=tap0 -sd ./a9rootfs.ext3
	${QEMU_CMD_ARM} -M vexpress-a9 -m 256 -kernel $1/$2 -nographic -net nic -net tap,ifname=tap0 -sd ./a9rootfs.ext3
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
	echo " ./run.sh uboot_nfs u-boot-2021.01 u-boot"
	echo " ./run.sh kernel linux-5.11/arch/arm/boot/ zImage dts/vexpress-v2p-ca9.dtb"
	echo " ./run.sh rootfs linux-5.11/arch/arm/boot/ zImage dts/vexpress-v2p-ca9.dtb ./a9rootfs.ext3"
}

echo "$1"
echo "$2"

case "$1" in
	uboot) shift 1; run_uboot $@;;
	kernel) shift 1; run_kernel $@;;
	rootfs) shift 1; run_rootfs $@;;
	uboot_nfs)  shift 1; run_uboot_nfs $@;;
	*) usage ;;
esac







