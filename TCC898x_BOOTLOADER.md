## [ BOARD ]
----------
SMP8985_OTT_D4152_V1.0


## [ DT ]
----------
tcc8985-android-ott-v02.dtb


## [ Toolchain ]
----------
/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-


## [ boot image structure. ]
----------
|-------------------|  
|Boot img header    |  
|-------------------|  
|Kernel             |  
|-------------------|  
|Ramdisk            |  
|-------------------|  
|Device tree table  |  
|-------------------|  
  


## [ Bootloader (LK) ]
----------


# LK call flow
----------
* The sequence starts with arch/arm/crt0.S: _start.
a. Set up CPU.
b. Call __cpu_early_init() if necessary (platform-specific initialization sequence)
c. Relocate if necessary.
d. Set up stack.
e. Call kmain().
	Kernel/main.c: kmain()
		thread_init_early()
		arch_early_init()
		platform_early_init()
		target_early_init()
		init: heap, thread, dpc, timer
		bootstrap2()
			Arch_init()
			Platform_init()
			Target_init()
			Apps_init()

* Calls made from bootstrap2():
a. arch/arm/arch.c -arch_init()
	Stub
b. platform/<platform>/(platform.c) -platform_init()
	Stub
c. target/<target>/(init.c) -target_init()
	Init SPMI
	Init keypad
	Set drive strength and pull configs for SDC pins (we have transitioned to SDHCI)
	Init the SD host controller/MMC card; identify the MMC card; set the clock, etc.
	mmc_init()
	Read the partition table from the eMMC card.
	partition_read_table()
d. app/init.c -apps_init()
	Init apps that are defiend using APP_START and APP_END macros; about_init() is called
	Run the app in a separate thread if it has .entry section.
e. app/aboot/aboot.c -aboot_init()
	* Regular boot.
	* Fastboot mode to accept images.
	* Recovery mode to jump to recovery firmware.

# LK regular boot.
-----
* Recovery flag or fastboot keys not set.
* Pulls out boot.img from the MMC and loads it into the scratch region (base address = 0x2000000) specified in target/tcc898x_stb/rules.mk
* Loads kernel from the scratch region into KERNEL_ADDR (retrieved from boot image header).
* Loads RAM disk from the scratch region into RAMDISK_ADDR (retrieved from boot image header).
* Finds the right device tree (for the appropriate SoC) from the device tree table and loads it at TAGS_ADDR (retrieved from boot image header).
* Updates the device tree by:
	- Getting the offset for the '/memory' node and '/chosen' node.
	- Adding HLOS memory regions (start address and size) as "reg" properties to '/memory' node.
	- Adding the cmd line as "bootargs" to the '/chosen' node.
	- Adding the RAM disk properties as "linux, initrd-start" and "linux, initrd-end" to the '/chosen' node.
	- Disable cache, interrupts, jump to kernel.
* This boot flow is illustrated through code snippets in the next section.


## [ Code snippet ]
----------

# [ boot_linux_from_mmc() ]


# [ void boot_linux() ]


# [ updating the device ]
(in t_tcc/aboot.c)
```
update_device_tree((void *)tags, (const char *)final_cmdline, ramdisk, ramdisk_size)

```

# [ LK fastboot mode ]
----------

* about_init checks if:
	boot.img not present, or
	volume down key is pressed.
* Checks reasonfor reboot - check_reboot_mode.
* Registers handlers for fastbootcommands:
```
 	fastboot_register(cmd_list[i].name, cmd_list[i].cb);
```
* Initializes fastboot
```
	fastboot_init(void *base, unsigned size)	
```
	Creates a thread associated with fastboot_handler()
	Thread waits for USB event.
* Sets up USB
	udc_start()

# [ Fastboot commands ]
----------

```
struct fastboot_cmd_desc cmd_list[]
```

# [ LK recovery mode ]
----------

* about_init checks if KEY_HOME or VOLUME UP is pressed.
* Checks reasonfor reboot -check_reboot_mode().
	If value at restart reason address is RECOVERY_MODE, sets boot_into_recovery = 1.
* boot_linux_from_mmc checks:
```
	index = partition_get_index("recovery");
```
* Gets image from recovery partition.
	gned int target_freq, unsigned int relation);

