# hook system call 

## get sys_call_table address
```
obj/KERNEL_OBJ$ cat System.map | rg sys_call_table
c000faa4 T sys_call_table
```
or 
```
$ adb shell
$ cat /proc/kallsyms | grep sys_call_table
```
## check file contains the system call numbers(sys_read()).
```
$ vi arch/arm/include/uapi/asm/unistd.h

/*
 *  arch/arm/include/asm/unistd.h
 *
 *  Copyright (C) 2001-2005 Russell King
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * Please forward _all_ changes to this file to rmk@arm.linux.org.uk,
 * no matter what the change is.  Thanks!
 */
#ifndef _UAPI__ASM_ARM_UNISTD_H
#define _UAPI__ASM_ARM_UNISTD_H

#define __NR_OABI_SYSCALL_BASE	0x900000

#if defined(__thumb__) || defined(__ARM_EABI__)
#define __NR_SYSCALL_BASE	0
#else
#define __NR_SYSCALL_BASE	__NR_OABI_SYSCALL_BASE
#endif

/*
 * This file contains the system call numbers.
 */

#define __NR_restart_syscall		(__NR_SYSCALL_BASE+  0)
#define __NR_exit			(__NR_SYSCALL_BASE+  1)
#define __NR_fork			(__NR_SYSCALL_BASE+  2)
#define __NR_read			(__NR_SYSCALL_BASE+  3)			/** this **/
#define __NR_write			(__NR_SYSCALL_BASE+  4)
#define __NR_open			(__NR_SYSCALL_BASE+  5)
#define __NR_close			(__NR_SYSCALL_BASE+  6)
					/* 7 was sys_waitpid */
#define __NR_creat			(__NR_SYSCALL_BASE+  8)
#define __NR_link			(__NR_SYSCALL_BASE+  9)
#define __NR_unlink			(__NR_SYSCALL_BASE+ 10)
#define __NR_execve			(__NR_SYSCALL_BASE+ 11)
#define __NR_chdir			(__NR_SYSCALL_BASE+ 12)
#define __NR_time			(__NR_SYSCALL_BASE+ 13)
#define __NR_mknod			(__NR_SYSCALL_BASE+ 14)
#define __NR_chmod			(__NR_SYSCALL_BASE+ 15)
#define __NR_lchown			(__NR_SYSCALL_BASE+ 16)
					/* 17 was sys_break */
					/* 18 was sys_stat */
#
...
```

## write hook test module

```
vi hook.c

/**
  * hook.c
  * sys_call_table hooking source.
  */

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/syscalls.h>


void** sys_call_table = (void*)0xc000faa4;	// sys_call_table address setting
asmlinkage ssize_t (*org_sys_read)(int fd, char* buf, size_t count);


asmlinkage ssize_t hooked_read(int fd, char* buf, size_t count)
{
	 printk(KERN_ALERT "pseudo read(): %s\n", buf);
	 return org_sys_read(fd, buf, count);
}

int __init my_init(void)
{
	org_sys_read=*(sys_call_table+__NR_read);
	printk(KERN_ALERT "init sys_read before %p\n", *(sys_call_table+__NR_read));
	*(sys_call_table+__NR_read)=hooked_read;
	printk(KERN_ALERT "init sys_read after %p\n", *(sys_call_table+__NR_read));
	return 0;
}

void __exit my_exit(void)
{
	printk(KERN_ALERT "exit sys_read before %p\n", *(sys_call_table+__NR_read));
	*(sys_call_table+__NR_read)=org_sys_read;
	printk(KERN_ALERT "exit sys_read after %p\n", *(sys_call_table+__NR_read));
}


module_init(my_init);
module_exit(my_exit);

MODULE_LICENSE("GPL");
```

## write Makefile

```
$ vi Makefile

obj-m := hook.o
KDIR := ../out/target/product/nhn1311/obj/KERNEL_OBJ/
PWD := $(shell pwd)

default:
	$(MAKE) ARCH=arm -C $(KDIR) M=$(PWD) modules

clean:
	rm -rf *.ko
	rm -rf *.mod.*
	rm -rf .*.cmd
	rm -rf *.o
	rm -rf .tmp_versions
	rm -rf modules.order
	rm -rf Module.symvers
```
