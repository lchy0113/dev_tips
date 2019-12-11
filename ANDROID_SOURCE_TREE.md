
Android source tree
=====
＊ bionic – bionic libc(BSD의 libc 수정)를 포함  
＊ bootable - bootloader, recovery mode 관련 코드  
＊ build - 빌드 관련 스크립트를 저장  
· envsetup.sh  
‥ build shell script들이 있음, 툴체인 경로 설정등 환경설정  
· generic board에 대한 configuration  
‥ build/target/board/generic/device.mk  
… root filesystem의 구성을 어떻게 해야하는가에 대한 방향을 지정하는 파일  
… android 최종 결과물 구성시 자동으로 포함하고 싶은 binary들에 대한 install을 결정  
‥ build/target/board/generic/BoardConfig.mk  
… Android의 makefile인 Android.mk에 기본적으로 포함되는 최상위 Makefile  
… 주로 HAL 혹은 기능들에 대한 enable/disable과 관련이 깊음  
… Android.mk 파일에 영향을 주고 Android.mk 파일에서 define을 제어할 수 있도록 설정하는 경우가 많음  
… ex> BoardConfig.mk의 BOARD_USES_GENERIC_AUDIO := true 의 경우  
• frameworks/base/services/audioflinger/Android.mk  
• frameworks/base/services/audioflinger/AudioHardwareInterface.cpp  
• 파일의 해당 부분을 참조  
＊ CTS – Compatibility Test Suite관련 소스 디렉토리  
＊ dalvik - dalvik VM 관련 소스코드  
＊ development – 개발용 app등…  
