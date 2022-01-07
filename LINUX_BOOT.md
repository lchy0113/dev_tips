# Linux kernel boot

init/miain.c: start_kernel() 전에 BIOS 및 기타 단계를 거쳐야 합니다. 여기서는 무시하고 start_kernel에서 직접 시작합니다.
start_kernel() 함수는 CPU 설정 초기화, 메모리 레이아웃 초기화, 메인 커널 페이지 디렉토리 설정 등 커널의 거의 모든 부분을 초기화합니다. 
Process 0도 이 시점에서 커널에 의해 정적으로 생성됩니다.
do_fork에 의해 생성되지 않았습니다., 즉, init_task 이후부터 Linux는 프로세스의 개념을 갖습니다.
이 중 start_kernel()의 끝부분에 rest_init() 함수가 있는데, 이때 init_task는 kernel_init과 kthreadd라는 두 개의 커널 쓰레드를 생성하며, pid는 1과 2이다. 다음 코드는 다음과 같다.
이후 init_task는 자신의 스케쥴링 타입을 idle_sched_class로 설정하고, 이때는 유휴 프로세스가 된다. 그런 다음 스케줄링이 실행되고 kernel_init 커널 스레드가 실행되기 시작합니다.
지금까지는 SMP 환경에서 커널을 부팅하는 것과 싱글 코어로 부팅하는 것 사이에 본질적인 차이는 없습니다.

init/main.c
```
static noinline void __init_refok rest_init(void)
{
	int pid;

	rcu_scheduler_starting();
	/*
	 * We need to spawn init first so that it obtains pid 1, however
	 * the init task will end up wanting to create kthreads, which, if
	 * we schedule it before we create kthreadd, will OOPS.
	 */
	kernel_thread(kernel_init, NULL, CLONE_FS);
	numa_default_policy();
	pid = kernel_thread(kthreadd, NULL, CLONE_FS | CLONE_FILES);
	rcu_read_lock();
	...
}
```



## SMP special case

SMP 환경에 둘 이상의 CPU가 있으므로 위의 작업은 문제가 될 수 있다. Linux는 이 문제를 해결하기 위해서, CPU 중 하나를 BP(Boot Processor)로 선택, 나머지를 AP 라고 지정합니다.
init_task 가 스케줄링 함수를 호출하여 kernel_init 커널 스레드가 BP를 실행하도록 하면 kernel_init() 함수가 실행됩니다. 
kernel_init 커널 스레드는 다른 AP의 초기화 작업을 완료하는 역활을 합니다.

다음 호출 함수는 kernel_init() -> kernel_init_freeable() -> smp_init() 을 호출합니다.

kernel_init_freeable() 함수의 주요 작업은 특정 SMP 아키텍처를 초기화하고 전역 CPU 수 등을 설정한 다음 smp_init() 를 호출 하는 것이며,
주요 호출 논리는 다음과 같습니다.

```
void __init smp_init(void) kernel/smp.c
	|	/* called by boot processor to activate the rest. */
	|
	+-> void __init idle_threads_init(void) kernel/smpboot.c
	|	|	/* initialize idle threads for all cpus */
	|	|
	|	+-> static inline void idle_init(unsigned int cpu)
	|			/* initialize the idle thread for a cpu
	|				cpu : the cpu for which the idle thread should be initialized */
	+-> int cpu_up(unsigned int cpu)
		|
		+-> static int _cpu_np(unsigned int cpu, int tasks_frozen) kernel/cpu.c
			/* wake up idle */
```

smp_init()는 idle_threads_init()을 호출하고, for_each_possible_cpu(cpu)를 통해 각 AP에 대해 idle_init() 작업을 수행하고, 
idle_init()는 fork_idle()을 호출하여 이 AP에 대한 새로운 유휴 프로세스를 생성한 다음, idle_init() 함수를 호출하여
새로 생성된 우휴프로세스 관련 설정이 작동합니다.

그런 다음 smp_init() 는 for_each_cpu()를 통해 각 AP에 생성된 유휴 프로세스를 깨웁니다.

SMP환경에는 유휴프로세스가 하나만 있는 것이 아니라 CPU 마다 유휴프로세스가 있어 적시에 실행되는 것을 알 수 있습니다.

kernel_init 커널 스레드가 다른 AP의 초기화를 완료 한 후 일련의 환경 설정 작업을 수행 한 후, 
init프로세스가 로드되어 사용자공간 프로세스 init 가 되며(pid 1) 사용자 공간 프로세스의 시작자가 됩니다. 


## kernel boot sequence

디바이스 드라이버 등록과정(module_init() 함수를 통해 어떻게 init함수가 등록되고 이 함수는 언제 어떻게 실행되는지)을 
알기 위해서는 커널 초기화 코드를 알아보자.

리눅스 커널은 C코드 상에서 가장 먼저 실행되는 함수는 init/main.c 파일의 kernel_init()로 부터 시작된다. 

```
asmlinkage __visiable void __init start_kernel(void)
	|
	+->	static noinline void __init_refok rest_init(void)
		|
		+-> kernel_thread(kernel_init, NULL, CLONE_FS);
			|
			+-> static int __ref kernel_init(void *unused)
				|
				+-> static noinline void __init kernel_init_freeable(void)
					|
					+-> static void __init do_pre_smp_initcalls(void)
					+-> static void __init do_basic_setup(void)
```

이 중에 do_pre_smp_initcalls() 함수는 for문을 돌면서 do_one_initcall() 함수를 호출한다. 

```
static void __init do_pre_smp_initcalls(void)
{
	initcall_t *fn;

	for (fn = __initcall_start; fn < __initcall0_start; fn++)
		do_one_initcall(*fn);
			|
			+-> int __init_or_module do_one_initcall(initcall_t fn)
}
```

그리고 do_basic_setup() 함수의 do_initcalls()라는 함수에서도 for문을 돌면서 do_one_initcall() 함수를 호출한다. 

```
static void __init do_basic_setup(void)
{
	cpuset_init_smp();
	usermodehelper_init();
	shmem_init();
	driver_init();
	init_irq_proc();
	do_ctors();
	usermodehelper_enable();
	do_initcalls();
		|
		+-> static void __init do_initcalls(void)  
	random_int_secret_init();
}
```

do_one_initcall() 함수는 단순히 각각 __initcall_start부터 __early_initcall_end까지, __early_initcall_end부터, __initcall_end까지 정의된 함수들을 호출해주는 역활을 한다. 
__initcall_start, __early_initcall_end, __initcall_end는  arch/arm/kernel/vmlinux.lds에서 찾아 볼수 있는데, vmlinux.lds 파일은 커널이 링킹되는데 사용되는 스크립트 파일로써
각각의 섹션(text, data)들이 어떻게 배치되는지 알수 있다. 
가장 처음에 나오는 섹션은 .init 섹션으로 init코드 및 데이터들이 위치하는데 .init가 이 섹션을 시작을 의미하며, __init_end는 이 섹션의 끝(아래 코드 * 표시) 을 나타낸다. 
__initcall_start, __early_initcall_end, __initcall_end는 .init 섹션의 서브섹션들을 가지고 있는 배열로 생각하면 되며 각 서브섹션에는 함수 포인터들이 등록되어 있다. 
( 이 함수 포인터들은 뒤에서 설명할 module_init()과 device_initcall() 매크로를 통해 등록된다.)

즉, 다시 말해서 do_pre_smp_initcalls()와 do_initcalls() 함수는 .init 섹션의 서브섹션인 .initcallearly.init, .initcall0.init 등의 서브섹션들에 등록되어 있는 함수 포인터를
do_one_initcall()함수에 넘겨 일괄적으로실행하는 역활을 담당한다.

```
OUTPUT_ARCH(arm)
ENTRY(stext)
jiffies = jiffies_64;
SECTIONS
{
 /*
	 * XXX: The linker does not define how output sections are
	 * assigned to input sections when there are multiple statements
	 * matching the same input section name.  There is no documented
	 * order of matching.
	 *
	 * unwind exit sections must be discarded before the rest of the
	 * unwind sections get included.
	 */
 /DISCARD/ : {
  *(.ARM.exidx.exit.text)
  *(.ARM.extab.exit.text)
 
 
 
 
  *(.exitcall.exit)
  *(.discard)
  *(.discard.*)
 }
 . = 0xC0000000 + 0x00008000;
 .head.text : {
  _text = .;
  *(.head.text)
 }
 .text : { /* Real text segment		*/
  _stext = .; /* Text and read-only data	*/
   __exception_text_start = .;
   *(.exception.text)
   __exception_text_end = .;
  
   . = ALIGN(8); *(.text.hot) *(.text) *(.ref.text) *(.text.unlikely)
   . = ALIGN(8); __sched_text_start = .; *(.sched.text) __sched_text_end = .;
   . = ALIGN(8); __lock_text_start = .; *(.spinlock.text) __lock_text_end = .;
   . = ALIGN(8); __kprobes_text_start = .; *(.kprobes.text) __kprobes_text_end = .;
   . = ALIGN(8); __idmap_text_start = .; *(.idmap.text) __idmap_text_end = .; . = ALIGN(32); __hyp_idmap_text_start = .; *(.hyp.idmap.text) __hyp_idmap_text_end = .;
   *(.fixup)
   *(.gnu.warning)
   *(.glue_7)
   *(.glue_7t)
  . = ALIGN(4);
  *(.got) /* Global offset table		*/
   . = ALIGN(4); __proc_info_begin = .; *(.proc.info.init) __proc_info_end = .;
 }
 . = ALIGN(((1 << 12))); .rodata : AT(ADDR(.rodata) - 0) { __start_rodata = .; *(.rodata) *(.rodata.*) *(__vermagic) . = ALIGN(8); __start___tracepoints_ptrs = .; *(__tracepoints_ptrs) __stop___tracepoints_ptrs = .; *(__tracepoints_strings) } .rodata1 : AT(ADDR(.rodata1) - 0) { *(.rodata1) } . = ALIGN(8); __bug_table : AT(ADDR(__bug_table) - 0) { __start___bug_table = .; *(__bug_table) __stop___bug_table = .; } .pci_fixup : AT(ADDR(.pci_fixup) - 0) { __start_pci_fixups_early = .; *(.pci_fixup_early) __end_pci_fixups_early = .; __start_pci_fixups_header = .; *(.pci_fixup_header) __end_pci_fixups_header = .; __start_pci_fixups_final = .; *(.pci_fixup_final) __end_pci_fixups_final = .; __start_pci_fixups_enable = .; *(.pci_fixup_enable) __end_pci_fixups_enable = .; __start_pci_fixups_resume = .; *(.pci_fixup_resume) __end_pci_fixups_resume = .; __start_pci_fixups_resume_early = .; *(.pci_fixup_resume_early) __end_pci_fixups_resume_early = .; __start_pci_fixups_suspend = .; *(.pci_fixup_suspend) __end_pci_fixups_suspend = .; __start_pci_fixups_suspend_late = .; *(.pci_fixup_suspend_late) __end_pci_fixups_suspend_late = .; } .builtin_fw : AT(ADDR(.builtin_fw) - 0) { __start_builtin_fw = .; *(.builtin_fw) __end_builtin_fw = .; } __ksymtab : AT(ADDR(__ksymtab) - 0) { __start___ksymtab = .; *(SORT(___ksymtab+*)) __stop___ksymtab = .; } __ksymtab_gpl : AT(ADDR(__ksymtab_gpl) - 0) { __start___ksymtab_gpl = .; *(SORT(___ksymtab_gpl+*)) __stop___ksymtab_gpl = .; } __ksymtab_unused : AT(ADDR(__ksymtab_unused) - 0) { __start___ksymtab_unused = .; *(SORT(___ksymtab_unused+*)) __stop___ksymtab_unused = .; } __ksymtab_unused_gpl : AT(ADDR(__ksymtab_unused_gpl) - 0) { __start___ksymtab_unused_gpl = .; *(SORT(___ksymtab_unused_gpl+*)) __stop___ksymtab_unused_gpl = .; } __ksymtab_gpl_future : AT(ADDR(__ksymtab_gpl_future) - 0) { __start___ksymtab_gpl_future = .; *(SORT(___ksymtab_gpl_future+*)) __stop___ksymtab_gpl_future = .; } __kcrctab : AT(ADDR(__kcrctab) - 0) { __start___kcrctab = .; *(SORT(___kcrctab+*)) __stop___kcrctab = .; } __kcrctab_gpl : AT(ADDR(__kcrctab_gpl) - 0) { __start___kcrctab_gpl = .; *(SORT(___kcrctab_gpl+*)) __stop___kcrctab_gpl = .; } __kcrctab_unused : AT(ADDR(__kcrctab_unused) - 0) { __start___kcrctab_unused = .; *(SORT(___kcrctab_unused+*)) __stop___kcrctab_unused = .; } __kcrctab_unused_gpl : AT(ADDR(__kcrctab_unused_gpl) - 0) { __start___kcrctab_unused_gpl = .; *(SORT(___kcrctab_unused_gpl+*)) __stop___kcrctab_unused_gpl = .; } __kcrctab_gpl_future : AT(ADDR(__kcrctab_gpl_future) - 0) { __start___kcrctab_gpl_future = .; *(SORT(___kcrctab_gpl_future+*)) __stop___kcrctab_gpl_future = .; } __ksymtab_strings : AT(ADDR(__ksymtab_strings) - 0) { *(__ksymtab_strings) } __init_rodata : AT(ADDR(__init_rodata) - 0) { *(.ref.rodata) } __param : AT(ADDR(__param) - 0) { __start___param = .; *(__param) __stop___param = .; } __modver : AT(ADDR(__modver) - 0) { __start___modver = .; *(__modver) __stop___modver = .; . = ALIGN(((1 << 12))); __end_rodata = .; } . = ALIGN(((1 << 12)));
 . = ALIGN(4);
 __ex_table : AT(ADDR(__ex_table) - 0) {
  __start___ex_table = .;
  *(__ex_table)
  __stop___ex_table = .;
 }
 .notes : AT(ADDR(.notes) - 0) { __start_notes = .; *(.note.*) __stop_notes = .; }
 _etext = .; /* End of text and rodata section */
 . = ALIGN((1 << 12));
 __init_begin = .;
 /*
	 * The vectors and stubs are relocatable code, and the
	 * only thing that matters is their relative offsets
	 */
 __vectors_start = .;
 .vectors 0 : AT(__vectors_start) {
  *(.vectors)
 }
 . = __vectors_start + SIZEOF(.vectors);
 __vectors_end = .;
 __stubs_start = .;
 .stubs 0x1000 : AT(__stubs_start) {
  *(.stubs)
 }
 . = __stubs_start + SIZEOF(.stubs);
 __stubs_end = .;
 . = ALIGN(8); .init.text : AT(ADDR(.init.text) - 0) { _sinittext = .; *(.init.text) *(.meminit.text) _einittext = .; }
 .exit.text : {
  *(.exit.text) *(.memexit.text)
 }
 .init.proc.info : {
 
 }
 .init.arch.info : {
  __arch_info_begin = .;
  *(.arch.info.init)
  __arch_info_end = .;
 }
 .init.tagtable : {
  __tagtable_begin = .;
  *(.taglist.init)
  __tagtable_end = .;
 }
 .init.smpalt : {
  __smpalt_begin = .;
  *(.alt.smp.init)
  __smpalt_end = .;
 }
 .init.pv_table : {
  __pv_table_begin = .;
  *(.pv_table)
  __pv_table_end = .;
 }
 .init.data : {
  *(.init.data) *(.meminit.data) *(.init.rodata) . = ALIGN(8); __start_ftrace_events = .; *(_ftrace_events) __stop_ftrace_events = .; *(.meminit.rodata) . = ALIGN(8); __clk_of_table = .; *(__clk_of_table) *(__clk_of_table_end) . = ALIGN(8); __reservedmem_of_table = .; *(__reservedmem_of_table) *(__reservedmem_of_table_end) . = ALIGN(8); __clksrc_of_table = .; *(__clksrc_of_table) *(__clksrc_of_table_end) . = ALIGN(8); __cpu_method_of_table = .; *(__cpu_method_of_table) *(__cpu_method_of_table_end) . = ALIGN(32); __dtb_start = .; *(.dtb.init.rodata) __dtb_end = .; . = ALIGN(8); __irqchip_of_table = .; *(__irqchip_of_table) *(__irqchip_of_table_end) . = ALIGN(8); __earlycon_of_table = .; *(__earlycon_of_table) *(__earlycon_of_table_end)
  . = ALIGN(16); __setup_start = .; *(.init.setup) __setup_end = .;
  __initcall_start = .; *(.initcallearly.init) __initcall0_start = .; *(.initcall0.init) *(.initcall0s.init) __initcall1_start = .; *(.initcall1.init) *(.initcall1s.init) __initcall2_start = .; *(.initcall2.init) *(.initcall2s.init) __initcall3_start = .; *(.initcall3.init) *(.initcall3s.init) __initcall4_start = .; *(.initcall4.init) *(.initcall4s.init) __initcall5_start = .; *(.initcall5.init) *(.initcall5s.init) __initcallrootfs_start = .; *(.initcallrootfs.init) *(.initcallrootfss.init) __initcall6_start = .; *(.initcall6.init) *(.initcall6s.init) __initcall7_start = .; *(.initcall7.init) *(.initcall7s.init) __initcall_end = .;
  __con_initcall_start = .; *(.con_initcall.init) __con_initcall_end = .;
  __security_initcall_start = .; *(.security_initcall.init) __security_initcall_end = .;
  . = ALIGN(4); __initramfs_start = .; *(.init.ramfs) . = ALIGN(8); *(.init.ramfs.info)
 }
 .exit.data : {
  *(.exit.data) *(.memexit.data) *(.memexit.rodata)
 }
 . = ALIGN((1 << 12)); .data..percpu : AT(ADDR(.data..percpu) - 0) { __per_cpu_load = .; __per_cpu_start = .; *(.data..percpu..first) . = ALIGN((1 << 12)); *(.data..percpu..page_aligned) . = ALIGN((1 << 6)); *(.data..percpu..read_mostly) . = ALIGN((1 << 6)); *(.data..percpu) *(.data..percpu..shared_aligned) __per_cpu_end = .; }
 __init_end = .;			(*)
```

이 서브섹션에 함수 포인터를 등록하기 위해서는 __define_initcall 매크로가 사용된다. 
```
  __initcall_start = .; *(.initcallearly.init) __initcall0_start = .; *(.initcall0.init) *(.initcall0s.init) __initcall1_start = .; *(.initcall1.init) *(.initcall1s.init) __initcall2_start = .; *(.initcall2.init) *(.initcall2s.init) __initcall3_start = .; *(.initcall3.init) *(.initcall3s.init) __initcall4_start = .; *(.initcall4.init) *(.initcall4s.init) __initcall5_start = .; *(.initcall5.init) *(.initcall5s.init) __initcallrootfs_start = .; *(.initcallrootfs.init) *(.initcallrootfss.init) __initcall6_start = .; *(.initcall6.init) *(.initcall6s.init) __initcall7_start = .; *(.initcall7.init) *(.initcall7s.init) __initcall_end = .;
 ```

 ```
#define __define_initcall(fn, id) \
	static initcall_t __initcall_##fn##id __used \
	__attribute__((__section__(".initcall" #id ".init"))) = fn; \
	LTO_REFERENCE_INITCALL(__initcall_##fn##id)

/*
 * Early initcalls run before initializing SMP.
 *
 * Only for built-in code, not modules.
 */
#define early_initcall(fn)		__define_initcall(fn, early)

/*
 * A "pure" initcall has no dependencies on anything else, and purely
 * initializes variables that couldn't be statically initialized.
 *
 * This only exists for built-in code, not for modules.
 * Keep main.c:initcall_level_names[] in sync.
 */
#define pure_initcall(fn)		__define_initcall(fn, 0)

#define core_initcall(fn)		__define_initcall(fn, 1)
#define core_initcall_sync(fn)		__define_initcall(fn, 1s)
#define postcore_initcall(fn)		__define_initcall(fn, 2)
#define postcore_initcall_sync(fn)	__define_initcall(fn, 2s)
#define arch_initcall(fn)		__define_initcall(fn, 3)
#define arch_initcall_sync(fn)		__define_initcall(fn, 3s)
#define subsys_initcall(fn)		__define_initcall(fn, 4)
#define subsys_initcall_sync(fn)	__define_initcall(fn, 4s)
#define fs_initcall(fn)			__define_initcall(fn, 5)
#define fs_initcall_sync(fn)		__define_initcall(fn, 5s)
#define rootfs_initcall(fn)		__define_initcall(fn, rootfs)
#define device_initcall(fn)		__define_initcall(fn, 6)
#define device_initcall_sync(fn)	__define_initcall(fn, 6s)
#define late_initcall(fn)		__define_initcall(fn, 7)
#define late_initcall_sync(fn)		__define_initcall(fn, 7s)
```

### 디바이스 드라이버 파일의 등록과정은 해당 디바이스 드라이버를 커널에 정적으로 링크할 것인지, 모듈로 적재할 것인지에 따라 차이가 있다.
1. 커널에 정적으로 링크하는 경우 
 module_init(x) define은 __initcall(x) 으로 정의되어 있어, __define_initcall("6", fn, 6)으로 대치되어 .initcall6.init 섹션에 등록됩니다.

```
#define device_initcall(fn)		__define_initcall(fn, 6)
#define __initcall(fn) device_initcall(fn)

#define module_init(x)	__initcall(x);
 ```

 2. 모듈로 컴파일되는 경우
 __inittest라는 static inline 함수를 정의하여 해당 디바이스 드라이버의 초기화 함수 포인터를 반환하도록 되어 있다. 
 그리고 init_module()이라는 함수를 __attriute__((alias)) 속성을 주어 정의한다.
 이 의미는 initfn 이라는 함수의 alias(별칭)fh init_module 함수를 정의함으로서, 디바이스 드라이버를 적재(insmod)시킬 때 
 공통적으로 init_module() 함수를 호출하여 해당 디바이스 드라이버의 함수가 호출되는 매커니즘이다. 

```

/* Each module must use one module_init(). */
#define module_init(initfn)					\
	static inline initcall_t __inittest(void)		\
	{ return initfn; }					\
	int init_module(void) __attribute__((alias(#initfn)));


 ```
