# MBR(Master Boot Record) Partition.
-----

## sector 
- 저장장치는 데이터를 찾아가기 위해 섹터(sector)란 구조로 주소화 시켰으며, 이 때 주소는 섹터를 최소 단위로 하며 섹터의 크기는 512 Byte 로 구성되어 있다.
- 1 sector  = 512 Bytes

## MBR(Master Boot Record)
-----
- 저장 장치의 첫번째 섹터는 MBR.
- 파티션된 기억장치의 첫 섹터인 512 Byte의 시동 섹터.
- MBR은 3가지 정보가 있다.
  * Boot Strap Code : 운영체제를 부팅시기기 위한 부팅 파티션을 찾는 부분.
  * Partition Table Entry : 파티션의 정보가 포함된 부분.
  * Signature : 해당 섹터의 오류 유무를 확인하기 위한값. (default : 0xAA55)

(example) Allwinner A40i board.
- MBR(Master Boot Record) 구조.
```
$ hexdump  -Cv -s0 -n512 mmcblk2p.dump 
00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000020  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000030  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000040  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000060  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000070  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000080  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000090  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000a0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000b0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000c0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000d0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000e0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000f0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000100  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000110  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000120  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000130  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000140  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000150  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000160  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000170  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000180  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000190  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000001a0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000001b0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 80 00  |................|
000001c0  00 00 0b 00 00 00 00 a0  70 00 00 d0 62 01 00 00  |........p...b...|
000001d0  00 00 06 00 00 00 00 20  01 00 00 00 01 00 00 00  |....... ........|
000001e0  00 00 05 00 00 00 01 00  00 00 00 80 6e 00 00 00  |............n...|
000001f0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 55 aa  |..............U.|
00000200
```

- Boot Code[0x0000 - 0x01BD]
```
$ hexdump  -Cv -s0 -n445 mmcblk2p.dump 
00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000020  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000030  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000040  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000060  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000070  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000080  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000090  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000a0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000b0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000c0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000d0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000e0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000f0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000100  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000110  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000120  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000130  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000140  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000150  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000160  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000170  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000180  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000190  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000001a0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000001b0  00 00 00 00 00 00 00 00  00 00 00 00 00           |.............|
000001bd
```

- Partition Table Entry
	> MBR에 파티션 정보는 4개 기록
	> MBR에 기록하는 파티션 정보는 주 파티션 정보이며 확장 파티션의 논리 드라이버는 기록되지 않음.
	+ Boot Flag(1 Byte) : 부팅에 사용되는 파티션일 경우, 사용. (부팅:0x80, 불가:0x00)
	+ Starting CHS Address(3 Byte) : 주소 지정 방식이 CHS인 경우, 파티션의 시작 위치.
	+ Partition Type(1 Byte) : [해당 파티션의 유형](http://en.wikipedia.org/wiki/Partition_type)
	+ Ending CHS Address(3 Byte) : 주소 지정 방식이 CHS인 경우, 파티션의 끝 위치.
	+ Starting LBA Address(4 Byte) : 주소 지정방식이 LBA인 경우, 파티션의 시작 섹터 위치.
	+ Size if Sector(4 Byte) : 파티션(LBA0에 할당된 섹터의 총 수. (1 sector * 512 = 1 Byte)
* Partition Table Entry 1 [0x01BE - 0x01CD]
```
$ hexdump  -Cv -s446 -n16 mmcblk2p.dump
000001be  80 00 00 00 0b 00 00 00  00 a0 70 00 00 d0 62 01  |..........p...b.|
000001ce
```
* Partition Table Entry 2 [0x01CE - 0x01DD]
```
$ hexdump  -Cv -s462 -n16 mmcblk2p.dump
000001ce  00 00 00 00 06 00 00 00  00 20 01 00 00 00 01 00  |......... ......|
000001de
```
* Partition Table Entry 3 [0x01DE - 0x01ED] 
```
$ hexdump  -Cv -s478 -n16 mmcblk2p.dump
000001de  00 00 00 00 05 00 00 00  01 00 00 00 00 80 6e 00  |..............n.| 
000001ee
```
* Partition Table Entry 4 [0x01EE - 0x01FD] 
```
$ hexdump  -Cv -s494 -n16 mmcblk2p.dump
000001ee  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................| 
000001fe
```

| Partition | Boot Flag | Starting CHS Address | Partition  Type | Ending CHS Address |  Starting LBA Address  |           Size in Sector          |
|:---------:|:---------:|:--------------------:|:---------------:|:------------------:|:----------------------:|:---------------------------------:|
|        #1 |      0x80 |             0x000000 |            0x0b |           0x000000 | 0x0070a000 (7,380,992) | 0x0162d000 (23,252,992; 11.08 GB) |
|        #2 |      0x00 |             0x000000 |            0x06 |           0x000000 |    0x00012000 (73,728) |         0x00010000 (65,536;32 KB) |
|        #3 |      0x00 |             0x000000 |            0x05 |           0x000000 |         0x00000001 (1) |    0x006e8000 (7,241,728;3.45 GB) |
|        #4 |      0x00 |             0x000000 |            0x00 |           0x000000 |          0x00000000 () |                    0x00000000 (;) |


* Partition Type
  + 0x05 : DOS 3.3+ Extended Partition
  + 0x0F : Extended LBA Partition

- Signature 
```
$ hexdump  -Cv -s510 -n2 mmcblk2p.dump
000001fe  55 aa                                             |U.| 
00000200
```
