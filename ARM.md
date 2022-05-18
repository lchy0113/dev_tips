# ARM Processor 개요

## ARM
영국의 ARM(Advanced RISC Machines)회사는 RISC 프로세서를 설계하고 라이센싱하는 회사입니다.
그 중에서 ARM社의 주요 사항은 ARM 아키쳐를 개발 및 CPU를 디자인 합니다. 
ARM Processor는 로드 및 저장 아키텍처를 구현하므로 일반적인 RISC 프로세서입니다.
로드 및 저장 명령어만 메모리에 액세스할 수 있고 데이터 처리 명령어는 레지스터 내용에 대해서만 작동합니다. 
ARM에서 구현된 Thumb®, Thumb-2, NEON™, VFP 또는 Wireless MMX 명령어 등의 여러 명령어들에 의해 정리되고, 실행 됩니다.

ARM社는 직접 processor 반도체를 제조해 판매하지 않습니다. 
대신 설계한 processor를 Intellectual property(IP) 형태로 제공하며, 이에 대한 license를 판매합니다. 
ARM processor IP는 일종의 설계도로, 여러 반도체 회사들이 여기에 필요한 주변장치들을 추가해 System On Chip(Soc) 형태로 반도체를 제조해 판매합니다.

ARM processor의 가장 큰 장점은 성능에 비해 전력 소비량이 작다는 것입니다. 
때문에 스마트폰이나 PDA 같은 비교적 큰 computing power가 필요하지만 전력 소비량이 작아야 하는 휴대용 기기 또는 임베디드 분야에서 많이 사용합니다.

## 용어정리
ARM 관련 자료에는 ARM architecture, ARM core, ARM processor라는 용어들이 자주 나오는데, 각각의 의미는 다음과 같습니다. 
먼저, ARM architecture는 명령어, 레지스터 구조, 메모리 구조 등의 processor기본 구조와 동작원리에 대한 정의를 의미합니다.
그리고 이 ARM architecture에 따라 구현한 processor의 핵십 부분을 ARM core라고 합니다.

이 ARM core에 Cache, Memory Management Unit(이하 MMU), Memory Protection Unit(이하 MPU), Tightly Coupled Memory (이하 TCM), Bus Interface Unit (이하 BIU) 등의 핵심 주변장치들을 추가해놓은 것을 ARM processor라고 합니다. 
아래 표는 ARM architecture와 그 architecture를 따르는 주요 ARM core 및 그 특징을 보여줍니다.

| **Arichitecture** 	| **특징**                                                                                                                                      	| **Core**          	|
|-------------------	|-----------------------------------------------------------------------------------------------------------------------------------------------	|-------------------	|
| ARMv1             	| 첫 ARM processor 26 bit addressing                                                                                                            	| ARM1              	|
| ARMv2             	| 32 bit multiplier 32 bit coprocessor 지원                                                                                                     	| ARM2              	|
| ARMv2a            	| On-Chip cache SWAP 명령 추가                                                                                                                  	| ARM3              	|
| ARMv3             	| 32 bit addressing CPSR과 SPSR regisger 분리 Mode 추가 (undefined mode, abort mode) MMU 지원 (가상 메모리)                                     	| ARM6 ARM7DI       	|
| ARMv3M            	| Signed/unsigned long multiply 명령 추가                                                                                                       	| ARM7M             	|
| ARMv4             	| Signed/unsigned halfwords/bytes load-store 명령 추가 Mode 추가 (system mode) 26 bit addressing 지원하지 않음                                  	| StrongARM         	|
| ARMv4T            	| Thumb 명령 추가                                                                                                                               	| ARM7TDMI ARM9TDMI 	|
| ARMv5T            	| ARMv4T의 확장판 향상된 ARM과 Thumb state 간 전환 명령 추가 Digital Signal Processing(이하 DSP) 성능 향상을 위한 명령 추가 (Enhanced DSP 명령) 	| ARM9E ARM10E      	|
| ARMv5TEJ          	| Java bytecode 성능 향상을 위한 명령 추가 (Jazelle 기술)                                                                                       	| ARM7EJ ARM926EJ   	|
| ARMv6             	| Multiprocessor 명령 개선 Unaligned and mixed endian 데이터 처리 지원 Multimedia 명령 추가                                                     	| ARM11             	|
<ARM architecture 별 특징과 구현 ARM core 예>

ARM core는 특징에 따라 몇 개의 family로 구분합니다. 
아래 표는 ARM core family와 그 familiy에 속하는 ARM core의 대략적인 특징을 보여줍니다.

|                                	| **ARM7**    	| **ARM9**     	| **ARM10**    	| **ARM11**    	|
|--------------------------------	|-------------	|--------------	|--------------	|--------------	|
| 파이프라인 단계                	| 3           	| 5            	| 6            	| 8            	|
| 동작 주파수 (MHz) (Worst case) 	| 125         	| 220 ~ 250    	| 266 ~ 325    	| 400          	|
| 전력 소비량 (mW/MHz)           	| 0.06        	| 0.4 (+cache) 	| 0.5 (+cache) 	| 0.4 (+cache) 	|
| 성능 (MIPS/MHz)                	| 0.9         	| 1.1          	| 1.3          	| 1.2          	|
| 구조                           	| Von Neumann 	| Harvard      	| Harvard      	| Harvard      	|
<ARM core family 별 특징>

ARM architecture, ARM core, 또는 ARM processor 이름에 포함된 알파벳과 숫자의 의미는 다음과 같습니다.
ARM [a] [b] [T] [D] [M] [I] [E] [J] [F] [-S]
	a : 속한 ARM core family
	b : memory management unit, memory protection unit, cache, TCM 구성
	T : Thumb 명령 지원
	D : 디버그 기능 지원
	M : 64 bit 결과를 내는 곱셈기 지원
	I : In-Circuit Emulator(이하 ICE) 기능 지원
	E : DSP 성능 향상을 위한 명령(Enhanced DSP 명령) 지원
	J : Java bytecode 성능 향상을 위한 명령(Jazelle 기술) 지원
	F : Vector Floating-Point(이하 VFP) 구조 지원
	-S: Electronic Design Automation(이하 EDA) 도구로 synthesis 할 수 있음

예를 들어, ARM926EJ-S의 “9”는 ARM 9 family에 속함을, “26”은 MMU와 cache 그리고 TCM 지원을, “E”는 DSP 성능 향상을 위한 명령(Enhanced DSP 명령) 지원을, J는 Java bytecode 성능 향상을 위한 명령(Jazelle 기술) 지원을, -S는 EDA 도구로 synthesis 할 수 있음을 의미합니다. 
그리고 ARM 9 family 부터는 대부분 “T”, “D”, “M”, “I” 가 나타내는 기능들을 기본적으로 포함하기 때문에 이 알파벳들은 생략합니다.

## Programmer's Model
Programmer's model이란 프로그래머가 프로그램을 작성하기 위해 필요한 정보를 의미합니다. 
명령어, 메모리 구조, 동작 모드, 레지스터, 예외처리 방법, 인터럽트 처리 방법 등이 이에 해당합니다. 
이 programmer’s model은 ARM architecture에 따라 조금씩 달라집니다.

- 명령어 집합, 명령어 집합 상태, 동작 모드
	* ARM Thumb instruction set
	ARM은 ARM instruction set과 Thumb instruction set이라는 두 종류의 명령어 집합(instruction set)을 지원한다. 
	ARM instruction set에 속하는 명령어들은 모두 32비트 명령어입니다. 
	Thumb instruction set에 속하는 명령어들은 모두 16비트 명령어입니다.
	따라서 동일한 C언어 소스코드로 작성된 프로그램을 ARM 명령어 집합으로 컴파일 했을 때와 Thumb명령어 집합으로 컴파일 했을 때에 생성되는 바이너리 이미지의 크기는 이상적인 상황에서 ARM 명령어 집합으로 컴파일
	하는 것이 Thumb 명령어 집합으로 컴파일 하는 것 보다 정확히 두 배 커야 합니다

	물론 여러가지 최적화 기법을 컴파일러가 적용하기 때문에 실제로 ARM 명령어 집합의 바이너리 이미지가 Thumb 명령어 집합의 바이너리 이미지보다 두 배 큰 경우는 거의 생기지 않습니다.
	
	* Instruction Set State
	ARM은 명령어 집합이 두 개이므로 해당 명령어 집합을 실행하는 프로세서의 상태도 이에 연동되어 두 개이다.
	ARM 명령어 집합에 해당하는 32비트 명령어를 실행하는 프로세서의 상태를 ARM 상태(ARM state)라고 하고 마찬가지로, Thumb 명령어 집합에 해당하는 16비트 명령어를 실행하는 상태를 Thumb 상태(Thumb state)라고 합니다.

	당연히 ARM 상태와 Thumb 상태는 프로세서가 동작하는 중간에 서로 변경 가능하다.
	ARM 명령어 중에 BX나 BLX를 사용해서 ARM 상태에서 Thumb 상태로 변경할 수 있습니다. 
	서로 상태를 바꾸어가며 변경이 가능할 뿐 두 명령어 집합을 섞어서 사용할 순 없습니다. 
	ARM 상태에서 ARM 명령어 집합의 명령을 수행하다가 Thumb 명령어가 나오면 반드시 프로세서의 명령어 수행 상태를 변경해야 합니다.

	CortexA5에서는 추가로 두 가지 프로세서 상태가 더 존재 하는데 ThumbEE 상태와 Jazelle 상태입니다 ThumbEE 상태는 Thumb 명령어와는 다른 명령어로 프로그램이 실행되는 중간에 실행코드를 만들어 내며 일종의 바이트 코드의 형태라고 보면 됩니다 Jazelle 상태는 1바이트 단위로 정렬되고 길이가 가변적인 Java 바이트 코드를 해석하기 위한 프로세서 동작 상태입니다.


> 출처 : https://julrams.tistory.com/11?category=646625
