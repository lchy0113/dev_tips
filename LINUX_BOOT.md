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
