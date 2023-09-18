Ethernet Fix
=====

> 우분투환경에서 네트워크와 관련하여 다음과 같은 문제가 발생되어 디버깅을 위해 작성함.
>  - 간헐적으로 네트어크 인터페이스가 인식되지 않는다.(정상 동작되지 않는다)
>  - Realtek driver(r8169 계열)사용시,


# 원인

![](./image/ETHERNET_FIX-01.png)
 

```
lchy0113@kdiwin-nb:~$ sudo lshw -c network
[sudo] password for lchy0113:
  *-network
       description: Wireless interface
       product: Cannon Lake PCH CNVi WiFi
       vendor: Intel Corporation
       physical id: 14.3
       bus info: pci@0000:00:14.3
       logical name: wlo1
       version: 10
       serial: dc:71:96:f7:cc:13
       width: 64 bits
       clock: 33MHz
       capabilities: pm msi pciexpress msix bus_master cap_list ethernet physical wireless
       configuration: broadcast=yes driver=iwlwifi driverversion=6.2.0-32-generic firmware=46.fae53a8b.0 9000-pu-b0-jf-b0- latency=0 link=no multicast=yes wireless=IEEE 802.11
       resources: irq:16 memory:a541c000-a541ffff
  *-network
       description: Ethernet interface
       product: RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller
       vendor: Realtek Semiconductor Co., Ltd.
       physical id: 0
       bus info: pci@0000:03:00.0
       logical name: eno2
       version: 15
       serial: 04:d4:c4:e0:c7:77
       size: 1Gbit/s
       capacity: 1Gbit/s
       width: 64 bits
       clock: 33MHz
       capabilities: pm msi pciexpress msix bus_master cap_list ethernet physical tp mii 10bt 10bt-fd 100bt 100bt-fd 1000bt-fd autonegotiation
       configuration: autonegotiation=on broadcast=yes driver=r8169 driverversion=6.2.0-32-generic duplex=full firmware=rtl8168h-2_0.0.2 02/26/15 ip=192.168.0.12 latency=0 link=yes multicast=yes port=twisted pair speed=1Gbit/s
       resources: irq:18 ioport:3000(size=256) memory:a5204000-a5204fff memory:a5200000-a5203fff
```

```

lchy0113@kdiwin-nb:~$ lsmod | grep r8169
r8169                 114688  0

```

 # 1.1 최신 드라이버 설치

```bash
sudo apt-get update
sudo apt-get install r8168-dkms
```

 # 1.2 r8169 모듈 제거

 이후에 r8169 모듈이 올라오는 문제로 발생하는 것을 방지하기 위해서 아래 명령어로 r8169 module을 blacklist 에 추가함.
```bash
sudo sh -c ‘echo blacklist r8169 >> /etc/modprobe.d/blacklist.conf

```
