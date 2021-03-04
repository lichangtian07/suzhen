###########################################################################################
#####  version 1.0.0 Makefile for suzhen MODEL  V1 
#####  PART 1: include Makefile  the key param  MODEL
#####  PART 2: the main param of this MODEL 
#####  
#####  PART 3: the part is same but a little different in kernel modules compile  
#####
###########################################################################################
###################################### PART 1 #############################################



ifeq ($(strip $(MODEL)),)
$(warning : usage: )
$(warning :		make MODEL=verson [command]  )
$(warning : for example: )
$(warning : 	make MODEL=V1 prepare )
$(warning : 	make MODEL=V1 qemu_build )
$(warning : 	make MODEL=V1 busybox )
$(warning : 	make MODEL=V1 kernel )
$(warning : 	make MODEL=V1 u-boot )
$(warning : make_rootfs: )
$(warning : 	./make_rootfs.sh  )
$(warning : simultion: )
$(warning : 	./run.sh uboot u-boot-2021.01 u-boot  )
$(warning : 	./run.sh uboot_nfs u-boot-2021.01 u-boot )
$(warning : 	./run.sh kernel linux-5.11/arch/arm/boot/ zImage dts/vexpress-v2p-ca9.dtb  )
$(warning : 	./run.sh rootfs linux-5.11/arch/arm/boot/ zImage dts/vexpress-v2p-ca9.dtb ./a9rootfs.ext3 )

#($(strip $(MODEL))
test:
	@echo "there is MODEL unset "

else 

COMPILE_DIR=$(CURDIR)

include $(CURDIR)/MODEL/$(MODEL)/qemu_config
include $(CURDIR)/rules.mk

#./build_dir/V1
BUILD_DIR=$(CURDIR)/build_dir/${MODEL}


QEMU_TAR_DIR=qemu
UBOOT_TAR_DIR=u-boot
KERNEL_TAR_DIR=kernel
BUSYBOX_TAR_DIR=busybox
TOOLCHAIN_TAR_DIR=toolchain


#build_dir/V1/qemu-5.2.0
#build_dir/V1/u-boot-2021.01
#build_dir/V1/linux-5.11
#build_dir/V1/busybox-1.33.0

QEMU_DIR=$(BUILD_DIR)/qemu-$(QEMU_VERSION)
UBOOT_DIR=$(BUILD_DIR)/u-boot-$(UBOOT_VERSION)
KERNEL_DIR=$(BUILD_DIR)/linux-$(KERNEL_VERSION)
BUSYBOX_DIR=$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)
TOOLCHAIN_DIR=$(BUILD_DIR)/gcc-$(TOOLCHAIN_VERSION)

#
CROSS_DIR=$(TOOLCHAIN_DIR)/bin/
#CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ)
#ARCH=$(ARCH_OBJ)


.PHONY:all u-boot kernel busybox


all: prepare qemu_build u-boot kernel busybox 
	@echo "############ do the qemu+u-boot+kernel+busybox by toolchain  #########"
	@echo "############ end ok ################ "


helloworld:
	echo "############ make test ${LOCAL_TEST_DIR}  ###################"
	mkdir -p $(LOCAL_TEST_DIR)
	make -C $(LOCAL_TEST_DIR) clean
	make -C $(LOCAL_TEST_DIR)
	echo "################### end ${LOCAL_TEST_DIR} ########################"


prepare:
	@echo "############ do prepare ############## "
	@mkdir -p $(BUILD_DIR)
	@if [ ! -d "$(QEMU_DIR)" ]; then \
		echo "the is not exist $(QEMU_DIR) " \
		tar -xvf $(QEMU_TAR_DIR)/$(QEMU_TAR) -C $(BUILD_DIR)/ ;\
	fi
	@if [ ! -d "$(UBOOT_DIR)" ]; then \
		tar -xvf $(UBOOT_TAR_DIR)/$(UBOOT_TAR) -C $(BUILD_DIR)/ ; \
	fi
	@if [ ! -d "$(KERNEL_DIR)" ]; then \
		tar -xvf $(KERNEL_TAR_DIR)/$(KERNEL_TAR) -C $(BUILD_DIR)/ ; \
	fi
	@if [ ! -d "$(BUSYBOX_DIR)" ]; then \
		tar -xvf $(BUSYBOX_TAR_DIR)/$(BUSYBOX_TAR) -C $(BUILD_DIR)/ ; \
	fi
	@if [ ! -d "$(TOOLCHAIN_DIR)" ]; then \
		tar -xvf $(TOOLCHAIN_TAR_DIR)/$(TOOLCHAIN_TAR) -C $(BUILD_DIR)/ ;\
	fi
	cp  -rf $(CURDIR)/MODEL/$(MODEL)/make_rootfs.sh $(BUILD_DIR)/ 
	cp  -rf $(CURDIR)/MODEL/$(MODEL)/run.sh $(BUILD_DIR)/ 
	@echo "############ prepare end ##############"

qemu_build:
	echo "############ do qemu_build compile #######"
	@if [ ! -d "$(QEMU_DIR)/out" ]; then \
		mkdir -p $(QEMU_DIR)/build ; \
		mkdir -p $(QEMU_DIR)/out ;\
		cd $(QEMU_DIR)/build && ../configure --prefix=$(QEMU_DIR)/out --target-list=arm-softmmu,i386-softmmu,x86_64-softmmu,aarch64-linux-user,arm-linux-user,i386-linux-user,x86_64-linux-user,aarch64-softmmu,mips-softmmu,mipsel-softmmu,mips64el-softmmu --audio-drv-list=alsa --enable-virtfs --enable-debug ;\
	fi
	make -C $(QEMU_DIR)/build 
	make -C $(QEMU_DIR)/build install 
	@if [ ! -d "$(QEMU_DIR)/out/etc/" ]; then \
		cp -rf $(CURDIR)/utils/qemu_deps/etc $(QEMU_DIR)/out ; \
	fi
	echo "############ qemu_build end #########"

qemu_clean:
	echo "########### do qemu_clean #########"
	rm -rf $(QEMU_DIR)/out
	echo "########### qemu_clean done #########"

qemu_distclean:
	echo "########### do qemu_clean #########"
	rm -rf $(QEMU_DIR)
	echo "########### qemu_clean done #########"

u-boot_menuconfig:
	echo "############ do u-boot compile #######"
	make -C $(UBOOT_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ) $(UBOOT_CONF) 
	#make -C $(UBOOT_DIR) 	
	echo "############ u-boot end #########"

u-boot:
	echo "############ do u-boot compile #######"
	#make -C $(UBOOT_DIR) $(UBOOT_CONF) 
	make -C $(UBOOT_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ)
	echo "############ u-boot end #########"

u-boot_clean:
	echo "############ do u-boot_clean #########"
	make -C $(UBOOT_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ) clean
	echo "############ do u-boot_clean #########"

u-boot_distclean:
	echo "############ do u-boot_distclean #########"
	#make -C $(UBOOT_DIR) distclean
	rm -rf $(UBOOT_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ)
	echo "############ do u-boot_distclean #########"

kernel_menuconfig:
	echo "########## make kernel_menuconfig ##############"
	make -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ) $(KERNEL_CONF)
	make -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ) menuconfig 
	echo "########## make kernel_menuconfig end ###############"

kernel:
	echo "########## make kernel ##############"
	make -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ)
	make -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ) uImage LOADADDR=0x60003000
	echo "########## kernel end ###############"

kernel_clean:
	echo "########## make kernel clean ##############"
	make -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ) clean
	echo "########## kernel clean  ##################"

kernel_distclean:
	echo "########## make kernel clean ##############"
	rm -rf $(UBOOT_DIR)
	echo "########## kernel distclean  ##############"

busybox_menuconfig:
	echo "########## make busybox_menuconfig ##############"
	make -C $(BUSYBOX_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ) defconfig 
	make -C $(BUSYBOX_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ) menuconfig 
	echo "########## make busybox_menuconfig end ###############"

busybox:
	echo "########## make busybox ##############"
	make -C $(BUSYBOX_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ)
	echo "########## busybox end ###############"

busybox_install:
	echo "########## make busybox_install ##############"
	make -C $(BUSYBOX_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ) install
	echo "########## busybox_install end ###############"

busybox_clean:
	echo "########## make busybox clean ##############"
	make -C $(BUSYBOX_DIR) CROSS_COMPILE=$(CROSS_DIR)/$(CROSS_COMPILE_OBJ) ARCH=$(ARCH_OBJ) clean 
	echo "########## busybox clean  ##################"

busybox_distclean:
	echo "########## make busybox clean ##############"
	rm -rf $(BUSYBOX_DIR)
	echo "########## busybox distclean  ##############"

endif # have the $MODEL
