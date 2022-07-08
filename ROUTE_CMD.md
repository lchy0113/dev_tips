# ROUTE COMMAND 

## ip 별로 route gateway 분기하기.
```bash
route del default
route add default gw 172.20.10.1
route add 130.80.10.185 gw 192.168.0.1
route add 130.68.49.35  gw 192.168.0.1

route 
Kernel IP routing table
Destination		Gateway 		Genmask 		Flags 	Metric 	Ref 	Use 	Iface
default			192.168.43.1	0.0.0.0			UG		0		0		0		wlan0
130.80.10.185	192.168.nate.co	255.255.255.255	UGH		0		0		0		eth0
link-local		* 				255.255.0.0		U		1000	0		0		wlan0
192.168.0.0		* 				255.255.255.0	U		0		0		0		eth0
192.168.43.0	* 				255.255.255.0	U		0		0		0		wlan0
```


U : 활성화 중.
G : 게이트웨이 설정중
H : 호스트 대상

130.68.41.0 네트워크 영역에 대해서 패킷이 나가는 GW를 192.168.0.1로 지정한다는 의미. 
```bash
route add -net 130.68.41.0 netmask 255.255.255.0 gw 192.168.0.1
```

```bash
route -n
Kernel IP routing table
Destination 	Gateway 		Genmask 		Flags 	Metric 	Ref 	Use 	Iface
0.0.0.0 		172.20.10.1 	0.0.0.0 		UG	 	0 		0 		0 		wlan0
130.68.41.0 	192.168.0.1 	255.255.255.0	UG 		0		0 		0 		eth0
130.80.10.185 	192.168.0.1 	255.255.255.255 UGH 	0 		0 		0	 	eth0
169.254.0.0 	0.0.0.0 		255.255.0.0 	U 		1000 	0 		0 		eth0
172.20.10.0 	0.0.0.0		 	255.255.255.240 U 		2		0 		0 		wlan0
192.168.0.0 	0.0.0.0 		255.255.255.0 	U 		1 		0 		0 		eth0

```



routing table : cat /proc/net/route
```bash
nhn1311:/ # cat /proc/net/route
Iface   Destination     Gateway         Flags   RefCnt  Use     Metric  Mask            MTU     Window  IRTT
wlan1   000010AC        010010AC        0003    0       0       0       00FFFFFF        0       0       0
wlan0   0000A8C0        00000000        0001    0       0       0       00FFFFFF        0       0       0
nhn1311:/ #
```


shows routes of all tables
```bash
ip route show table 0
```

show route table which interface
```bash
ip route show table (interface)
```

route table을 network interface 가  활성화/비활성화 시, overwritten 됩니다.
또한 아래 명령어를 통해 변경 가능합니다.
```bash
/system/bin/ip route delete table wlan0 default via 192.168.7.1 dev wlan0  proto static
/system/bin/ip route add table wlan0 192.168.7.0/24 dev wlan0 proto kernel scope link src 192.168.7.10 metric 327
```





## route 와 ip route 의 차이점?
route는 매우 간단한 도구로 정적 경로를 만드는 데 적합합니다. 호환성을 위해 많은 배포판에 여전히 존재합니다. ip route는 훨씬 강력하고 기능이 훨씬 많으며보다 전문화 된 규칙을 만들 수 있습니다.

ip route 정적 경로를 만드는 데 필요하지는 않지만 훨씬 유용한 도구이기 때문에 학습에 소요되는 노력과 그 구문에 시간이 많이 걸립니다.


## Android devices don't know route to a host located in the same network
issue : main route table 을 파일시스템에 추가 하지 않는 문제 발생. 
android device address :
	wlan0 : 192.168.0.20 (wifi; station mode)
	wlan1 : 172.16.0.1	 (wifi; ap mode) 


* ping test 
	wlan0 : 전송 성공.
 	wlan1 : *타겟 장치에서 ping 프로그램을 통해, network에 연결된 노드에 데이터 전송 실패 됨.*

route table
```bash
nhn1311:/ # ip route
172.16.0.0/24 dev wlan1  proto kernel  scope link  src 172.16.0.1
192.168.0.0/24 dev wlan0  proto kernel  scope link  src 192.168.0.20
nhn1311:/ #


nhn1311:/ # ip route show table 0
default dev dummy0  table dummy0  proto static  scope link
default via 192.168.0.1 dev wlan0  table wlan0  proto static
192.168.0.0/24 dev wlan0  table wlan0  proto static  scope link
172.16.0.0/24 dev wlan1  proto kernel  scope link  src 172.16.0.1
192.168.0.0/24 dev wlan0  proto kernel  scope link  src 192.168.0.20
broadcast 127.0.0.0 dev lo  table local  proto kernel  scope link  src 127.0.0.1
local 127.0.0.0/8 dev lo  table local  proto kernel  scope host  src 127.0.0.1
local 127.0.0.1 dev lo  table local  proto kernel  scope host  src 127.0.0.1
broadcast 127.255.255.255 dev lo  table local  proto kernel  scope link  src 127.0.0.1
broadcast 172.16.0.0 dev wlan1  table local  proto kernel  scope link  src 172.16.0.1
local 172.16.0.1 dev wlan1  table local  proto kernel  scope host  src 172.16.0.1
broadcast 172.16.0.255 dev wlan1  table local  proto kernel  scope link  src 172.16.0.1
broadcast 192.168.0.0 dev wlan0  table local  proto kernel  scope link  src 192.168.0.20
local 192.168.0.20 dev wlan0  table local  proto kernel  scope host  src 192.168.0.20
broadcast 192.168.0.255 dev wlan0  table local  proto kernel  scope link  src 192.168.0.20
unreachable default dev lo  proto kernel  metric 4294967295  error -101
unreachable default dev lo  proto kernel  metric 4294967295  error -101
unreachable default dev lo  proto kernel  metric 4294967295  error -101
fe80::/64 dev dummy0  table dummy0  proto kernel  metric 256
default dev dummy0  table dummy0  proto static  metric 1024
unreachable default dev lo  proto kernel  metric 4294967295  error -101
fe80::/64 dev wlan0  table wlan0  proto kernel  metric 256
fe80::/64 dev wlan0  table wlan0  proto static  metric 1024
unreachable default dev lo  proto kernel  metric 4294967295  error -101
fe80::/64 dev wlan1  table 1007  proto kernel  metric 256
unreachable default dev lo  proto kernel  metric 4294967295  error -101
unreachable default dev lo  proto kernel  metric 4294967295  error -101
local ::1 dev lo  table local  proto none  metric 0
local fe80::432:f4ff:fe06:b994 dev lo  table local  proto none  metric 0
local fe80::632:f4ff:fe06:bd94 dev lo  table local  proto none  metric 0
local fe80::c61:51ff:fe74:c174 dev lo  table local  proto none  metric 0
ff00::/8 dev dummy0  table local  metric 256
ff00::/8 dev wlan0  table local  metric 256
ff00::/8 dev wlan1  table local  metric 256
unreachable default dev lo  proto kernel  metric 4294967295  error -101
nhn1311:/ #

```

- 타겟 장치에서 패킷 라우팅 경로를 추적. 
wlan0 
```bash
nhn1311:/ # tracepath -n 192.168.0.3
1?: [LOCALHOST]                                         pmtu 1500
1:  192.168.0.3                                           9.233ms reached
1:  192.168.0.3                                           6.532ms reached
Resume: pmtu 1500 hops 1 back 64
nhn1311:/ #
```

wlan1
```bash
255|nhn1311:/ # tracepath -n 172.16.0.10
1?: [LOCALHOST]                                         pmtu 1500
1:  192.168.0.1                                           4.357ms
1:  192.168.0.1                                           5.396ms
2:  192.168.27.1                                          6.994ms asymm  3
3:  192.168.25.2                                          5.001ms
4:  175.124.155.1                                         9.864ms
5:  100.72.247.149                                        6.084ms
6:  10.44.132.53                                          7.374ms
7:  10.44.248.52                                          3.817ms
8:  10.44.248.65                                          8.516ms
9:  100.73.0.134                                          7.260ms
10:  210.220.81.2                                          4.696ms

11:  no reply
12:  no reply
13:  no reply
(...)
29:  no reply
30:  no reply
Too many hops: pmtu 1500
Resume: pmtu 1500
```

- wlan1 로 routing되어 전송 되지 않는 현상.
: ping *-I interface_number* option을 추가하여 ping 전송됨을 확인 함.

- wlan1 네트워크 외부에서 타겟 장치로 ping 전송이 되지 않는 현상. 
: main route table에 아래 명령을 추가하여 해결함. 
 ip rule add from all lookup main pref 1

```bash

nhn1311:/ # ip rule
0:      from all lookup local
10000:  from all fwmark 0xc0000/0xd0000 lookup legacy_system
10500:  from all oif dummy0 lookup dummy0
10500:  from all oif wlan0 lookup wlan0
13000:  from all fwmark 0x10063/0x1ffff lookup local_network
13000:  from all fwmark 0x10064/0x1ffff lookup wlan0
14000:  from all oif dummy0 lookup dummy0
14000:  from all oif wlan0 lookup wlan0
15000:  from all fwmark 0x0/0x10000 lookup legacy_system
16000:  from all fwmark 0x0/0x10000 lookup legacy_network
17000:  from all fwmark 0x0/0x10000 lookup local_network
19000:  from all fwmark 0x64/0x1ffff lookup wlan0
22000:  from all fwmark 0x0/0xffff lookup wlan0
23000:  from all fwmark 0x0/0xffff lookup main
32000:  from all unreachable
nhn1311:/ #

nhn1311:/ # ip rule add from all lookup main pref 1


nhn1311:/ # ip rule
0:      from all lookup local
1:      from all lookup main
10000:  from all fwmark 0xc0000/0xd0000 lookup legacy_system
10500:  from all oif dummy0 lookup dummy0
10500:  from all oif wlan0 lookup wlan0
13000:  from all fwmark 0x10063/0x1ffff lookup local_network
13000:  from all fwmark 0x10064/0x1ffff lookup wlan0
14000:  from all oif dummy0 lookup dummy0
14000:  from all oif wlan0 lookup wlan0
15000:  from all fwmark 0x0/0x10000 lookup legacy_system
16000:  from all fwmark 0x0/0x10000 lookup legacy_network
17000:  from all fwmark 0x0/0x10000 lookup local_network
19000:  from all fwmark 0x64/0x1ffff lookup wlan0
22000:  from all fwmark 0x0/0xffff lookup wlan0
23000:  from all fwmark 0x0/0xffff lookup main
32000:  from all unreachable
```
