#A40i Build system
-----

## sunxi lichee tool Build Sequence.

> build.sh 의 대략적인 코드 흐름 (bootloader, kernel, android, flash image 생성 등)을 정리 한 것이다.
```
build.sh config
	|
build.sh
	|
	+--> buildroot/scripts/mkcommon.sh 
			|
			+--> 
				source shflags
					|
					+--> flag  라이브러리이며, google-gflags와 유사하다.
				
				buildconfig env 세팅. build target을 정함. 
				export LICHEE_CHIP=sun8iw11p1
				export LICHEE_PLATFORM=androidm
				export LICHEE_KERN_VER=linux-3.10
				export LICHEE_BOARD=a40-p1
				
				source mkcmd.sh 
					|
					+--> export importance variable (kernel, 등 directory).
					LICHEE_TOP_DIR, LICHEE_BR_DIR, LICHEE_KERN_DIR, LICHEE_TOOLS_DIR, LICHEE_OUT_DIR
					mk_error, mk_warn, mk_info, check_env, init_disclaimer, init_defconf, init_chips, init_platforms, init_kernel_ver, init_boards, select_chip, select_platform, select_kern_ver, select_board, mkbr, clbr, prepare_toolchain, mkkernel, clkernel, mkboot, packtinyandroi, mkrootfs, mklichee, mkclean, mkdistclean, mkpack, mkhelp() 가 정의되어 있음.
```
