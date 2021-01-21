#A40i Build system(sunxi lichee)
-----

## Build Sequence.

> build.sh 의 대략적인 코드 흐름 (bootloader, kernel, android, flash image 생성 등)을 정리 한 것이다.
```
build.sh config
	|
build.sh
	|
	+--> buildroot/scripts/mkcommon.sh 
```
