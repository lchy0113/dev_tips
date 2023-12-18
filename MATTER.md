Matter 
=====

> IP 기반 Home IOT 통신 표준

<br/>
-----

# Open-source Matter SDK
  
> Connected Home Over IP 는 Google, Amazon, Apple, Zigbee Alliance 등이 함께 개발한 IoT 기기 간의 상호 운용성을 향상시키기 위한 개방형 표준.  
> 이 표준은 Wi-Fi, Thread, Bluetooth LE 등 다양한 프로토콜을 지원하며, 사용자는 다양한 제조사의 IoT기기를 하나의 허브에서 관리 가능.
  
[ConnectedHomeIP]: https://github.com/project-chip/connectedhomeip  
  
<br/>
-----

# Matter Study
> Matter 의 원칙은 Local Control


<br/>
-----

# Reference
## smartthings hub
  * 와이파이로 통신되는 제품들은 앱에서 바로 등록하기 때문에 허브가 필요 없음. 이 허브는 지그비 전파를 이용하여 작동되는 기기, 예를들어 전등스위치, 전동커텐레일 등 앱에 바로 등록 불가능한 기기를 스마트싱스앱에 등록시키는 역할.

  * 지그비 전파로 통신되는 기기를 허브에 등록시키려면 삼성Idle 웹에 등록. (스마트싱스 정식 지원 기기들은 DTH가 필요 없이 인식되고 아닌 경우, DTH를 사용하여 인식)
    - Zigbee 방식이 블루투스처럼 그냥 신호만 잡으면 바로 연결되는 것은 아니고, PnP처럼 스마트싱스가 정식 지원하는 센서가 아니면 Device Handler라고 하는 DTH(Device Type Handler)를 설치해야함. 

  * 스마트싱스 IDE사이트 세팅
    - IDE사이트 : https://account.smartthings.com
		![](./image/MATTER-01.png)
		+ Locations : 계정에 할당된 스마트싱스 플랫폼에 대한 장소.
		+ Hubs : 스마트싱스허브 장치에 대한 정보 제공.
		+ Devices : 스마트싱스 플랫폼에 연결된 모든 장치(센서, 가전 등) 정보 제공.
		+ Installed Apps : 쓰마트싱스 플랫폼 내에서 사용할수 있는 각종 앱 관리.
  
    - Github 연동  
        + DTH를 등록하기 위해서는 크게 2가지의 방법이 있음.   
		  = github 연동.  
		  = 수동으로 사용자가 등록  
  
	    + https://github.com/SmartThingsCommunity/SmartThingsPublic 페이지에 접속하여 fork  
	    + IDE 사이트에서 연동.   


  * 결론 : 지그비를 사용하는 기기들을 묶어서 스마트싱스로 제어할 수 있게 하는 제품.

<br/>
-----

[to do]

개발일정
 - matter open-source 검토. : 3 w
 - matter open-source 포팅 (상용 EVB). : 4w
 - matter bridge 기능 동작 : 
 - matter open-source 타겟 보드 포팅 (POC) : (for BT)
 - 모바일에서 matter 기기 제어.(스마트폰 agent app <-> matter hub <-> matter device)
