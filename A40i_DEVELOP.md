#A40i Build system
-----

## sunxi lichee tool Build Sequence.

> build.sh 의 대략적인 코드 흐름 (bootloader, kernel, android, flash image 생성 등)을 정리 한 것이다.
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
							fastdtb : [   dtb len=0x000155f3  ] + [  len=0x0001 114d   ]
						update_uboot_fdt command 를 사용하여 u-boot.bin정보에 dtb  정보를 추가.
							u-boot.fex len = u-boot.fex len + sunxi.fex len 
						boot0 image 업데이트.
							bootloader 에서 빌드된 boot0 이미지에 sys_config 데이터 추가.
						u-boot.fex 업데이트.
						fes1.fex 업데이트.
						boot-resource.ini 업데이트.
					|
					+--> function do_pack_androidm()
						boot.img, system.img, recovery.img 를 링크	
					|
					+--> function do_finish()
						sys_partition.bin 업데이트.
						dragon image.cfg sys_partition.fex
							하나의 이미지로 pack. 
			

```

