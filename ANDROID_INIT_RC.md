# 안드로이드 init.rc 문법.(Android Init Language)
=====

안드로이드 시스템 시작시 실행되는 init.rc와 init.xxxx.rc 파일이 있다.
시스템 서비스 (안드로이드 서비스 말고 리눅스 서비스)는 이곳에서 정의된다.


이하 프레임워크/system/core/init/README.md 파일의 내용.


--------------------------------------------------------------

Android Init Language는 5개의 board classes of statements 로 구성된다.
 (Actions, Commands, Services, Options, Imports) 

각 요소는 라인으로 구분되고, 토큰은 공백으로 구분된다.
백스페이스문자를 사용하여 공백문자를 토큰으로 사용이 가능하다.
쌍따옴표는 공백이 포함된 텍스트를 하나의 토큰으로 취급하기 위해 사용되고,
각 라인 가장 마지막에 백스페이스문자가 있으면 다음 줄과 동일한 라인으로 본다.


#으로 시작하는 라인은 코멘트처리된다.


Actions와 Services는 새로운 섹션을 구성한다. Commands와 Options는 가장 최근에 선언된(바로 위에 가까이 있는) Actions와 Services에 속하게 되며, 첫번째 섹션 전에 있는 Commands와 Options는 무시된다.

Actions와 Services는 유니크한 이름을 가지며, 동일한 이름으로 선언되면 에러로 무시된다. (새로 선언된 녀석이 기존의것을 덮어쓸거다)


# 1. Actions
-----
액션은 순차적인 명령어의 집합이다. 액션은 해당 액션이 시작될 트리거를 갖고 있다.
지정된 트리거가 동작되면, 액션은 실행될 큐에 추가된다. (이미 큐에 있더라도 추가된다)

각 액션은 순차적으로 dequeue되며, 명령어도 순차적으로 실행된다.
Init handles other activities (device creation/destruction, property setting, process restarting) "between" the execution of the commands in activities.

액션은 다음과 같은 형식이 된다.

```
on <trigger> [&& <trigger>]*
     <command>
     <command>
     <command>
```

예를 들어, 
```
on boot
	setprop a 1
	setprop b 2

on boot && property:true=true
	setprop c 1
	setporp d 2

on boot 
	setprop e 1
	setprop f 2
```
그런 다음 'boot' trigger 가 발생하고 'true' 속성이 'true'라고 가정하면 실행되는 명령의 순서가 된다. 
```
setprop a 1
setprop b 2
setprop c 1
setprop d 2
setprop e 1
setprop f 2
```


# 2. Service
-----
서비스는 초기 실행되(거나 서비스가 종료되면 재시작되)는 프로그램이다. 서비스는 다음과 같은 형식을 가진다

```
service <name> <pathname> [ <argument> ] *
    <option>
    <option>
    ....
```


# 3. Options
-----
옵션은 서비스의 속성을 설정한다. 서비스가 언제, 어떻게 실행될지를 정한다.

`console [<console>]`
> Service에 콘솔이 필요한 경우 사용. 

`critical`
> 장치에 치명적인(중요한) 서비스. 4분 내에 4번 이상 종료되면 디바이스는 리커버리모드로 재부팅된다.

`disabled`
> 시작시 자동으로 실행되지 않고, 명시적으로 실행하는 서비스.

`setenv <name> <value>`
> 환경설정값을 지정

`socket <name> <type> <perm> [ <user> [ <group> [ <seclabel> ] ] ]`
> /dev/socket/<name> 에 유닉스 도메인 소켓을 생성하고 시작된 프로세스에 해당 fd를 넘겨준다.  <type>은 "dgram", "stream", "seqpacket" 중 한가지 값을 가진다.  user와 group의 기본값은 0

`file <path> <type>`
> 파일 경로를 열고, fd를 시작된 프로세스로 전달. 

`user <username>`
> 서비스 실행시 사용될 사용자 명. 기본값은 root 이다 (nobody일수도 있음)
> Android O 부터 프로세스는 .rc 파일에서 직접 기능을 요청할 수 있다. 아래 "capabilities" 옵션을 참고.

`group <groupname> [ <groupname>\* ]`
> 서비스 실행시 사용될 그룹명. 기본값은 root (nobody일수도 있음)

`seclabel <seclabel>`
> Change to 'seclabel' before exec'ing this service.
> 기본적으로 rootfs에서 실행되는 서비스에 사용된다. (예: ueventd, adbd.)
> 시스템 파티션의 서비스는 file security context 를 기반으로 policy-defined 전환을 사용할 수 있다. 
> 지정하지 않은 경우, 기본값은 init context이다. 

`oneshot`
> 서비스 종료시 자동적으로 재시작하지 않음.

`class <name> [ <name>\* ]`
> 서비스 클래스명을 지정한다. 모든 서비스는 같이 시작/종료될 클래스명을 가지고 있으며, 미지정시 "default" 클래스로 지정된다.

`animation class`
> 'animation' 클래스에는 부팅 애니메이션과 종료 애니메이션에 필요한 모든 서비스가 포함되어야 한다. 

`onrestart`
> 서비스 재시작시 명령을 실행한다.

`writepid <file> [ <file>\* ]`
> 지정된 파일의 자식 pid  를 사용한다. 

# 4. Triggers
-----
트리거는 이벤트나 액션이 발생하는 상황을 지정할 수 있다.

- boot
 : init이 시작될 때 실행된다. (/init.conf 가 로드된 후)

- <name>=<value>
 : 시스템 프로퍼티 <name>의 값이 <value>가 될 때 실행

- device-added-<path>
- device-removed-<path>
 : 디바이스 노드가 추가되거나 삭제되었을때

- service-exited-<name>
 : <name>서비스가 종료되었을때 실행


# 5. Commands
-----
`bootchart [start|stop]`
> Start/stop bootcharting. 
> bootchart/enabled 파일이 존재하는 경우에만 활성화 된다. 

`chmod <octal-mode> <path>`
> 파일 권한 변경.

`chown <owner> <group> <path>`
> 파일 소유자와 그룹 변경

`class_start <serviceclass>`
> 특정 클래스의 서비스를 모두 시작한다.

`class_stop <serviceclass>`
> 현재 실행중인 클래스 서비스를 중지시킨다.

`class_reset <serviceclass>`
> 지정된 클래스의 모든 서비스를 비활성화하지 않고, 현재 실행중인 경우 중지시킨다.

`class_restart <serviceclass>`
> 지정된 클래스의 모든 서비스를 다시 시작시킨다.

`copy <src> <dst>`
> 파일을 복사한다. write 와 유사하지만 binary/large 을 복사하는 경우 유용하다.

`domainname <name>`
> 도메인명 지정.

`enable <servicename>`
> 서비스가 disabled를 지정하지 않은 것처럼, 비활성화 된 서비스를 활성화 된 서비스로 전환한다.
> 서비스가 실행 중이면 지금 시작된다. 일반적으로 부트로더가 필요 할 때, 특정 서비스를 시작해야 함을 나타내는 변수를 설정할 때 사용된다. (예:
```
on property:ro.boot.myfancyhardware=1
	enable my_fancy_service_for_my_fancy_hardware
```
>)

`exec [ <seclabel> [ <user> [ <group>\* ] ] ] -- <command> [ <argument>\* ]`
> 주어진 인수로 명령을 fork하고 실행한다. option security context, user, supplementary group을 제공할 수 있도록 "--" 이후에 명령이 시작된다.
> Command가 완료될 때까지 다른 Command는 실행되지 않는다. 
> _seclabel_은 기본값을 나태나는 - 일 수 있다.
> _argument_ 내에서 특성이 확장되었다.
> 분기 된 프로세스가 종료될 때까지 Init 는 명령 실행을 중지한다. 

`exec_start <service>`
> Start a given service and halt the processing of additional init commands until it returns. 
> 이 명령은 `exec`명령과 유사하게 동작하지만 exec 인수 벡터 대신 기존 서비스 정의를 사용한다.

`export <name> <value>`
> 환경변수 <name>에 <value>값을 지정

`hostname <name>`
> host name 을 세팅.

`ifup <interface>`
> Network interface _interface_를 온라인 상태로 변경한다.

`insmod [-f] <path> [<options>]`
> 지정된 옵션으로 _path_에 모듈을 설치한다.

`load_all_props`
> /system, /vendor 등에서 properties를 load한다.

`load_persist_props`
> /data 가 decrypted될 때, properties를 load한다. 
> 이것은 default init.rc에 포함되어 있다. 

`restart <service>`
> 실행중인 서비스를 중지했다가 다시 시작한다. 서비스가 현재 다시 시작중이면 아무것도 하지 않는다. 그렇지 않으면 서비스가 시작된다. 

`restorecon <path> [ <path>\* ]`
> Restore the file named by _path_ to the security context specified in the file\_contexts configuration.
> Not required for directories created by the init.rc as these are automatically labeled correctly by init.

`start <service>`
> Service가 아직 실행되고 있지 않으면 실행한다.

- exec <path> [ <argument> ]
 : 새로운 프로세스로 <path> 를 실행. 이 작업시 해당 프로그램이 종료될때까지 init은 block되므로 사용상에 주의를 요함.


- ifup <interface>
 : <interface>를 UP상태로 전환한다.

- import <filename>
 : 현재 설정으로 다른 init config 파일을 읽는다

- hostname <name>
 : 호스트명 설정

- chdir <directory>
 : 작업중인 디렉토리 변경


- chroot <directory>
 : 프로세스의 루트 디렉토리를 변경한다

- insmod <path>
 : <path>에 있는 모듈을 설치한다.

- mkdir <path> [mode] [owner] [group]
 : path에 디렉토리를 생성한다. mode, owner, group은 옵션이며 이 옵션이 지정되지 않으면 755 권한에 root/root 소유자로 생성된다.

- mount <type> <device> <dir> [ <mountoption> ]
 : 해당 device를 dir에 마운트한다. <device>는 mtd 블록을 지정하기 위해 mtd@name 형식을 가질 수 있다.
 <mountoption>은 "ro", "rw", "remount", "noatime" ... 등등의 값을 가질 수 있다.

- setkey
 : TBD (미사용, 추가예정)

- setprop <name> <value>
 : 시스템 속성 <name>에 <value>를 지정

- setrlimit <resource> <cur> <max>
 : 리소스에 대해 rlimit를 지정

- start <service>
 : 서비스가 실행중이 아닌경우 서비스를 실행한다.

- stop <service>
 : 서비스가 실행중이면 중지시킨다.

- symlink <target> <path>
 : 심볼릭 링크 생성

- sysclktz <mins_west_of_gmt>
 : 시스템 기준시를 지정한다. (GMT이면 0)

- trigger <event>
 : 특정 이벤트를 발생한다. 액션에서 다른 액션을 실행하기 위해 사용된다.

- write <path> <string> [ <string> ]
 : <path>에 파일을 만들고, 하나 이상의 문자열을 쓴다. (write 사용)


# 6. Properties
-----
 : init은 몇개의 시스템 속성값을 셋팅한다.

`init.action`
> 현재 실행중인 액션의 이름

`init.command`
> 현재 실행중인 커맨드

`init.svc.<name>`
> <name> 서비스의 현재 상태. "stopped", "running", "restarting"


기본적으로, init을 통해 실행되는 프로그램은 stdout과 stderr가 /dev/null로 전달된다. (표시되거나 저장되지 않는다)
디버깅을 위해서 Android program logwrapper 를 사용하면 된다. 이 로그는 logcat에서 볼 수 있다.

예)
service akmd /system/bin/logwrapper /sbin/akmd


# Boot timing
-----
 : Init는 시스템 속성에 일부 부팅 타이밍 정보를 기록한다. 

`ro.boottime.init`
> 부팅 후 init의 첫 번째 단계가 시작된 ns (via the CLOCK\_BOOTTIME clock)의 시간입니다.

`bo.boottime.init.selinux`
> Time after boot in ns (via the CLOCK\_BOOTTIME clock) at which the first stage of init started. 

`ro.boottime.init.cold_boot_wait`
> How long init waited for ueventd's coldboot phase to end.

`ro.boottime.<service-name>`
> Time after boot in ns (via the CLOCK\_BOOTTIME clock) that the service was first started.


# bootcharting
-----
 : init 에는 "bootcharting"를 수행하기 위한 코드가 포함되어 있다. <http://www.bootchart.org/>에서 제공하는 도구를 사용하여 처리 할 수 있는 로그를 생성한다. 
 -bootchart _timeout_ 옵션을 사용하여 _timeout_  초를 확인 할 수 있다.

 On a device:
```
adb shell 'touch /data/bootchart/enabled'
```
 로그 파일은 /data/bootchart/에 기록된다. bootchart 명령 행 유틸리티와 함께 사용할 수있는 bootchart.tgz 파일을 작성하고 검색하기위한 스크립트가 제공된다.

```
sudo apt-get install pybootchartgui 
# grab-bootchart.sh uses $ANDROID_SERAIL.
$ANDROID_BUILD_TOP/system/core/init/grab-bootchart.sh
```

# systrace
-----

 Systrace (<http://developer.android.com/tools/help/systrace.html>) can be used for obtaining performance analysis reports during boot time on userdebug or eng builds.

 Here is an example of trace events of "wm" and "am" categories:
```
$ANDROID_BUILD_TOP/external/chromium-trace/systrace.py \ 
	wm am --boot
```

 This command will cause the device to reboot. After the device is rebooted and the boot sequence has finished, the trace report is obtained from the device and written as trace.html on the host by hitting Ctrl+C.



