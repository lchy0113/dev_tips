# 안드로이드 SELinux
=====

 이 문서는 새로운 device 나 properties 을 사용하기 위해 SELinux authorizing process(domain)와 관련된 파일을 추가하거나 수정하는 방법을 설명합니다.


-------------------------------------------------------------



# 1. SELinux 관련 Android 설정 및 파일.
-----

 'user'모드로 Android SDK (Software Development Kit)를 빌드하면 SELinux가 활성화 된 다음 'Enforcing'mode가 기본값으로 설정됩니다.


 'A'기기에 대한 권한을 얻지 못한 프로세스는 'A'기기를 사용할 수 없습니다. 
 이를 피하려면‘eng’mode 내장 환경에서‘A’장치 (또는 사용하려는 프로세스)와 관련된 파일을 추가하거나 SELinux 파일을 수정해야합니다.

* SELinux 정책에는 세 가지 모드가 있으며 booting-command line 옵션으로 그 중 하나를 선택할 수 있습니다.

- Permissive – SELinux 보안 정책이 적용되지 않고 기록됩니다.
- Enforcing – 보안 정책이 시행되고 기록됩니다. 사용자 모드의 경우 이것이 기본값입니다.
- Disabled - 비활성화.


 device/telechips/tcc898x/BoardConfig.mk 에서 코드를 확인 할 수 있다. 
 AOSP(Android Open Source Project) Android SDK 는 system/sepolicy directory 에  SDLinux 파일이 있다.
 vendor 사의 보안 정책에 대한 파일은 device/telechips/tcc898x/sepolicy 디렉토리에 추가된다.
 
 프로세스에 새 장치를 추가하고 해당 장치에 대한 권한을 부여해야 하는 경우 위의 파일을 추가하거나 디렉토리에서 정책 파일을 수정하면 된다. 
 그렇지 않으면 enforcing policy mode 를 사용할 때 코드가 동작되지 않는다. 

# 2. Guideline.
-----

# 2.1 device 추가 방법.
-----
 
# 2.1.1
 추가된 장치의 권한이 없는 프로세스는 SELinux 환경에서 장치를 사용할 수 없다.

# 2.1.2
 Android SDK (AOSP)의 대부분의 장치는 System/sepolicy/private(or vendor)/file_context에 정의 되어 있다.

# 2.1.3 
 파일에서 장치를 찾을 수 없으면 device/telechips/tcc898x/sepolicy/file_context에 코드를 추가한다.

# 2.1.4 
 예를 들어, /dev/mali 및 /dev/vpu_vdec은 /system/sepolicy/private/file_contexts에 정의 되어 있지 않다.  아래와 같이 device/telechips/tcc898x/sepolicy/file_contexts에 코드를 추가해야 한다. 
# 2.1.4.1
 /dev/mali u:object_r:gpu_device:s0
# 2.1.4.2
 /dev/vpu_.* u:object_r:vpu_device:s0
# 2.1.4.3
 system/sepolicy/public/device.te에서 'gpu_device' type을 찾을 수 있다. 그러나 파일에 'vpu_device'type이 없다.  device/telechips/tcc898x/device.te에서 'vpu_type'을 정의해야 한다.

# 2.1.5
 장치를 사용하는 프로세스에 권한을 부여해야 한다. 그렇지 않으면 프로세스가 장치를 사용할 수 없으며, warning message("avc: denied")가 출력된다. 
 예를 들어 "/dev/graphics/fb0" 장치를 추가했는데 mediaserver 프로세스가 장치를 열려고 하면 아래와 같이 로그가 출력된다.
# 2.1.5.1
 ```
 avc: denied {open} for pied = 1493 comm="mediaserver" path="/dev/graphics/fb0" dev="tmpfs ino=8724 scontext=u:r:mediaserver:s0 tcontext=u:object_r:graphics_devices:s0 tclass=chr_file permissive=1"
 ```
# 2.1.5.2
 디버깅하기 위해 아래 코드를 system/sepolicy/public/mediaserver.te 가 아닌  device/telechips/tcc898x/sepolicy/mediaserver.te에 추가해야 한다. 
 ```
 allow mediaserver graphics_device:chr_file open;
 ```

# 2.1.6
 shell command "ls -Z" 를 사용하여 장치가 제대로 등록되었는지 확인할 수 있다.
 ```
 ls -Z /dev/mali show “crw-rw-rw- system system u:object_r:gpu_device:s0 mali”
 ```

# 2.2 process 추가 방법.(domain)
-----

# 2.2.1
 Android 시스템에서 사용되는 대부분의 프로세스 (surfacefliger, mediaserver 등)는 system/sepolicy/에서 .te 파일로 정외 된다. 
 프로스의 .te파일이 system/sepolicy에 존재 하지 않으면 device/telechips/tcc898x/sepolicy 에 새로운 .te 파일을 작성해야 한다. 

# 2.2.2
 예를 들어 TCC Dxb 서비스의 경우, tcc_dxb_service.te 가 device/telechips/tcc898x/sepolicy 에 추가되어 있다. 

# 2.2.3
 파일을 열고 코드를 추가하여 아래와 같이 type 과 domain 을 설정한다. 
# 2.2.3.1
 ```
 type tcc_dxb_service, domain;
 ```
# 2.2.3.2
 ```
 type tcc_dxb_service_exec, exec_type, file_type;
 ```
# 2.2.3.3
 초기화 과정에서 생성되는 경우, 
 ```
 init_daemon_domain(tcc_dxb_service)
 ```

# 2.2.4
 코드를 추가하여 등록한다. 
 ```
 /system/bin/tcc_dxb_service u:object_r:tcc_dxb_service_exec:s0
 ```

# 2.2.5
 compile 및 download.

# 2.2.6
 부팅 후, "ps -Z" 명령을 입력하면 아래 메시지를 볼 수 있다. 
 ```
 u:r:tcc_dxb_service:s0 root 1526 1 /system/bin/tcc_dxb_service
 ```

# 2.2.7
 서비스를 실행 하면 더 많은 warning message가 출력된다. 
 device/telechips/tcc898x/sepolicy 에서 tcc_dxb_service.te 및 other .te 파일을 수정하며 warning messages를 디버그 한다. 
# 2.2.7.1
 add code “allow tcc_dxb_service servicemanager:binder call;”
 ```
 avc: denied { call } for pid=1497 comm="tcc_dxb_service" scontext=u:r:tcc_dxb_service:s0 tcontext=u:r:servicemanager:s0 tclass=binder permissive=1
 ```
# 2.2.7.2
 add code allow tcc_dxb_service vpu_device:chr_file open;
 ```
 avc: denied { open } for pid=1497 comm="tcc_dxb_service" scontext=u:r:tcc_dxb_service:s0 tcontext=u:r:vpu_device:s0 tclass=chr_file permissive=1
 ```

 Note: All permissions are not granted to a process. Note that “neverallow” policy with reference to system/sepolicy/public/domain.te,
app.te, etc. If your code violates the policy, a compile error occurs.
