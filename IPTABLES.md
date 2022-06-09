# iptables

## tables

 - The Filter Table
   Iptables에서 가장 널리 사용되는 테이블. 이 Filter 테이블은 패킷이 계속해서 원하는 목적지로 보내거나 요청을 거부하는데에 대한 결정을 하는데 사용된다. 방화벽 용어로 이것은 “filtering” 패킷들로 알려진다.


 - The NAT Table
   네트워크 주소 변환 규칙을 구현하는데 사용된다. 패킷들이 네트워크 스택에 들어오면, 이 테이블에 있는 규칙들은 패킷의 source 혹은 destination 주소를 변경하거나 변경하는 방법을 결정한다. 보통 direct access가 불가능할 때 네트워크에 패킷들을 라우팅하는데 종종 사용된다. 


 
 - The Mangle Table
   다양한 방법으로 패킷의 IP 헤더를 변경하는데 사용된다. 예를 들어 패킷의 TTL (Time to Live) Value를 조정할수 있다. 이 테이블은 다른 테이블과 다른 네트워킹 툴에 의해 더 처리되기 위해 패킷위에 내부 커널 “mark”를 위치 시킨다. 이 “marks”는 실제 패킷을 건들이지는 않지만 패킷의 커널의 표현에 mark를 추가하는 것이다. 



 - The Raw Table
    Iptables 방화벽은 stateful 방식이다. 이것은 패킷들은 이전 패킷들과 연관되어 평가된다는 것이다. Connection tracking 기능들은 netfilter 프레임워크의 최 상단에서 빌드되어지고 이것은 iptables가 ongoing connection 혹은 관계없는 패킷의 스트림으로의 세션 일부분으로 패킷을 살펴 볼 수 있도록 허용해준다. 이 Raw 테이블은 배우 좁게 정의된 기능이다. 이것의 유일한 목적은 connection tracking을 위한 패킷을 표시하기 위한 메커니즘을 제공하는 것이다.



 - The Security Table
   내부의 internal SELinux 보안 context marks를 패킷에 설정하는데 사용된다. 이것은 SELinux나 다른 시스템들이 어떻게 패킷을 핸들링하는데 영향을 미치는지에 대해 관여한다. 


