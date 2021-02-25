

COMPILE_DIR=$(CURDIR)

include $(CURDIR)/MODEL/$(MODEL)/qemu_config
include $(CURDIR)/rules.mk


BUILD_DIR=build_dir/${MODEL}


QEMU_TAR_DIR=qemu
UBOOT_TAR_DIR=u-boot
KERNEL_TAR_DIR=kernel
BUSYBOX_TAR_DIR=busybox

#build_dir/V1/qemu-5.2.0
#build_dir/V1/u-boot-2021.01
#build_dir/V1/linux-5.11
#build_dir/V1/busybox-1.33.0

QEMU_DIR=$(BUILD_DIR)/qemu-$(QEMU_VERSION)
UBOOT_DIR=$(BUILD_DIR)/u-boot-$(KERNEL_VERSION)
KERNEL_DIR=$(BUILD_DIR)/linux-$(UBOOT_VERSION)
BUSYBOX_DIR=$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)


.PHONY:all

all: helloworld u-boot kernel busybox
	echo "############ do the qemu+u-boot+kernel+busybox  #########"
	echo "############ end ok ################ "

prepare:
	echo "############ do prepare ############## "
	mkdir -p $(CURDIR)/$(BUILD_DIR)
	if []
	tar -xvf $(QEMU_TAR_DIR)/$(QEMU_TAR) -C $(BUILD_DIR)/
	tar -xvf $(UBOOT_TAR_DIR)/$(UBOOT_TAR) -C $(BUILD_DIR)/
	tar -xvf $(KERNEL_TAR_DIR)/$(KERNEL_TAR) -C $(BUILD_DIR)/
	tar -xvf $(BUSYBOX_TAR_DIR)/$(BUSYBOX_TAR) -C $(BUILD_DIR)/
	echo "############ prepare end ##############"

helloworld:
	echo "############ make test ${LOCAL_TEST_DIR}  ###################"
	mkdir -p $(LOCAL_TEST_DIR)
	make -C $(LOCAL_TEST_DIR) clean
	make -C $(LOCAL_TEST_DIR)
	echo "################### end ${LOCAL_TEST_DIR} ########################"


qemu_build:
	echo "############ do qemu_build compile #######"
	mkdir -p $(QEMU_DIR)/build
	mkdir -p $(QEMU_DIR)/out
	cd $(QEMU_DIR)/build & ../configure --prefix=$(QEMU_DIR)/out --target-list=arm-softmmu,i386-softmmu,x86_64-softmmu,aarch64-linux-user,arm-linux-user,i386-linux-user,x86_64-linux-user,aarch64-softmmu,mipsel-softmmu,mips64el-softmmu --audio-drv-list=alsa --enable-virtfs --enable-debug & make & make install
	echo "############ qemu_build end #########"

qemu_clean:
	echo "########### do qemu_clean #########"
	rm -rf $(QEMU_DIR)/out/*
	echo "########### qemu_clean done #########"

qemu_distclean:
	echo "########### do qemu_clean #########"
	rm -rf $(QEMU_DIR)
	echo "########### qemu_clean done #########"

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

u-boot_clean:
	echo "############ do u-boot_clean #########"
	make -C $(UBOOT_DIR) clean
	echo "############ do u-boot_clean #########"

u-boot_distclean:
	echo "############ do u-boot_distclean #########"
	make -C $(UBOOT_DIR) distclean
	echo "############ do u-boot_distclean #########"

kernel_menuconfig:
	echo "########## make kernel_menuconfig ##############"
	make -C $(KERNEL_DIR) $(KERNEL_CONF)
	make -C $(KERNEL_DIR) menuconfig 
	echo "########## make kernel_menuconfig end ###############"

kernel:
	echo "########## make kernel ##############"
	make -C $(KERNEL_DIR)
	make -C $(KERNEL_DIR) uImage LOADADDR=0x60003000
	echo "########## kernel end ###############"

kernel_clean:
	echo "########## make kernel ##############"

kernel_distclean:
	echo "########## make kernel ##############"

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

