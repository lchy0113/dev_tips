# 안드로이드 init.rc 문법.(Android Init Language)
=====

안드로이드 시스템 시작시 실행되는 init.rc와 init.xxxx.rc 파일이 있다.

시스템 서비스 (안드로이드 서비스 말고 리눅스 서비스)는 이곳에서 정의된다.



이하 프레임워크/system/core/init/readme.txt 파일의 내용.



--------------------------------------------------------------



크게 Actions, Commands, Services, Options 네 부분으로 구분된다.



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



on <trigger>

     <command>

     <command>

     <command>







# 2. Service
-----
서비스는 초기 실행되(거나 서비스가 종료되면 재시작되)는 프로그램이다. 서비스는 다음과 같은 형식을 가진다



service <name> <pathname> [ <argument> ]

    <option>

    <option>

    ....







# 3. Options
-----
옵션은 서비스의 속성을 설정한다. 서비스가 언제, 어떻게 실행될지를 정한다.



critical

장치에 치명적인(중요한) 서비스. 4분 내에 4번 이상 종료되면 디바이스는 리커버리모드로 재부팅된다.



disabled

시작시 자동으로 실행되지 않고, 명시적으로 실행하는 서비스.



setenv <name> <value>

환경설정값을 지정



socket <name> <type> <perm> [ <user> [ <group> ] ]

/dev/socket/<name> 에 유닉스 도메인 소켓을 생성하고 시작된 프로세스에 해당 fd를 넘겨준다.

<type>은 "dgram", "stream", "seqpacket" 중 한가지 값을 가진다.

user와 group의 기본값은 0



user <username>

서비스 실행시 사용될 사용자 명. 기본값은 root 이다 (nobody일수도 있음)



group <groupname> [ <groupname> ]

서비스 실행시 사용될 그룹명. 기본값은 root (nobody일수도 있음)



oneshot

서비스 종료시 자동적으로 재시작하지 않음



class <name>

서비스 클래스명을 지정한다. 모든 서비스는 같이 시작/종료될 클래스명을 가지고 있으며, 미지정시 "default" 클래스로 지정된다.



onrestart

서비스 재시작시 명령을 실행한다.







# 4. Triggers
-----
트리거는 이벤트나 액션이 발생하는 상황을 지정할 수 있다.



boot

init이 시작될 때 실행된다. (/init.conf 가 로드된 후)



<name>=<value>

시스템 프로퍼티 <name>의 값이 <value>가 될 때 실행



device-added-<path>

device-removed-<path>

디바이스 노드가 추가되거나 삭제되었을때



service-exited-<name>

<name>서비스가 종료되었을때 실행







# 5. Commands
-----


exec <path> [ <argument> ]

새로운 프로세스로 <path> 를 실행. 이 작업시 해당 프로그램이 종료될때까지 init은 block되므로 사용상에 주의를 요함.



export <name> <value>

환경변수 <name>에 <value>값을 지정



ifup <interface>

<interface>를 UP상태로 전환한다.



import <filename>

현재 설정으로 다른 init config 파일을 읽는다



hostname <name>

호스트명 설정



chdir <directory>

작업중인 디렉토리 변경



chmod <octal-mode> <path>

파일 권한 변경



chown <owner> <group> <path>

파일 소유자와 그룹 변경



chroot <directory>

프로세스의 루트 디렉토리를 변경한다



class_start <serviceclass>

특정 클래스의 서비스를 모두 시작한다.



class_stop <serviceclass>

현재 실행중인 클래스 서비스를 중지시킨다.



domainname <name>

도메인명 지정



insmod <path>

<path>에 있는 모듈을 설치한다.



mkdir <path> [mode] [owner] [group]

path에 디렉토리를 생성한다. mode, owner, group은 옵션이며 이 옵션이 지정되지 않으면 755 권한에 root/root 소유자로 생성된다.



mount <type> <device> <dir> [ <mountoption> ]

해당 device를 dir에 마운트한다. <device>는 mtd 블록을 지정하기 위해 mtd@name 형식을 가질 수 있다.

<mountoption>은 "ro", "rw", "remount", "noatime" ... 등등의 값을 가질 수 있다.



setkey

TBD (미사용, 추가예정)



setprop <name> <value>

시스템 속성 <name>에 <value>를 지정



setrlimit <resource> <cur> <max>

리소스에 대해 rlimit를 지정



start <service>

서비스가 실행중이 아닌경우 서비스를 실행한다.



stop <service>

서비스가 실행중이면 중지시킨다.



symlink <target> <path>

심볼릭 링크 생성



sysclktz <mins_west_of_gmt>

시스템 기준시를 지정한다. (GMT이면 0)



trigger <event>

특정 이벤트를 발생한다. 액션에서 다른 액션을 실행하기 위해 사용된다.



write <path> <string> [ <string> ]

<path>에 파일을 만들고, 하나 이상의 문자열을 쓴다. (write 사용)







# 6. Properties
-----
init은 몇개의 시스템 속성값을 셋팅한다.



init.action

현재 실행중인 액션의 이름



init.command

현재 실행중인 커맨드



init.svc.<name>

<name> 서비스의 현재 상태. "stopped", "running", "restarting"









기본적으로, init을 통해 실행되는 프로그램은 stdout과 stderr가 /dev/null로 전달된다. (표시되거나 저장되지 않는다)

디버깅을 위해서 Android program logwrapper 를 사용하면 된다. 이 로그는 logcat에서 볼 수 있다.



예)

service akmd /system/bin/logwrapper /sbin/akmd


