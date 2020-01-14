
Android NDK 를 이용한 소스코드 크로스 컴파일.
=====

 NDK(Native Development Kit)
-----
C/C++ 같은 네이티브 코드 언어를 안드로이드에서 사용할 수 있게 도와주는 도구 모음



 JNI(Java Native Interface)
-----
Java가 C/C++ 같은 네이티브 코드 언어로 작성된 어플리케이션과 상호 작용할 수 있는 인터페이스



더 자세한 내용은 Android NDK Guides(https://developer.android.com/ndk/guides/)를 참고하시면 됩니다.
아래에 빌드와 관련된 내용도 위 가이드에 포함되어 있습니다.




0. 목표
-----
리눅스에서 C 언어로 작성된 프로그램을 안드로이드에서 실행



1. Android NDK 다운로드
-----
https://developer.android.com/ndk/ 에 접근하여 NDK 다운로드

Linux 64비트 (x86): android-ndk-r14b-linux-x86_64.zip



2. jni 디렉터리 생성
-----
압축 풀고 android-ndk-r14b 디렉터리로 이동하여 jni 디렉터리 생성
```
$ unzip android-ndk-r14b-linux-x86_64.zip
$ cd android-ndk-r14b
$ mkdir jni
```


3. 소스코드 파일 생성
-----
간단한 hello, world 문자열을 출력하는 C 코드 파일 생성
```
$ cat > hello.c
#include <stdio.h>

int main() {
	printf("hello, world\n");
	return 0;
}
```


4. Android.mk 파일 생성
-----
```
$ cat > Android.mk

# 빌드가 작업되는 위치를 지정
# $(call my-dir): 현재 위치를 반환

LOCAL_PATH := $(call my-dir)

# $(CLEAR_VARS): LOCAL_PATH를 제외한 LOCAL_MODULE, LOCAL_SRC_FILES와 같은 수많은 LOCAL_XXX 변수를 초기화

include $(CLEAR_VARS)

# C/C++ 소스코드 빌드할 때 사용할 옵션
# -pie -fPIE: PIE(Position Independant Executable) 옵션, -fPIE(compiler option), -pie(linker option)

LOCAL_CFLAGS += -fPIE -pie

# 파일명 지정

LOCAL_MODULE := hello

# 소스코드 파일 지정

LOCAL_SRC_FILES := hello.c

# 실행 가능한 바이너리 생성
# 라이브러리 생성 시에는 BUILD_SHARED_LIBRARY, BUILD_STATIC_LIBRARY 등을 사용

include $(BUILD_EXECUTABLE)
```

5. ndk-build로 빌드
-----
상위 디렉터리로 이동 후 ndk-build 바이너리를 이용해서 빌드
```
$ cd ..

$ ./ndk-build
```

APP_ABI를 이용하여 특정 아키텍처만 빌드하도록 설정 가능
```
$ ./ndk-build APP_ABI=arm64-v8a
```


6. 바이너리 실행
-----
빌드가 완료되면 libs 디렉터리에 아키텍처 별로 바이너리가 생성

(특정 아키텍처를 지정한 경우 해당 아키텍처만 생성)
```
$ adb push libs/arm64-v8a/hello /data/local/tmp/hello

$ adb shell ./data/local/tmp/hello

hello, world

```
