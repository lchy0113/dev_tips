[A40i Develop]

<hr/>
# Develop Git Project.

a40i_develop : private.
	- branch : main
android : local
	- branch : develop/private
lichee : 
	- branch : develop/private
	- list
		brandy : lichee/brandy
		buildroot : lichee/buildroot
		linux-3.10 : lichee/linux-3.10
		tools : lichee/tools


<hr/>

#A40i Build system

## sunxi lichee tool Build Sequence.

> build.sh 의 대략적인 코드 흐름 (bootloader, kernel, android, flash image 생성 등)을 정리 한 것이다.
### bootloader compile.
> partition type : mbr
> origin defconfig : sun8iw11p1_config
```
brandy/build.sh
	|
	+--> build_uboot
		|
		+--> make
			outputmakefile
			|
			+--> mkconfig
				|
				+--> boards.cfg
					include/config.mk file 생성.
			|
			+--> overridden arch/arm/cpu/armv7/config.mk 
				CROSS_COMPILE Path 세팅.
			|
			+--> u-boot-$(CONFIG_TARGET_NAME).bin 
				./tools/add_hash_uboot.sh -f u-boot.bin -m uboot
					|
					+--> u-boot.bin의 offset(0x600)에 commit number 추가.
				u-boot 이미지를 지정된 pack 경로에 복사. 
		|
		+--> make spl
			fes, boot0 이미지 빌드. 
				fes, boot0 이미지를 지정된 pack경로에 복사.
			|
			+--> spl_make fes	(fes 는 사용하지 않음)
				timer_init, serial_init(for debug), initial pll, dram init /* fes 가 사용되는지 확인여부 */
				
			|
			+--> spl_make boot0
				timer, serial, pll, check rtc value, dram  
					|
					+--> rtc[2] value = 0x5aa5a55a 인경우, boot0 jump to 0xffff0020(FEL mode.
				load_boot1(u-boot)
					|
					+--> copy para 
				
```
### output file  
- (lichee)/tools/pack/chips/sun8iw11p1/bin/fes1_sun8iw11p1.bin
- (lichee)/tools/pack/chips/sun8iw11p1/bin/u-boot-sun8iw11p1.bin

> CONFIG_STORAGE_MEDIA_NAND, CONFIG_STORAGE_MEDIA_MMC, CONFIG_STORAGE_MEDIA_SPINOR config중 Target에 사용되는 config 확인. 

### kernel compile.
> Allwinner 사에서 제공하는 lichee  build system을 이용하여 빌드되도록 SDK가 구성되어 있음. 
```
build.sh
	|
	+--> buildroot/scripts/mkcommon.sh 
			|
			+--> source shflags
					|
					+--> flag  라이브러리이며, google-gflags와 유사하다.
			|
			+--> [ -f .buildconfig ]
				source .buildconfig
				buildconfig env 세팅. build target을 정함. 
				(example)
				export LICHEE_CHIP=sun8iw11p1
				export LICHEE_PLATFORM=androidm
				export LICHEE_KERN_VER=linux-3.10
				export LICHEE_BOARD=a40-p1
			|
			+--> source mkcmd.sh 
					|
					+--> export importance variable (kernel, 등 directory).
						LICHEE_TOP_DIR, LICHEE_BR_DIR, LICHEE_KERN_DIR, LICHEE_TOOLS_DIR, LICHEE_OUT_DIR
						mk_error, mk_warn, mk_info, check_env, init_disclaimer, init_defconf, init_chips, init_platforms, init_kernel_ver, init_boards, select_chip, select_platform, select_kern_ver, select_board, mkbr, clbr, prepare_toolchain, mkkernel, clkernel, mkboot, packtinyandroi, mkrootfs, mklichee, mkclean, mkdistclean, mkpack, mkhelp() 가 정의되어 있음.
			|
			+--> [ " x$1 " = "xconfig" ]
				$1 값이 config인 경우, config 세팅 동작을 취함.
					|
					+--> buildroot/scripts/mksetup.sh 
							기존 buildconfig을 제거 하고 새로운 buildconfig을 export취함. 
							|
							+--> init_disclaimer 
							|
							+--> select_board
								LICHEE_CHIP, LICHEE_PLATFORM, LICHEE_KERN_VER, LICHEE_BOARD
							|
							+--> init_defconf
			|
			+--> [ " x$1 " = "xpack" ]
					|
					+--> init_defconf	
					|
					+--> mkpack
						packing firmware
						pack() function을 실행시킴. 
			+--> [ " x$1 " = "xpack_debug" ]
			+--> [ " x$1 " = "xpack_dump" ]
			+--> [ " x$1 " = "xpack_secure" ]
			+--> [ " x$1 " = "xpack_prev_refurbish" ]
			+--> [ " x$1 " = "xpack_prvt" ]
			+--> [ " x$1 " = "xpack_nor" ]
			+--> [ " x$1 " = "xclean" ]
			+--> [ " x$1 " = "xdistclean" ]
			+--> [ " $# -eq 0 ]
				커널 빌드 수행. 
				|
				+--> init_defconf
					export 된 variable(chip, platform)정보를 통해 target defconf을 설정.
					buildroot/scripts/mkrule 파일에 리스트로 정의되어 있음. 
					(example)
					pattern=sun8iw11p1_androidm
					LICHEE_BR_DEFCONFIG=sun8i_defconfig
					LICHEE_KERN_DEFCONF=sun8iw11p1smp_androidm_defconfig
				|
				+--> mklichee
					build total lichee.
					|
					+--> mkbr 
						build buildroot.
						toolchain 설치 & PATH.
						(example) 
						buildroot tool path = lichee/out/${LICHEE_CHIP}/${LICHEE_PLATFORM}/common/buildroot/external-toolchain
					|
					+--> mkkernel
						build kernel.
							|
							+--> script/build.sh
								build_kernel, build_modules, build_ramfs 실행.
									|
									+--> build_kernel
										make modules 실행.
										build 이미지(ko파일 포함)를 output 경로에 복사. (Makefile 옵션 적용 검토)
									|
									+--> build_modules
										build_nand_lib, build_gpu(mali)
									|
									+--> build_ramfs
										rootfs.cpio.gz에 빌드된 ko파일을 포함하여 regenerate 및 boot.img 생성. 
										(boot.img spec)
										BASE="0x40000000"
										KERNEL_OFFSET="0x8000"
										bss_sz = bss 영역 size(offset + size)
										RAMDISK_OFFSET=0x01000000
										dtb 파일을 사용하지 않음. 
									|
									+--> gen_output
										LICHEE_PLAT_OUT(lichee/out/${LICHEE_CHIP}/${LICHEE_PLATFORM}/common 경로에 lib 파일을 포함한 output 파일 복사.
						

```

## Android compile.
> Android build 과정을 정리(A40i에 귀속된 부분만 정리)
```
(android)/device/softwinner/common/vendorsetup.sh
	|
	+--> function extract-bsp()
		bsp 및 출력 파일을 컴파일 된 Android 소스 코드의 출력 디렉토리에 복사함.
			|
			+--> get_lichee_out_dir() 
				kernel output file 디렉토리 환경변수 세팅.
			|
			+--> get_device_dir()
				target device(a40-p1) 디렉토리 환경변수 세팅.
			|
			+--> kernel(bImage), modules 파일 copy. 
				modules.mk 파일 생성. 
	|
	+--> make 
		Android build.
	|
	+--> function pack()
		package into firmware.
		|
		+--> (android)/device/softwinner/a40-p1/package.sh
			chip(sun8iw11p1), platform(androidm), board(a40-p1), debug(uart0),sigmode(none), securemode(none) para 정보 세팅후, pack 실행.
				|
				+--> (android)/../lichee/tools/pack/pack
					packing
					|
					+--> function do_prepare()
						tools_file, configs_file, boot_resource, boot_file 복사.
						IMG_NAME_세팅 후, image.cfg  파일 업데이트.
					|
					+--> function do_ini_to_dts()
						sys_config_fix.fex 업데이트. dram -> dram_para, 	nand0 -> nand0_para
						dts 파일을 사용하지 않으므로, common dts file로 대체.
						DTC_DEP_FILE=.sun8iw11p1-soc.dtb.d.dtc.tmp
						DTC_SRC_FILE=.sun8iw11p1-soc.dtb.dts
					|
					+--> function do_common()
						fastdtb command 를 사용하여 dtb 정보에 추가 size 만큼 데이터를 추가. (fastdtb command 확인)
						update_uboot_fdt command 를 사용하여 u-boot.bin정보에 dtb  정보를 추가.
							u-boot.fex len = u-boot.fex len + sunxi.fex len 
						boot0 image 업데이트.
							bootloader 에서 빌드된 boot0 이미지에 sys_config 데이터 추가.
						u-boot.fex 업데이트.
						fes1.fex 업데이트.
						boot-resource.ini 업데이트.
						dragonsecboot -pack boot_package.cfg 
							|
							+--> boot_package.cfg  의 정보를 읽어 bootloader(u-boot.fex) pack.
						u_boot_env_gen 
							|
							+--> generate the u-boot env partition from config file.
								env의 comment를 제거하고  0x20000 length 의 fex file 출력.
					|
					+--> function do_pack_androidm()
						boot.img, system.img, recovery.img 를 링크	
					|
					+--> function do_finish()
						sys_partition.bin 업데이트.
						dragon image.cfg sys_partition.fex
							하나의 이미지로 pack. 
			

```

<hr/>

# pack 

## boot0 
- tools/pack/chips/sun8iw11p1/bin/ 경로의 bin 파일을  out 경로에 복사한다. 
```
boot_file_list=(
chips/${PACK_CHIP}/bin/boot0_nand_${PACK_CHIP}.bin:out/boot0_nand.fex
chips/${PACK_CHIP}/bin/boot0_sdcard_${PACK_CHIP}.bin:out/boot0_sdcard.fex
chips/${PACK_CHIP}/bin/boot0_spinor_${PACK_CHIP}.bin:out/boot0_spinor.fex
...
)

pintf "copying boot file\n"
for file in ${boot_file_list[@]} ; do
	cp -f `echo $file | awk -F: '{print $1}'` \
		`echo $file | awk -F: '{print $2}'` 2 >/dev/null
done
```
- sys_config.bin을 통해 boot0 을 업데이트하고 boot0_sdcard.fex를 생성함.
```
update_boot0 boot0_sdcard.fex sys_config.bin SDMMC_CARD > /dev/null
```

## u-boot 
- brandy/build.sh는 u-boot를 컴파일하여 tools/pack/chips/${PACK_CHIP}/bin/ 경로에 복사한다.  

```
boot_file_list=(
...
chips/${PACK_CHIP}/bin/u-boot-${PACK_CHIP}.bin:out/u-boot.fex
...
)

pintf "copying boot file\n"
for file in ${boot_file_list[@]} ; do
	cp -f `echo $file | awk -F: '{print $1}'` \
		`echo $file | awk -F: '{print $2}'` 2 >/dev/null
done
```
- sys_config을 통해 uboot파일헤더의 메타데이터를 업데이트한다.
```
update_uboot u-boot.fex sys_config.bin > /dev/null
```

> offset address 0xda800
```
update_uboot_fdt u-boot.fex sunxi.fex u-boot.fex
```

## sys_config
> sys_config 는 Allwinner sunxi 의 구성 script로서 Linux kernel 의 DTS와는 다르지만 DTS 와 유사하게 동작.

- dts를 통해 sunxi.dtb를 생성하려면 sys_config.fex 를 사용.
```
local DTC_INI_FILE_BASE=${LICHEE_OUT}/../../../../tools/pack/out/sys_config.fex
local DTC_INI_FILE=${LICHEE_OUT}/../../../../tools/pack/out/sys_config_fix.fex
local DTC_DEP_FILE=${LICHEE_OUT}/../../../../$PACK_KERN/arch/$ARCH/boot/dts/.${PACK_CHIP}-soc.dtb.d.dtc.tmp
local DTC_SRC_FILE=${LICHEE_OUT}/../../../../$PACK_KERN/arch/$ARCH/boot/dts/.${PACK_CHIP}-soc.dtb.dts
cp $DTC_INI_FILE_BASE $DTC_INI_FILE

$DTC_COMPILER -O dtb -o ${LICHEE_OUT}/sunxi.dtb	\
		-b 0									\
		-i $DTC_SRC_PATH						\
		-F $DTC_INI_FILE						\
		-d $DTC_DEP_FILE	$DTC_SRC_FILE
```

- sys_config.bin을 생성하여 config.fex를 복사한다. 
- sys_config.bin은 나중에 다른 파일을 업데이트 하는데 사용된다. 
- config.fex는 일시적으로 사용되지 않는다.
```
busybox unix2dos sys_config.fex
script sys_config.fex > /dev/null
cp -f sys_config.bin config.fex
```

- sys_config.bin을 사용하여 boot0, uboot, fes1, toc0 을 업데이트 한다. 
```
update_boot0 boot0_spinor.fex	sys_config.bin SDMMC_CARD > /dev/null
update_uboot u-boot-spinor.fex	sys_config.bin > /dev/null

update_boot0 boot0_nand.fex		sys_config.bin NAND > /dev/null
update_boot0 boot0_sdcard.fex	sys_config.bin SDMMC_CARD > /dev/null

update_uboot u-boot.fex			sys_config.bin > /dev/null
update_fes1	 fes1.fex			sys_config.bin > /dev/null
update_toc0  toc0.fex			sys_config.bin
```

## dts
> sys_config.fex를 사용하여 dts를 통해 sunxi.dtb 파일 생성.
```
$DTC_COMPILER -O dtb -o ${LICHEE_OUT}/sunxi.dtb	\
	-b 0						\
	-i $DTC_SRC_PATH			\
	-F $DTC_INI_FILE			\
	-d $DTC_DEP_FILE $DTC_SRC_FILE
```

> 생성된 sunxi.fex를 복사하고 uboot 이미지에 병함.
> Offset addr : 0xda800
```
update_uboot_fdt	u-boot.fex sunxi.fex u-boot.fex
```
```
hexdump -C -n 1000 tools/pack/out/sunxi.fex
hexdump -C -n 1000 -s 0xda800 tools/pack/out/u-boot.fex
```

## boot-resource
> boot-resource는 uboot에서 부팅에 사용되는 리소스 파일(부팅화면).

## bootimg (kernel+ramdisk)
> boot.img는 android 부팅용 커널 형식으로 파일 헤더와 커널, 램디스크가 포함되어 있음.


<hr/>

# script.bin
-----
> script.bin은 커널에서 사용되는 board-specific binary 즉, 'configuration file'이며 주변 장치, I/O pin 셋업을 명시한다.
> Sunxi-tools를 사용하여 bin <-> fex 변환한다. 

## Build script.bin
### Get bin2fex utility
### Get sunxi-boards repository


<hr/>

# FEL/USBBoot
 Allwinner SoC 는 USB OTG를 통한 부팅이 가능하다. 

## Install the tools
project : https://github.com/linux-sunxi/sunxi-tools

## Switch device into FEL mode
> sunxi-tool을 통한 device와 통신을 위해선 device가 FEL mode에 진입해야 한다.
- boot0 에서 2 key  입력.
- 전원 인가 후 u-boot 버튼 입력.(EVBoard 기준)
- adb reboot efex


