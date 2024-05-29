# DNS-SD
 DNS-SD(DNS Service Discovery) 기술은 local network에서 서비스를 찾기 위한 기술.  
 주로 IoT 및 다양한 네트워크 기기에서 사용.  
 이 기술은 DNS(Domain Name System)을 활용하여 서비스를 검색하고 발견하는 방법을 제공.  

<hr>
<br/>

[Avahi](#avahi)

<hr>
<br/>
<br/>
<br/>

## Avahi 

 - background :
  Linux 기반으로 네트워크를 구성할 때, 상대 장치의 HOST IP를 알아야 한다.  
  네트워크를 구성할 때 관련 장치 정보를 /etc/hosts 에 저장하여 사용함.  

  avahi라는툴을 사용하면 상대의 정보를 사전에 미리 시스템에 세팅해 두지 않아도  
  자동으로 호스트와 IP를 리졸브(resolve) 할 수 있다.  
  뿐만 아니라 같은 도메인에 있는 다른 장치 정보까지 스캔 할 수있다.  

### Avahi

 Avahi 는 흔히 zeroconf라고 불리는 Zero-Configuration Networking 기술을 기반으로 개발된  
 네임 서비스 디스커버리 툴.  
 mDNS(멀티캐스트 DNS) / DNS-SD 기술을 기반으로 개발된 리눅스 버전 zeroconf 도구이며,   
 애플의 Bonjour 서비스 또한 zeroconf 기반 디스커버리 툴.  

 리눅스에서는 대표적으로 NFS, SMB, Vftpd 같은 툴들이, avahi 를 활용하여 동작하는 것으로 알려짐.  

### Avahi 활용

 1. Avahi 설치하기

```bash
$ sudo apt update
$ sudo apt install avahi-utils
```

 2. Host 이름 또는 IP 정보로 상대 장치 정보 얻기. 
 > 상대 장치도 zeroconf를 지원하는 조건.  즉, 상대장치도 avahi daemon이 실행 중이어야함.  

 *avahi-resolve* 명령을 사용하여 HostPC 에서 richgold.pizza 탐색을 시도함. 
 결과, IP주소를 resolve하는 것을 확인. 

  - -4, -6 : ipv4, ipv6
  - -n or --name : domain 이름
  - -a or --address : ip 주소

```bash
$ avahi-resolve -4 -n richgold.pizza
richogld.pizza 192.168.0.2

$ avahi-resolve -4 -a 192.168.0.2
192.168.0.2 richgold.pizza
```



