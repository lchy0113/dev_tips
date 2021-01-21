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
					+-->	
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
							

```
