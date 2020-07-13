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



=====

##  SELinux 정책파일(.te) 사용법. (Android 5.x) 
=====

1. `BOARD_SEPOLICY_REPLACE` :
> external/sepolicy의 파일을 BOARD_SEPOLICY_REPLACE 파일로 치환한다.

2. `BOARD_SEPOLICY_UNION` :
> external/sepolicy의 파일에 BOARD_SEPOLICY_UNION의 파일을 추가한다.

3. `BOARD_SEPOLICY_DIRS` :
> BOARD_SEPOLICY_REPLACE, BOARD_SEPOLICY_UNION의 파일이 위치한 폴더리스트 이며, 치환, 혹은 추가할 파일을 찾지 못하면 오류가 발생한다. 
> 파일 생성 후, out/target/product/<device>/etc/sepolicy_intermediates/policy.conf 에서 확인 할 수 있다.

4. `BOARD_SEPOLICY_IGNORE` : 
> 정책파일에서 제외되어야 할 것으로 제거의 의미이다.
> 예) 
```
 BOARD_SEPOLICY_DIRS += X Y
 BOARD_SEPOLICY_REPLACE += A
 BOARD_SEPOLICY_IGNORE += X/A
```
> 폴더 X,Y 가 있고, A의 파일을 치환하면, X/A, Y/A가 되며, 
> 여기서 X/A를 제거하면 결국 Y/A만 남게 된다. 



## 초기화 코드 확인.
=====
system/core/init/init.c의 main() 함수에서 selinux_initialize()의 호출로 SELinux의 초기화가 시작된다.

system/core/init/init.c :
```
int main(int argc, char **argv)
{
...
	union selinux_callback cb;
	cb.func_log = log_callback;
	selinux_set_callback(SELINUX_CB_LOG, cb);
	cb.func_audit = audit_callback;
	selinux_set_callback(SELINUX_CB_AUDIT, cb);
	selinux_initialize();
...
	return 0;
}
```
> ▶selinux_initialize() 는 SElinux 관련 함수 초기화를 수행합니다. 
> SElinux 가 disable 되었는지의 여부를 먼저 확인후,
> 정책파일을 읽은 후, 오류가 있으면 recovery 모드로 안드로이드를 재 부팅 시킵니다.
> 정상적으로 정책파일이 로드되었으면, SElinux 관련 모든 핸들러들을 초기화 시키고, 
> enforcing 모드인지 확인후 현재 모드로 재 설정을 하게 됩니다.

system/core/init/init.c :
```
static void selinux_initialize(void)
{
	if (selinux_is_disabled()) {
		return;
	}
	INFO("loading selinux policy\n");
	if (selinux_android_load_policy() < 0) {
		ERROR("SELinux: Failed to load policy; rebooting into recovery mode\n");
		android_reboot(ANDROID_RB_RESTART2, 0, "recovery");
		while (1) { pause(); } // never reached
	}
	selinux_init_all_handles();
	bool is_enforcing = selinux_is_enforcing();
	INFO("SELinux: security_setenforce(%d)\n", is_enforcing);
	security_setenforce(is_enforcing);
}
```
> ▶selinux_is_disabled(void) 함수는 Android.mk의 -DALLOW_DISABLE_SELINUX 의 컴파일러 외부정의에 의하여 설정되며, 
> userdebug, eng 모드일 경우 활성화 됩니다.
> 활성화 체크 하는 방법은 /sys/fs/selinux 폴더를 체크 하거나, property값중 ro.boot.selinux의 값을 읽어 확인합니다.

system/core/init/init.c : 
```
static bool selinux_is_disabled(void)
{
#ifdef ALLOW_DISABLE_SELINUX
	char tmp[PROP_VALUE_MAX];
	if (access("/sys/fs/selinux", F_OK) != 0) {
		/* SELinux is not compiled into the kernel, or has been disabled
		* via the kernel command line "selinux=0".
		*/
		return true;
	}
	if ((property_get("ro.boot.selinux", tmp) != 0) && (strcmp(tmp, "disabled") == 0)) {
		/* SELinux is compiled into the kernel, but we've been told to disable it. */
		return true;
	}
#endif
	return false;
}

```

system/core/init/Android.mk : 
```
...
...
ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
LOCAL_CFLAGS += -DALLOW_LOCAL_PROP_OVERRIDE=1 -DALLOW_DISABLE_SELINUX=1
endif
...
```

> ▶selinux_android_load_policy()은  external/libselinux/src/android.c에 라이브러리 형태로 위치 하고 있으며, 
> 내부적으로는 set_selinuxmnt()  호출 후  selinux_android_load_policy_helper() 를 호출합니다.

external/libselinux/src/android.c :
```
int selinux_android_load_policy(void)
{
	const char *mnt = SELINUXMNT;
	int rc;
	rc = mount(SELINUXFS, mnt, SELINUXFS, 0, NULL);
	if (rc < 0) {
		if (errno == ENODEV) {
			/* SELinux not enabled in kernel */
			return -1;
		}
		if (errno == ENOENT) {
			/* Fall back to legacy mountpoint. */
			mnt = OLDSELINUXMNT;
			rc = mkdir(mnt, 0755);
			if (rc == -1 && errno != EEXIST) {
				selinux_log(SELINUX_ERROR,"SELinux: Could not mkdir: %s\n",
				strerror(errno));
				return -1;
			}
			rc = mount(SELINUXFS, mnt, SELINUXFS, 0, NULL);
		}
	}

	if (rc < 0) {
		selinux_log(SELINUX_ERROR,"SELinux: Could not mount selinuxfs: %s\n",
		strerror(errno));
		return -1;
	}
	set_selinuxmnt(mnt);
	return selinux_android_load_policy_helper(false);
}

```

> ▶selinux_android_load_policy_helper() 은 정책 로딩을 위한 메모리 맵핑을 하고, security_load_policy() 호출에 의해 정책이 로드 된다.

external/libselinux/src/android.c
```
static int selinux_android_load_policy_helper(bool reload)
{
...
	map = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
...
	rc = security_load_policy(map, sb.st_size);
...
	return 0;
}
```

> ▶security_load_policy() 는 selinux_mnt 폴더의 load 파일을 열어 정책파일을 기록한다.

/external/libselinux/src/policy.h 
```
#define SELINUXMNT "/sys/fs/selinux"
```

/external/libselinux/src/load_policy.c 
```
int security_load_policy(void *data, size_t len)
{
...
	snprintf(path, sizeof path, "%s/load", selinux_mnt);
	fd = open(path, O_RDWR);
	if (fd < 0)
	return -1;
	ret = write(fd, data, len);
...
return 0;
}
```

> ▶selinux_init_all_handles 는 sehandle와 sehandle_prop 핸들을 설정하며, 관련한 파일은 아래와 같다.

/external/libselinux/src/android.c 
```
#define POLICY_OVERRIDE_VERSION "/data/security/current/selinux_version"
#define POLICY_BASE_VERSION  "/selinux_version"
```

> ▶selinux_is_enforcing() 은 enforcing이 설정되었는지 체크 하며, 기본값은 enforcing 모드이다. 
> 확인 방법은 ro.boot.selinux의 값을 읽고, 설정이 안되었으면  enforcing 모드라 가정하며, 
> permissive 모드이면 fasle를 반환한다. 그외 나머지 값은 enforcing 모드라고 가정한다.

system/core/init/init.c
```
static bool selinux_is_enforcing(void)
{
#ifdef ALLOW_DISABLE_SELINUX
	char tmp[PROP_VALUE_MAX];
	if (property_get("ro.boot.selinux", tmp) == 0) {
		/* Property is not set. Assume enforcing */
		return true;
	}
	if (strcmp(tmp, "permissive") == 0) {
		/* SELinux is in the kernel, but we've been told to go into permissive mode */
		return false;
	}
	if (strcmp(tmp, "enforcing") != 0) {
		ERROR("SELinux: Unknown value of ro.boot.selinux. Got: \"%s\". Assuming enforcing.\n", tmp);
	}
#endif
	return true;
}
```
> ▶security_setenforce()  호출을 마지막으로 selinux_mnt의 enforce 파일에 enforcing 모드값을 설정하고 초기화를 완료한다.

external/libselinux/src/setenforce.c
```
int security_setenforce(int value)
{
...
	snprintf(path, sizeof path, "%s/enforce", selinux_mnt);
	fd = open(path, O_RDWR);
	if (fd < 0)
	return -1;
	snprintf(buf, sizeof buf, "%d", value);
	ret = write(fd, buf, strlen(buf));
...
	return 0;
}
```


##  정책파일 .te의 사용법
=====
 sepolicy에 있는 .te파일에 정책설정하는 방법에 대해 알아보겠다. 
 사용법에 관한 내용은 NSA사이트를 참고했으며, TE설정파일의 예를 보면 아래와 같다.

| Filename                    | Description                                                             |
|-----------------------------|-------------------------------------------------------------------------|
| tunables/*.tun              | Defines policy tunables for customization.                              |
| attrib.te                   | Defines type attributes.                                                |
| macros/program/*.te         | Defines macro for specific program domains.                             |
| macros/*.te                 | Defines commonly used macros.                                           |
| types/*.te                  | Defines general types.                                                  |
| domains/user.te             | Defines unprivileged user domains.                                      |
| domains/admin.te            | Defines administrator domains.                                          |
| domains/misc/*.te           | Defines miscellaneous domains not associated with a particular program. |
| domains/program/*.te        | Defines domains for specific programs.                                  |
| domains/program/unused/*.te | Optional domains for further programs.                                  |
| assert.te                   | Defines assertions on the TE configuration.                             |


이를 기준으로 햄머헤드의 BOARD_SEPOLICY_UNION 설정파일중 몇개를 확인해 보도록 하겠습니다.  
attrib.te 파일은 attributes을 정의한 것으로 되어 있으나, android-5.0.0_r2  
에는 attrib.te 대신 external/sepolicy/attributes의 파일이 있습니다. dev_type의 속성은 주로 device.te 파일에, file_type,  
data_file_type의 속성은 file.te에 사용되고 있습니다. device.te는 디바이스와 관련된 설정이며, file.te는 파일과 관련된 설정이라 할 수 있습니다.  

external/sepolicy/attributes:
```
######################################
# Attribute declarations
#
# All types used for devices.
attribute dev_type;
# All types used for processes.
attribute domain;
# All types used for filesystems.
attribute fs_type;
# All types used for context= mounts.
attribute contextmount_type;
# All types used for files that can exist on a labeled fs.
# Do not use for pseudo file types.
attribute file_type;
# All types used for domain entry points.
attribute exec_type;
# All types used for /data files.
attribute data_file_type;
# All types use for sysfs files.
attribute sysfs_type;
...
```

카메라와 관련된 정책파일인 camera.te를 보면 크게 type, allow, type_transition, macros 4가지를 사용하고 있음을 볼수 있다. 

1.` type :` 
```
type camera, domain;
type camera_exec, exec_type, file_type;
```
> 타입은 말 그대로 형태를 선언하는 것으로 주로 사용하는 카메라 타입은 프로세스 형태의 도메인과
> 카메라 실행타임은 실행형 타임과 
> 파일형 타임의 특성을 가진 것으로 선언 되어 있습니다. 

2. ` allow :`
```
allow camera self:process execmem;
```
> 카메라 타입은 자기 자신의 프로세스를 메모리 상에 실행가능하게 허락하는 설정이다. 
> execmem은  external/sepolicy/access_vector에 class process내에 선언되어 있다.

3. `type_transition :`
```
type_transition camera system_data_file:sock_file camera_socker "cam_socket1";
```
> 타입변환은 camera 타입의 system_data_file:sock을 camera_socket의 "cam_socket1"으로 변환하는 설정이다.

4. `macro :`
```
unix_socket_connect(camera, sensors, sensors)
```
> unix_socket_connect의 경우, 여러 .te 파일에서 사용되고 있으며, 정의된 곳은 te_macros에 정의되어 있으며,아래와 같다. 
> 매크로는 define으로 시작하여 선언되며, ()로 안에 구성을 하기 된다.

external/sepolicy/te_macros 
```
...
#####################################
# unix_socket_connect(clientdomain, socket, serverdomain)
# Allow a local socket connection from clientdomain via
# socket to serverdomain.
define(`unix_socket_connect', `
allow $1 $2_socket:sock_file write;
allow $1 $3:unix_stream_socket connectto;
')
...
```

device/lge/hammerhead/sepolicy/camera.te
```
# Qualcomm MSM camera
type camera, domain;
type camera_exec, exec_type, file_type;
# Started by init
init_daemon_domain(camera)
 init_daemon_domain
allow camera self:process execmem;
# Interact with other media devices
allow camera camera_device:dir search;
allow camera { gpu_device video_device camera_device }:chr_file rw_file_perms;
allow camera { surfaceflinger mediaserver }:fd use;
# Create front and back camera sockets (/data/cam_socket[12])
type_transition camera system_data_file:sock_file camera_socket "cam_socket1";
type_transition camera system_data_file:sock_file camera_socket "cam_socket2";
allow camera camera_socket:sock_file { create unlink };
allow camera system_data_file:dir w_dir_perms;
allow camera system_data_file:sock_file unlink;
type_transition camera system_data_file:file camera_data_file "fdAlbum";
allow camera camera_data_file:file create_file_perms;
# Connect to sensor socket (/data/app/sensor_ctl_socket)
allow camera apk_data_file:dir r_dir_perms;
unix_socket_connect(camera, sensors, sensors)
allow camera sensors_socket:sock_file read;
allow camera sensors_device:chr_file rw_file_perms;
# Read camera files from persist filesystem
allow camera persist_file:dir search;
r_dir_file(camera, persist_camera_file)
```

> 컨텍스트의 확인은 ls -Z로 확인할 수 있으며, 아래의 file_context에 대하여 살펴보면, 
> 크게 형태가 u:object_r:type_s#의 형태로 되어 있음을 볼 수 있으며, 각 의미하는 바는 아래와 같다.
>> u : user를 뜻하며 object를 기본적으로 가지고 있다.
>> r : role을 뜻함
>> type : 정책 타입을 말하며, 예로 device type, process type, file system type, network type, IPC type 등이 있다.
>> s : security Level(MLS의 확장기능)로 보안 레벨을 의미한다.

/device/lgd/hammerhead/sepolicy/file_contexts :
```
# GPU device
/dev/kgsl-3d0  u:object_r:gpu_device:s0
/dev/kgsl u:object_r:gpu_device:s0
# Bluetooth
/dev/ttyHS99 u:object_r:hci_attach_dev:s0
# nfc
/dev/bcm2079x u:object_r:nfc_device:s0
# Used by keystore to access trustzone
/dev/qseecom u:object_r:tee_device:s0
# GPS
/dev/gss u:object_r:sensors_device:s0
...
```
> 마지막으로 파일 및 폴더에 대한 권한은 external/sepolicy/global_macros에서 찾아 볼 수 있으며,
> 3가지 일반적인 그룹으로 나뉘어 있으며, object class, permission, socket 그룹으로 나뉘어 있습니다.

external/sepolicy/global_macros:
```
#####################################
# Common groupings of object classes.
#
define(`capability_class_set', `{ capability capability2 }')
define(`devfile_class_set', `{ chr_file blk_file }')
define(`notdevfile_class_set', `{ file lnk_file sock_file fifo_file }')
 고무다라
  정책파일
 사용법
define(`file_class_set', `{ devfile_class_set notdevfile_class_set }')
define(`dir_file_class_set', `{ dir file_class_set }')
define(`socket_class_set', `{ socket tcp_socket udp_socket rawip_socket netlink_socket packet_socket
key_socket unix_stream_socket unix_dgram_socket appletalk_socket netlink_route_socket netlink_firewall_socket
netlink_tcpdiag_socket netlink_nflog_socket netlink_xfrm_socket netlink_selinux_socket netlink_audit_socket
netlink_ip6fw_socket netlink_dnrt_socket netlink_kobject_uevent_socket tun_socket }')
define(`dgram_socket_class_set', `{ udp_socket unix_dgram_socket }')
define(`stream_socket_class_set', `{ tcp_socket unix_stream_socket }')
define(`unpriv_socket_class_set', `{ tcp_socket udp_socket unix_stream_socket unix_dgram_socket }')
define(`ipc_class_set', `{ sem msgq shm ipc }')
#####################################
# Common groupings of permissions.
#
define(`x_file_perms', `{ getattr execute execute_no_trans }')
define(`r_file_perms', `{ getattr open read ioctl lock }')
define(`w_file_perms', `{ open append write }')
define(`rx_file_perms', `{ r_file_perms x_file_perms }')
define(`ra_file_perms', `{ r_file_perms append }')
define(`rw_file_perms', `{ r_file_perms w_file_perms }')
define(`rwx_file_perms', `{ rw_file_perms x_file_perms }')
define(`link_file_perms', `{ getattr link unlink rename }')
define(`create_file_perms', `{ create setattr rw_file_perms link_file_perms }')
define(`r_dir_perms', `{ open getattr read search ioctl }')
define(`w_dir_perms', `{ open search write add_name remove_name }')
define(`ra_dir_perms', `{ r_dir_perms add_name write }')
define(`rw_dir_perms', `{ r_dir_perms w_dir_perms }')
define(`create_dir_perms', `{ create reparent rmdir setattr rw_dir_perms link_file_perms }')
define(`r_ipc_perms', `{ getattr read associate unix_read }')
define(`w_ipc_perms', `{ write unix_write }')
define(`rw_ipc_perms', `{ r_ipc_perms w_ipc_perms }')
define(`create_ipc_perms', `{ create setattr destroy rw_ipc_perms }')
#####################################
# Common socket permission sets.
define(`rw_socket_perms', `{ ioctl read getattr write setattr append bind connect getopt setopt shutdown }')
define(`create_socket_perms', `{ create rw_socket_perms }')
define(`rw_stream_socket_perms', `{ rw_socket_perms listen accept }')
define(`create_stream_socket_perms', `{ create rw_stream_socket_perms }')
```
