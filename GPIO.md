# GPIO

GPIO : General Purpose Input Output, 단일 비트로 디지털 정보(high/low voltage) 를 전송 및 수신하는 핀을 나타냅니다.

GPIO bank : CPU 또는 DMA에서 동시에 접근할 수 있는 GPIO bit group 입니다.   
그룹의 bit수는 일반적으로 내부 데이터 버스의 크기에 의해 제한됩니다.   예를 들어, 24개의 I/O핀이 있는 8비트 MUC에는 최소 3개의 GPIO *bank*가 필요합니다. 
일부는 다른 전압에서 작동하거나 대체 기능을 갖추고 있거나 또는 특정 패키지에 그룹의 모든 bit를 가져오기에 충분한 핀이 없기 때문에 비트가 더 많은 뱅크로 분할 되는 경우가 있습니다.


GPIO controller : GPIO 핀의 작동을 제어하는 MCU의 회로입니다. 
