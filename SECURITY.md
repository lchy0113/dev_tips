
# security for linux server


해커 및 크래커의 손으로부터 프로덕션 시스템을 보호하는 것은 시스템 관리자에게 어려운 작업입니다. 이것은 Linux 박스 보안 방법 또는 Linux 박스 강화와 관련된 첫 번째 기사입니다. 이 게시물에서는 Linux 시스템을 보호하기 위한 25가지 유용한 팁과 요령을 설명합니다. 아래의 팁과 요령이 시스템 보안을 확장하는 데 도움이 되기를 바랍니다.

1. 물리적 시스템 보안
BIOS<에서 CD/DVD, 외부 장치, 플로피 드라이브에서 부팅을 비활성화하도록 BIOS를 구성합니다. /강한>. 그런 다음 BIOS 암호를 활성화하고 암호로 GRUB을 보호하여 시스템의 물리적 액세스를 제한합니다.

Linux 서버 보호를 위한 GRUB 암호 설정
2. 디스크 파티션
재해가 발생할 경우를 대비하여 더 높은 데이터 보안을 확보하려면 서로 다른 파티션을 갖는 것이 중요합니다. 서로 다른 파티션을 생성하여 데이터를 분리하고 그룹화할 수 있습니다. 예상치 못한 사고가 발생하면 해당 파티션의 데이터만 손상되고 다른 파티션의 데이터는 살아남습니다. 다음과 같은 별도의 파티션이 있어야 하고 타사 응용 프로그램이 /opt 아래의 별도 파일 시스템에 설치되어야 합니다.

/
/boot
/usr
/var
/home
/tmp
/opt
3. 취약성을 최소화하기 위해 패키지 최소화
정말 모든 종류의 서비스를 설치하시겠습니까?. 패키지의 취약점을 피하기 위해 쓸모없는 패키지를 설치하지 않는 것이 좋습니다. 이렇게 하면 한 서비스의 손상이 다른 서비스의 손상으로 이어질 수 있는 위험을 최소화할 수 있습니다. 취약점을 최소화하기 위해 서버에서 원치 않는 서비스를 찾아 제거하거나 비활성화합니다. runlevel 3에서 실행 중인 서비스를 찾으려면 'chkconfig' 명령을 사용하십시오.

# /sbin/chkconfig --list |grep '3:on'
원치 않는 서비스가 실행 중임을 알게 되면 다음 명령을 사용하여 비활성화합니다.

# chkconfig serviceName off
yum 또는 apt-get 도구와 같은 RPM 패키지 관리자를 사용하여 시스템에 설치된 모든 패키지를 나열하고 다음을 사용하여 제거합니다. 다음 명령.

# yum -y remove package-name
# sudo apt-get remove package-name
5개의 chkconfig 명령 예
RPM 명령의 20가지 실용적인 예
Linux 패키지 관리를 위한 20개의 Linux YUM 명령
패키지 관리를 위한 25개의 APT-GET 및 APT-CACHE 명령
4. 수신 네트워크 포트 확인
'netstat' 네트워킹 명령을 사용하면 열려 있는 모든 포트와 관련 프로그램을 볼 수 있습니다. 위에서 말했듯이 시스템에서 원치 않는 모든 네트워크 서비스를 비활성화하려면 'chkconfig' 명령을 사용하십시오.

# netstat -tulpn
Linux에서 네트워크 관리를 위한 20개의 Netstat 명령
5. SSH(Secure Shell) 사용
Telnet 및 rlogin 프로토콜은 보안 위반인 암호화된 형식이 아닌 일반 텍스트를 사용합니다. SSH는 서버와 통신하는 동안 암호화 기술을 사용하는 보안 프로토콜입니다.

필요한 경우가 아니면 루트로 직접 로그인하지 마십시오. sudo를 사용하여 명령을 실행합니다. sudo는 /etc/sudoers 파일에 지정되어 있으며 VI 편집기에서 열리는 visudo 유틸리티로 편집할 수도 있습니다.

또한 기본 SSH 22 포트 번호를 다른 상위 수준 포트 번호로 변경하는 것이 좋습니다. 기본 SSH 구성 파일을 열고 다음 매개변수를 만들어 사용자의 액세스를 제한합니다.

# vi /etc/ssh/sshd_config
루트 로그인 비활성화
PermitRootLogin no
특정 사용자만 허용
AllowUsers username
SSH 프로토콜 2 버전 사용
Protocol 2
SSH 서버 보안 및 보호를 위한 5가지 모범 사례
6. 시스템을 최신 상태로 유지
사용 가능한 최신 릴리스 패치, 보안 수정 및 커널로 시스템을 항상 최신 상태로 유지하십시오.

# yum updates
# yum check-update
7. 락다운 크론잡
Cron에는 작업 실행을 원하는 사람과 원하지 않는 사람을 지정할 수 있는 자체 내장 기능이 있습니다. 이는 /etc/cron.allow 및 /etc/cron.deny라는 파일을 사용하여 제어됩니다. cron을 사용하여 사용자를 잠그려면 cron.deny에 사용자 이름을 추가하고 사용자가 cron.allow 파일에 cron 추가를 실행할 수 있도록 허용합니다. 모든 사용자가 cron을 사용하지 못하도록 하려면 cron.deny 파일에 'ALL' 줄을 추가합니다.

# echo ALL >>/etc/cron.deny
Linux의 11가지 Cron 예약 예
8. USB 스틱을 비활성화하여 감지
데이터 도난을 방지하고 보호하기 위해 시스템에서 USB 스틱을 사용하는 사용자를 제한하려는 경우가 많습니다. '/etc/modprobe.d/no-usb' 파일을 만들고 아래 줄을 추가하면 USB 저장소를 감지하지 못합니다.

install usb-storage /bin/true
9. SELinux 켜기
보안 강화 Linux(SELinux)는 커널에서 제공되는 필수 액세스 제어 보안 메커니즘입니다. SELinux를 비활성화하면 시스템에서 보안 메커니즘이 제거됩니다. 제거하기 전에 신중하게 두 번 생각하십시오. 시스템이 인터넷에 연결되어 있고 대중이 액세스하는 경우 좀 더 생각하십시오.

SELinux는 세 가지 기본 작동 모드를 제공합니다.

강제: 시스템에서 SELinux 보안 정책을 활성화하고 적용하는 기본 모드입니다.
Permissive: 이 모드에서 SELinux는 시스템에 보안 정책을 적용하지 않고 경고하고 작업만 기록합니다. 이 모드는 SELinux 관련 문제를 해결하는 데 매우 유용합니다.
비활성화: SELinux가 꺼져 있습니다.
'system-config-selinux', 'getenforce' 또는 ''를 사용하여 명령줄에서 SELinux 모드의 현재 상태를 볼 수 있습니다. sestatus' 명령.

# sestatus
비활성화된 경우 다음 명령을 사용하여 SELinux를 활성화합니다.

# setenforce enforcing
또한 활성화 또는 비활성화할 수 있는 '/etc/selinux/config' 파일에서 관리할 수 있습니다.

10. KDE/GNOME 데스크탑 제거
전용 LAMP 서버에서 KDE 또는 GNOME과 같은 X Window 데스크톱을 실행할 필요가 없습니다. 이를 제거하거나 비활성화하여 서버 보안 및 성능을 높일 수 있습니다. 간단히 비활성화하려면 '/etc/inittab' 파일을 열고 실행 수준을 3으로 설정합니다. 시스템에서 완전히 제거하려면 아래 명령을 사용하십시오.

# yum groupremove "X Window System"
11. IPv6 끄기
IPv6 프로토콜을 사용하지 않는 경우 대부분의 애플리케이션 또는 정책이 IPv6 프로토콜을 요구하지 않으며 현재 서버에서 요구하지 않기 때문에 비활성화해야 합니다. . 네트워크 구성 파일로 이동하고 다음 줄을 추가하여 비활성화합니다.

# vi /etc/sysconfig/network
NETWORKING_IPV6=no
IPV6INIT=no
12. 사용자가 이전 암호를 사용하도록 제한
이는 사용자가 동일한 이전 암호를 사용하지 못하게 하려는 경우에 매우 유용합니다. 이전 암호 파일은 /etc/security/opasswd에 있습니다. 이것은 PAM 모듈을 사용하여 달성할 수 있습니다.

RHEL/CentOS/Fedora에서 '/etc/pam.d/system-auth' 파일을 엽니다.

# vi /etc/pam.d/system-auth
Ubuntu/Debian/Linux Mint에서 '/etc/pam.d/common-password' 파일을 엽니다.

# vi /etc/pam.d/common-password
'auth' 섹션에 다음 줄을 추가합니다.

auth        sufficient    pam_unix.so likeauth nullok
사용자가 자신의 마지막 5 비밀번호를 재사용하지 못하도록 하려면 '비밀번호' 섹션에 다음 줄을 추가합니다.

password   sufficient    pam_unix.so nullok use_authtok md5 shadow remember=5
마지막 5개의 암호만 서버에서 기억합니다. 마지막 5개의 이전 암호를 사용하려고 하면 다음과 같은 오류가 발생합니다.

Password has been already used. Choose another.
13. 사용자 비밀번호 만료 확인 방법
Linux에서 사용자의 비밀번호는 '/etc/shadow' 파일에 암호화된 형식으로 저장됩니다. 사용자의 비밀번호 만료를 확인하려면 'chage' 명령을 사용해야 합니다. 마지막 비밀번호 변경 날짜와 함께 비밀번호 만료 내역 정보를 표시합니다. 이러한 세부 정보는 시스템에서 사용자가 암호를 변경해야 하는 시기를 결정하는 데 사용됩니다.

만료 날짜 및 시간과 같은 기존 사용자의 노화 정보를 보려면 다음 명령을 사용하십시오.

#chage -l username
사용자의 암호 사용 기간을 변경하려면 다음 명령을 사용하십시오.

#chage -M 60 username
#chage -M 60 -m 7 -W 7 userName
매개변수
-M 최대 일수 설정
-m 최소 일수 설정
-W 경고 일수 설정
14. 수동으로 계정 잠금 및 잠금 해제
잠금 및 잠금 해제 기능은 매우 유용합니다. 시스템에서 계정을 제거하는 대신 일주일 또는 한 달 동안 잠글 수 있습니다. 특정 사용자를 잠그려면 다음 명령을 사용할 수 있습니다.

# passwd -l accountName
참고 : 잠긴 사용자는 여전히 루트 사용자만 사용할 수 있습니다. 잠금은 암호화된 암호를 (!) 문자열로 대체하여 수행됩니다. 누군가 이 계정을 사용하여 시스템에 액세스하려고 하면 아래와 유사한 오류가 발생합니다.

# su - accountName
This account is currently not available.
잠긴 계정에 대한 액세스를 잠금 해제하거나 활성화하려면 as 명령을 사용합니다. 이렇게 하면 암호화된 비밀번호로 (!) 문자열이 제거됩니다.

# passwd -u accountName
15. 더 강력한 암호 적용
많은 사용자가 약하거나 취약한 비밀번호를 사용하며 비밀번호는 사전 기반 또는 무차별 대입 공격으로 해킹될 수 있습니다. 'pam_cracklib' 모듈은 PAM(Pluggable Authentication Modules) 모듈 스택에서 사용할 수 있으며 사용자가 강력한 비밀번호를 설정하도록 합니다. 편집기로 다음 파일을 엽니다.

또한 읽기:

# vi /etc/pam.d/system-auth
신용 매개변수를 각각 소문자로 사용하여 줄을 추가합니다. , 대문자, 숫자 및 기타)

/lib/security/$ISA/pam_cracklib.so retry=3 minlen=8 lcredit=-1 ucredit=-2 dcredit=-2 ocredit=-1
16. Iptables 활성화(방화벽)
서버에 대한 무단 액세스를 보호하려면 Linux 방화벽을 활성화하는 것이 좋습니다. iptables의 규칙을 적용하여 수신, 발신 및 전달 패킷을 필터링합니다. 특정 udp/tcp 포트 번호에서 허용 및 거부할 소스 및 대상 주소를 지정할 수 있습니다.

기본 IPTables 가이드 및 팁
17. Inittab에서 Ctrl+Alt+Delete 비활성화
대부분의 Linux 배포판에서 'CTRL-ALT-DELETE'를 누르면 시스템이 재부팅됩니다. 따라서 누군가가 실수로 이 옵션을 사용하는 경우 적어도 프로덕션 서버에서 이 옵션을 활성화하는 것은 좋지 않습니다.

이것은 '/etc/inittab' 파일에 정의되어 있으며, 해당 파일을 자세히 보면 아래와 유사한 행을 볼 수 있습니다. 기본적으로 줄은 주석 처리되지 않습니다. 주석 처리해야 합니다. 이 특정 키 시퀀스 신호는 시스템을 종료합니다.

# Trap CTRL-ALT-DELETE
#ca::ctrlaltdel:/sbin/shutdown -t3 -r now
18. 빈 암호에 대한 계정 확인
빈 암호가 있는 계정은 웹상의 모든 사람에 대한 무단 액세스를 위해 열려 있음을 의미하며 Linux 서버 내 보안의 일부입니다. 따라서 모든 계정에 강력한 암호가 설정되어 있고 아무도 액세스 권한이 없는지 확인해야 합니다. 빈 암호 계정은 보안 위험이 있으며 쉽게 해킹할 수 있습니다. 비밀번호가 비어있는 계정이 있는지 확인하려면 다음 명령을 사용하십시오.

# cat /etc/shadow | awk -F: '($2==""){print $1}'
19. 로그인 전 SSH 배너 표시
SSH 인증 전에 일부 보안 경고가 포함된 법적 배너 또는 보안 배너를 사용하는 것이 항상 더 좋습니다. 이러한 배너를 설정하려면 다음 기사를 읽으십시오.

사용자에게 SSH 경고 메시지 표시
20. 사용자 활동 모니터링
많은 사용자를 상대하는 경우 각 사용자 활동 및 사용자가 소비하는 프로세스에 대한 정보를 수집하고 나중에 또는 어떤 종류의 성능, 보안 문제가 있는 경우 이를 분석하는 것이 중요합니다. 그러나 사용자 활동 정보를 모니터링하고 수집하는 방법.

시스템에서 사용자 활동 및 프로세스를 모니터링하는 데 사용되는 'psacct' 및 'acct'라는 두 가지 유용한 도구가 있습니다. 이러한 도구는 시스템 백그라운드에서 실행되며 Apache, MySQL, SSH, FTP 등. 설치, 구성 및 사용에 대한 자세한 내용은 아래 URL을 방문하십시오.

psacct 또는 acct 명령으로 사용자 활동 모니터링
21. 로그를 정기적으로 검토
로그를 전용 로그 서버로 이동하면 침입자가 로컬 로그를 쉽게 수정하는 것을 방지할 수 있습니다. 다음은 공통 Linux 기본 로그 파일 이름과 사용법입니다.

/var/log/message – 전체 시스템 로그 또는 현재 활동 로그를 사용할 수 있는 위치입니다.
/var/log/auth.log – 인증 로그.
/var/log/kern.log – 커널 로그.
/var/log/cron.log – Crond 로그(cron 작업).
/var/log/maillog – 메일 서버 로그.
/var/log/boot.log – 시스템 부팅 로그.
/var/log/mysqld.log – MySQL 데이터베이스 서버 로그 파일.
/var/log/secure – 인증 로그.
/var/log/utmp 또는 /var/log/wtmp : 로그인 기록 파일.
/var/log/yum.log: Yum 로그 파일.
22. 중요 파일 백업
프로덕션 시스템에서는 재해 복구를 위해 중요한 파일을 백업하고 안전한 저장소, 원격 사이트 또는 오프 사이트에 보관해야 합니다.

23. NIC 본딩
NIC 결합에는 두 가지 유형의 모드가 있으며 결합 인터페이스에서 언급해야 합니다.

mode=0 – 라운드 로빈
mode=1 – 활성 및 백업
NIC 결합은 단일 실패 지점을 방지하는 데 도움이 됩니다. NIC 본딩에서는 두 개 이상의 네트워크 이더넷 카드를 함께 본딩하고 다른 사람과 통신할 IP 주소를 할당할 수 있는 하나의 단일 가상 인터페이스를 만듭니다. 서버. 어떤 이유로든 하나의 NIC 카드가 다운되거나 사용할 수 없는 경우 네트워크를 사용할 수 있습니다.

24. /boot를 읽기 전용으로 유지
Linux 커널 및 관련 파일은 기본적으로 읽기-쓰기인 /boot 디렉토리에 있습니다. 읽기 전용으로 변경하면 중요한 부팅 파일을 무단으로 수정할 위험이 줄어듭니다. 이렇게 하려면 /etc/fstab 파일을 엽니다.

# vi /etc/fstab
하단에 다음 줄을 추가하고 저장하고 닫습니다.

LABEL=/boot     /boot     ext2     defaults,ro     1 2
나중에 커널을 업그레이드해야 하는 경우 변경 사항을 읽기-쓰기로 재설정해야 합니다.

25. ICMP 또는 브로드캐스트 요청 무시
ping 또는 broadcast 요청을 무시하려면 /etc/sysctl.conf 파일에 다음 행을 추가하십시오.

Ignore ICMP request:
net.ipv4.icmp_echo_ignore_all = 1

Ignore Broadcast request:
net.ipv4.icmp_echo_ignore_broadcasts = 1
다음 명령을 실행하여 새 설정 또는 변경 사항을 로드합니다.

#sysctl -p
