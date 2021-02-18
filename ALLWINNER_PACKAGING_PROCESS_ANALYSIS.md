# Allwinner Packaing Process Analysis
-----

- introduction to firmware packaging.
- Packaging script analysis.
- Analysis of firmware components.


<hr/>

## introduction to firmware packaging.
> firmware packaging은 compile된 bootloader, kernel, root file system을 하나의 image file에 write 하는 것을 의미.
> 이미지를 nand, eMMC, or sd card에 flashing하여 시스템을 동작 가능케 함.

<hr/>

## Packaging script analysis.
script flow
> lichee directory에서 ./build.sh을 실행하고 컴파일이 완료되면 packaging을 실행 할 수 있다. 전체 packaging process는 아래 그림과 같다. 
![](./image/ALLWINNER_PACKAGING_PROCESS_ANALYSIS-1.png)

Packaing script는 다음과 같은 5단계로 구분된다. 
	do_prepare
	do_ini_to_dts
	do_common
	do_pack_${PACK_PLATFORM}
	do_finish

## Analysis of each stage of packaging
### do_prepare
 파일을 복사하는 작업을 진행하며, tools/pack/out directory에 복사된다. 
 tools_file_list, configs_file_list, boot_resource_list, boot_file_list로 분류되어 복사된다. 
 추구 패키징에 추가하고 싶은 항목이 있으면 추가 하면 됨. 
```
echo "copy tools file"
for file in ${tools_file_list[@]} ; do
	 cp -f $file out/ 2> /dev/null
	echo "[${file}]"
done

echo "copy configs file"
for file in ${configs_file_list[@]} ; do
	cp -f $file out/ 2> /dev/null
	echo "[${file}]"
done

echo "copy boot resource"
for file in ${boot_resource_list[@]} ; do
	cp -f `echo $file | awk -F: '{print $1}'` \
		`echo $file | awk -F: '{print $2}'` 2>/dev/null
	echo "[${file}]"
done

```

### do_ini_to_dts
 linux device tree를 설명하는 sunxi.dtb파일이 컴파일 및 생성 됨.
> sunxi build 시스템을 분석하며, linux ver 3.10 에서 처음으로 devicetree 개념이 도입되어, devicetree의 개념을 system에 적용하기 위해 이와 같은 방법을 도입한 것으로 추측됨. allwinner사의 차기 시스템(이후 버전)에서는 devicetree 를 가공하지 않고 mainline으로 적용하여 사용하고 있는 것으로 보임. 
```
$DTC_COMPILER -O dtb -o ${LICHEE_OUT}/sunxi.dtb \
	-b 0	\
	-i $DTC_SRC_PATH    \
	-F $DTC_INI_FILE	\
	-d $DTC_DEP_FILE $DTC_SRC_FILE
```

### do_common
 packaging 에 사용되는 file analysis, partition packaging 등 시스템에 관련된 parameters를 업데이트 한다.  

```
if [ -f "${LICHEE_OUT}/sunxi.dtb" ]; then
	cp ${LICHEE_OUT}/sunxi.dtb sunxi.fex
	fastdtb sunxi.fex
	update_uboot_fdt u-boot.fex sunxi.fex u-boot.fex
fi

# Those files for Nand or card0
update_boot0 boot0_nand.fex 	sys_config.bin NAND 		> /dev/null
update_boot0 boot0_sdcard.fex   sys_config.bin SDMMC_CARD 	> /dev/null
update_uboot u-boot.fex         sys_config.bin 				> /dev/null
update_fes1  fes1.fex           sys_config.bin 				> /dev/null
fsbuild      boot-resource.ini  split_xxxx.fex 				> /dev/null

if [ -f boot_package.cfg ]; then
	echo "pack boot package"
	busybox unix2dos boot_package.cfg
	dragonsecboot -pack boot_package.cfg

	if [ $? -ne 0 ]
	then
		echo "dragon pack run error"
		exit 1
	fi
fi

# generate the u-boot env partition from config file.
# input_config_file env.cfg 
# output_config_bin_file env.fex
u_boot_env_gen env.cfg env.fex > /dev/null

#arisc
if [ -f "${LICHEE_OUT}/arisc" ]; then
	ln -sf $(get_realpath $LICHEE_OUT ./)/arisc arisc.fex
fi

```

### do_pack_${PACK_PLATFORM}
 시스템 플랫폼에 고유한 작업은 진행되며, 우리의 경우 Android 플랫폼에 필요한 boot.img, system.img, recovery.img 를 링크시킨다. 
 리눅스와 같은 플랫폼의 경우, 커널 파일과 파일 시스템을 링크 시킨다.  

```
ln -sf ${AOSP_IMAGE_PATH}/boot.img		boot.fex
ln -sf ${AOSP_IMAGE_PATH}/system.img	system.fex
ln -sf ${AOSP_IMAGE_PATH}/recovery.img	recovery.fex

if [ -f ${AOSP_IMAGE_PATH}/userdata.img ]; then
	ln -sf ${AOSP_IMAGE_PATH}/userdata.img	userdata.fex
fi
```

### do_finish
 전 단계까지 진행하며 지정된 펌웨어 리스트를 패키징한다. 
```
update_mbr          sys_partition.bin 4 > /dev/null
 /* 파티션 구조 파일 sunxi_mbr.fex & 파티션 다운로드 파일 목록 dlinfo.fex생성 */

dragon 		image.cfg		 sys_partition.fex
 /* 파일 리스트 및 파티션 정보에 따라 패키징 */
```

## Analysis of firmware components
 펌웨어 패키지를 구성하는 파일에 대해 설명.

 tools/pack/out/image.cfg 파일을 열어보면 아래와 같은 데이터를 확인할 수 있다. 
```
[DIR_DEF]
INPUT_DIR = "../"

;(eng) document list
[FILELIST]
;(eng) maintype and subtype cannot be changed 
    ;-------------------------------��������---------------------------------------;
	;(eng)Public section

	;(eng) consistent
    {filename = "sys_config.fex",   maintype = ITEM_COMMON,       subtype = "SYS_CONFIG100000",},
    {filename = "config.fex",       maintype = ITEM_COMMON,       subtype = "SYS_CONFIG_BIN00",},
    {filename = "split_xxxx.fex",   maintype = ITEM_COMMON,       subtype = "SPLIT_0000000000",},
    {filename = "sys_partition.fex",maintype = ITEM_COMMON,       subtype = "SYS_CONFIG000000",},
    {filename = "sunxi.fex",        maintype = ITEM_COMMON,       subtype = "DTB_CONFIG000000",},

	;(eng) boot file
    {filename = "boot0_nand.fex",   maintype = ITEM_BOOT,         subtype = "BOOT0_0000000000",},
    {filename = "boot0_sdcard.fex", maintype = "12345678",        subtype = "1234567890BOOT_0",},
    {filename = "u-boot.fex",   	maintype = "12345678",        subtype = "UBOOT_0000000000",},
    {filename = "toc1.fex",     	maintype = "12345678",        subtype = "TOC1_00000000000",},
    {filename = "toc0.fex",     	maintype = "12345678",        subtype = "TOC0_00000000000",},
    {filename = "fes1.fex",         maintype = ITEM_FES,          subtype = "FES_1-0000000000",},
    {filename = "boot_package.fex", maintype = "12345678",        subtype = "BOOTPKG-00000000",},

	;(eng) USB mass production part
    ;-->tools�ļ�
	;(eng) tools file
    {filename = "usbtool.fex",      maintype = "PXTOOLSB",        subtype = "xxxxxxxxxxxxxxxx",},
    {filename = "aultools.fex",     maintype = "UPFLYTLS",        subtype = "xxxxxxxxxxxxxxxx",},
    {filename = "aultls32.fex",     maintype = "UPFLTL32",        subtype = "xxxxxxxxxxxxxxxx",},

	;(eng) Card mass production part
	;(eng) Fixed PC usage
    {filename = "cardtool.fex",     maintype = "12345678",        subtype = "1234567890cardtl",},
    {filename = "cardscript.fex",   maintype = "12345678",        subtype = "1234567890script",},

	;(eng) First that need to be burned to the card
    {filename = "sunxi_mbr.fex",       maintype = "12345678",        subtype = "1234567890___MBR",},
    {filename = "dlinfo.fex",          maintype = "12345678",        subtype = "1234567890DLINFO",},
    {filename = "arisc.fex",           maintype = "12345678",        subtype = "1234567890ARISC" ,},
	;(eng) Other

;(eng) maintype and subtype cannot be changed

;(eng) Mirror configuration information
[IMAGE_CFG]
version = 0x100234                ;-->Image�İ汾 	;(eng) Image version
pid = 0x00001234                  ;-->��ƷID			;(eng) Product ID
vid = 0x00008743                  ;-->��Ӧ��ID		;(eng) Vendor ID
hardwareid = 0x100                ;-->Ӳ��ID bootrom	;(eng) Hardware ID bootrom
firmwareid = 0x100                ;-->�̼�ID bootrom	;(eng) Firmware ID bootrom
bootromconfig = "bootrom_071203_00001234.cfg"
rootfsconfig = "rootfs.cfg"
;;imagename = "ePDKv100_nand.img"
filelist = FILELIST
;imagename = ..\sun4i_test_evb.img
encrypt = 0		;-->�������Ҫ���ܽ���������Ϊ0	����������Ϊ1	;(eng) If encryption is not required, set this to 0, otherwise set to 1 

imagename = RICHGOLD_sun8iw11p1_androidm_a40-p1_uart0_none_v0-0.img
```

Custom으로 파일을 추가해야 하는 경우, 필요한 파일의 Type을 지정하여 script파일 작성 가능하다.
 * filename : package file
 * maintype : package format
 * subtype : custom name (최대 16Byte)
> 위의 규칙에 따라 작성하고 파일의 [FILELIST] Tab에 추가하면 함께 패키징된다.

아래 Table은 image.cfg 에서 각 펌웨어 멤버에 대한 설명.

| name              | function                                                                                                            |
|-------------------|---------------------------------------------------------------------------------------------------------------------|
| sys_config.fex    | Hardware-related configuration file  리스트 정보를 갖고 있다.                                                       |
| config.fex        | sys_config.fex에 대한 binary file.                                                                                  |
| split_xxxx.fex    | As one of the input parameters of fsbuild, make partition mirror                                                    |
| sys_partition.fex | 스토리지 장치에 생성될 파티션을 정의하는 파일. 파티션 갯수, 파티션 속성을 정의.                                     |
| sunxi.fex         | device tree 구성정보.                                                                                               |
| boot0_nand.fex    | boot0 은 타겟 장치(nand 스토리지) 의 RAM에서 실행된다.  boot0 은 RAM을 초기화하고, 스토리지에서 uboot을 로드한다.   |
| boot0_sdcard.fex  | boot0 은 타겟 장치(sdcard 스토리지) 의 RAM에서 실행된다.  boot0 은 RAM을 초기화하고, 스토리지에서 uboot을 로드한다. |
| u-boot.fex        | u-boot binary.                                                                                                      |
| toc1.fex          | security boot 관련 파일.                                                                                            |
| toc0.fex          | security boot 관련 파일.                                                                                            |
| fes1.fex          | RAM 초기화에 사용되며 초기화 결과값을 반환함.  부팅 시, 이 코드가 가장 먼저 실행된다.                               |
| boot_package.fex  | u-boot 코드가 압축되어 있음.                                                                                        |
| usbtool.fex       | nor-flash 에 사용.                                                                                                  |
| aultools.fex      | usb flashing tool. 64bit system                                                                                     |
| aultools32.fex    | usb flashing tool. 32bit system                                                                                     |
| cardtool.fex      | Card burning tool.                                                                                                  |
| cardscript.fex    | Specify each partition file burned by Card.                                                                         |
| sunxi_mbr.fex     | Partition master boot record                                                                                        |
| dlinfo.fex        | 지정된 파티션에 다운로드 할 파일 정의.                                                                              |
| arisc.fex         | standby, power management 등을 관리하는데 사용되는 코드.( in A40i)                                                  |

 image.cfg 파일의 리스트 외에도 sys_partition.fex 의 리스트의 파일도 패키징시 포함된다. 

sys_partition.fex 을 보면 다음과 같다.

```
[partition_start]
```
