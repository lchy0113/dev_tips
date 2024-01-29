# Contiguous Memory Allocator - CMA(Linux)

## introduction

 일부 하드웨어 block은 **Memory Management Unit(MMU)**를 통해 메모리 액세스를 수행한다. 
  즉, 가상 주소 공간을 사용하고 물리적 주소를 사용하여 직접 메모리에 액세스한다.

 예로, Direct Meomory Access(DMA) controller 또는 Heterogeneous Multicore Processing (HMP) 환경에서의 Companion CPU(Ex, COretex M Controller)가 있다. 

 이를 위해서는 연속적인 물리적 주소로 메모리 block을 할당해야 한다. 이를 해결하는 방법으로 Contiguous Memory Allocator (CMA)가 있다. 

  > page-sized 로  DMA를 수행하는 방법도 존재함.
  > scatter-gather 를 사용하는 방법도 존재, 즉, SW 또는 HW의 작은 memory 영역 list 을 사용하거나, boot time에 memory를 독점적으로 관리하는 방법. DMA use, input-output memory management unit(IOMMU)

 CMA는 kernel 내의 memory allocator 로 인접한 메모리 주소로 큰 메모리 덩어리를 할당 해주고 있다.


## Intended audience

> CMA size를 설정에 대해 설명 

 - App layer에서  종종 GPU 또는 VPU 사용으로 인해 big chunk of CMA 를 사용하여 기존 CMA 으로만은 부족할 때, 늘려야 한다.
 - CMA 가 필요하지 않은 경우, CMA 사이즈를 줄여야 한다.


## CMA 

 CMA 는 boot time에 large memory 를 예약(reserve) 하고, CMA 를 사용하고자 하는 kernel memory subsystem에 제약 조건과 함께 전달하는 방식으로 작동된다.

 CMA 는 kernel config에 의해 활성화 된다.


### CMA area 사이즈 설정

 CMA area 사이즈를 구성하는 방법에는 3가지가 있다.   
 devicetree는 kernel cmdline의 내용을 overrules 시키고,cmdline 은 kernel configuration 을 overrules 한다.
 즉,  kernel configuration > cmd line > devicetree

 devicetree에서 CMA area를 설정하면 CMA area이 위치해야 하는 주소에서 length 를 설정할 수 있다.

 - device tree
	 ***reserved-memory/linux,cma*** Node를 추가.

```dts
	linux,cma {
		compatible = "shared-dma-pool";
		inactive;
		reusable;
		reg = <0x0 0x10000000 0x0 0x04000000>;
		linux,cma-default;
	};
```

 - command line

```bash
cma=256MB
```

 - kernel configuration

```bash
#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=16
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8
CONFIG_GENERIC_ARCH_TOPOLOGY=y
```


 - CMA reserved size 를 확인
```bash
# dmesg | grep cma

F: reserved mem: initialized node linux,cma, compatible id shared-dma-pool
[    0.000000] Memory: 1942548K/2078720K available (15614K kernel code, 2056K rwdata, 9120K rodata, 1280K init, 945K bss, 70636K reserved, 65536K cma-reserved)
[    1.079848] ion_device_add_heap: linux,cma id=2 type=4
```


### CMA use in the BSP

 CMA area가 필요한 size 는 실제로 사용하는 subsystem에 따라 다르다. 
 big chunks의 사용자는 주로 GPU 및 VPU subsystem(ex. 3D  acceleration and video decoding/encoding)이다.

 CMA area 할당 요청을 수행하기에 너무 작은 경우 커널은 아래 에러를 출력한다.
  ex. CMA를 64MB로 설정한 다음 비디오 재생 시, 

```bash
[   38.419943] cma: cma_alloc: alloc failed, req-size: 4097 pages, ret: -12
```
