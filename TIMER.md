TIMER 
=====

linux커널에서는 jiffies라는 글로벌 변수를 이용하여 측정하며, 이 변수는 시스템 부팅 이후에 tick 수를 식별한다.  
tick 수를 계산하는 방법은 최저 레벨인 실행 중인 특정 하드웨어 플랫폼에 따라 달라지지만, 일반적으로 tick은 interrupt을 통해 증가한다.  
틱 속도(jiffies의 최하위 비트)는 구성가능 하지만 x86 용 2.6 커널의 경우 1 tick이 4 ms  (250 Hz)  이다.  
jiffies 글로벌 변수는 커널 내에서 다양한 용도로 널리 사용되고 있으며, 대표적으로 timer의 제한시간 값을 계산하기 위해 현재 절대 시간에 사용된다.  

# kernel timer

커널의 timer에는 몇가지 다양한 스키마가 잇다. timer API가 대부분의 경우에 적합하기는 하지만 모든 timer 중에서 가장 단순하고 정확성이 낮다.  
이 API를 사용하면 jiffies 도메인(최소 4 ms 제한시간) 에서 작동하는 timer를 생성할 수 있다.   
또한 시간이 나노초 단위로 정의되는 timer를 생성할 수 있는 고분해능 타이머(high-resolution timer) API 도 있다.  
프로세서 및 그 작동 속도에 따라서 성능의 차이가 있을 수 있지만 이 API 를 사용하면 제한시간을 jiffies tick 간격 이하로 스케줄링 할 수 있다.  

# 표준 timer

표준 timer API는 linux 커널의 초기 버전 부터 오랫동안 linux 커널에 포함되어 있었다.  
고분해능 timer(high-resolution timer)에 비해 정확도가 떨어지기는 하지만 실제 장치를 처리할 때 발생하는 오류 케이스를 처리하는데 사용되는 일반적인 드라이버 제한시간에 이상적이다.  
이러한 제한시간은 실제로 초과되는 경우도 많지 않으며 대부분의 경우 시작되었다가 제거되는 형태를 보인다.  

# timer API

Linux에는 timer의 생성과 관리를 위한 간단한 API가 있다.  
이 API는 timer 작성, 취소 및 관리를 위한 함수(및 헬퍼 함수)로 구성되어 있다.  

timer는 timer_list 구조체로 정의되며, 이 구조체에는 타이머 구현에 필요한 모든 데이터(컴파일 시 구성되는 선택적 타이머 통계 및 목록 포인터 포함).  
사용자의 관점에서 볼 경우, timer_list에는 만기 시간, 콜백 함수(timer의 만기 시간/여부) 및 사용자 제공 컨텍스트가 있다.  
그런 다음 사용자는 timer를 초기화해야 한다.  
초기화는 몇 가지 방법으로 수행할 수 있다. 가장 간단한 방법은 setup_timer를 호출하는 것이다.  
이 함수는 timer를 초기화하고 사용자 제공 콜백 함수 및 컨텍스트를 설정한다.   
이 함수를 사용하지 않을 경우에는 사용자가 timer에서 이러한 값(함수 및 데이터)을 설정하고 init_timer를 호출할 수 있다.  
init_timer는 setup_timer에서 내부적으로 호출된다.

```c
void init_timer( struct timer_list *timer );
void setup_timer( struct timer_list *timer,

void (*function)(unsigned long), unsigned long data );
```

timer를 초기화한 후에는 사용자가 mod_timer를 호출하여 만기 시간을 설정해야 한다.  
일반적으로 만기 시간은 미래이므로 여기에서는 jiffies를 추가하여 현재 시간을 기준으로 하는 오프셋을 설정한다.   
사용자는 del_timer를 호출하여 timer를 삭제할 수도 있다(만기되지 않은 경우).  

```c
int mod_timer( struct timer_list *timer, unsigned long expires );
void del_timer( struct timer_list *timer );
```

마지막으로 사용자는 timer_pending을 호출하여 timer가 아직 만기되지 않고 보류 중인지 여부를 확인할 수 있다(타이머가 보류 중이면 1이 리턴됨).  

```c
int timer_pending(const struct timer-list *timer);
```

## timer 예제

```c

/**
  * init_module 에서 setup_timer를 사용하여 timer를 초기화 한다음, 
  * mod_timer를 호출하여 timer를 시작한다. 
  * timer가 만료되면 callback 함수(my_timer_callback)가 호출된다. 
  * 마지막으로 모듈을 제거하면 del_timer를 통해 timer가 삭제된다.
  * del_timer의 리턴값을 검사하여 timer가 사용중인지 여부를 식별한다.
  */
#include <linux/kernle.h>
#include <linux/module.h>
#include <linux/timer.h>

static struct timer_list my_timer;

void my_timer_callback(unsigned long data)
{
	printk("my_timer_callback (%ld).\n", jiffies);
}

int init_module(void)
{
	int ret;
	printk("timer module installing\n");

	// my_timer.function, my_timer.data
	setup_timer(&my_timer, my_timer_callback, 0);

	printk("starting timer to fire in 200ms (%ld)\n", jiffies);
	ret = mod_timer(&my_timer, jiffies + msecs_to_jiffies(200));
	if (ret)
		printk("error in mod_timer\n");

	return 0;
}

void cleanup_module(void)
{
	int ret;

	ret = del_timer(&my_timer);
	int (ret) 
		printk("the timer is still in use...\n");

	return;
}

```

# 고분해능 timer(high-resolution timers)

고분해능 timer(또는 hrtimer)는 앞에서 설명한 timer 프레임워크와는 독립된 고정밀 timer 관리 프레임워크를 제공한다.  
이는 두 프레임워크를 병합하기가 복잡하기 때문이다.  
**mer는 jiffies 단위로 작동하는 반면, hrtimer는 나노초 단위로 작동한다.**

hrtimer 프레임워크는 일반적인 timer API와 다르게 구현된다.   
버켓 및 timer Cascading 대신 hrtimer는 timer로 구성된 시간순 데이터 구조를 관리한다.   
(활성 시간에 처리 시간을 최소화하기 위해 timer가 시간순으로 삽입된다.  
이 프레임워크에 사용되는 데이터 구조는 레드-블랙 트리이다.  
이 트리는 성능에 중점을 둔 애플리케이션에 이상적이며 일반적으로 커널 내의 라이브러리로 사용할 수 있다.  

hrtimer 프레임워크는 커널 내에서 API로 사용할 수 있으며, nanosleep, itimers 및 POSIX(Portable Operating System Interface timer 인터페이스를 통해 사용자 공간 애플리케이션에서도 사용 가능된다.  
(이 프레임워크는 커널 버전 2.6.21  에 포함되었다.)  

# 고분해능 timer API

hrtimer API에는 기존 API와 유사한 점도 있지만 추가적인 시간 제어를 위해 몇 가지 근본적인 차이점도 있다.  
첫 번째 차이점은 시간이 jiffies가 아닌 ktime이라는 특수 데이터 유형으로 표시된다는 것이다.  
이 표시는 이 단위에서의 효율적인 시간 관리와 관련된 일부 세부 사항을 숨긴다.  
이 API 는 절대 시간과 상대 시간을 구별하므로 호출자가 유형을 지정해야 한다.  

기존 timer API와 마찬가지로 hrtimer도 구조체로 표현된다  
이 구조체는 사용자 관점(콜백함수, 만기시간 등) 에서 timer 를 정의하고 관리 정보를 통합한다.  
(이 경우에는 timer가 레드-블랙 트리, 선택적 통계 등에 존재한다.)  

먼저 hrtimer_init을 통해 timer가 초기화 된다.  
이 호출은 timer, clock 정의 및 timer 모드(일회성 또는 다시 시작) 를 포함한다.  
사용할 clock은 ./include/linux/time.h 에 정의되어 있으며 시스템에서 지원하는 다양한 clock을 나타낸다.  
(예 : 실시간 clock 또는 시스템 시동 과 같은 시작 시점의 시간을 나타내는 모노 clock)  
초기화된 timer는 hrtimer_start를 사용하여 시작 할 수 있다. 
이 호출은 만기 시간(ktime_t) 및 시간 모드 값(절대 값 또는 상대 값)을 포함한다.  

```c
void hrtimer_init(struct hrtimer *time, clockid_t which_clock, enum hrtimer_mode mode);

int hrtimer_start(struct hrtimer *timer, ktime_t time, const enum hrtimer_mode mode);
```

hrtimer를 시작한 후에는 hrtimer_cancel 또는 hrtimer_try_to_cancel을 호출하여 취소 할 수 있다.  
각 함수에는 중지할 timer에 대한 hrtimer 참조가 들어있다.  
두 함수의 차이점은 다음과 같다.  
hrtimer_cancel 함수는 timer를 취소하려고 시도한다.   하지만 timer 가 이미 시작되었으면 callback함수가 종료 될 때까지 기다린다.  
이에 반해  hrtimer_try_to_cancel 함수는 timer를 취소하려고 시도할 때 timer가 이미 시작되었으면 오류를 리턴한다.  

```c
int hrtimer_cancel(struct hrtimer *timer);
int hrtimer_try_to_cancel(struct hrtimer *timer);
```

hrtimer_callback_running 을 호출하여 hrtimer가 해당 callback을 활성화 했는지 여부를 확인 할 수 있다.  
이 함수는 callback 함수가 호출되었을 때 오류를 리턴하기 위해 hrtimer_try_to_cancel 에 의해 내부적으로 호출된다.  

```c
int hrtimer_callback_running(struct hrtimer *timer);
```

## hrtimer 예제

```c
/**
  * init_module내에서 상대적인 제한시간(이 경우에는 200ms)을 정의하여 시작할 수 있다. 
  * hrtimer_init 호출을 사용하여 hrtimer를 초기화한(모노 클록 사용) 다음 callback 함수를 설정한다.
  * 마지막으로 앞에서 작성한 ktime 값을 사용하여 timer를 시작한다. 
  * timer가 시작되면 my_hrtimer_callback 함수가 호출되면서 HRTIMER_NORESTART를 리턴한다. 
  * 따라서 timer가 자동으로 시작되지 않는다. 
  * cleanup_module함수에서 hrtimer_cancel을 사용하여 timer를 취소하면서 정리한다.
  */
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/hrtimer.h>
#include <linux/ktime.h>

#define MS_TO_NS(x)	(x * 1E6L)


static struct hrtimer hr_timer;

enum hrtimer_restart my_hrtimer_callback(struct hrtimer *timer)
{
	printk("my_hrtimer_callback called (%ld).\n", jiffies);

	return HRTIMER_NORESTART;
}

init init_module(void)
{
	ktime_t ktime;
	unsigned long delay_in_ms = 200L;

	printk("hrtimer module installing\n");

	ktime = ktime_set(0, MS_TO_NS(delay_in_ms));

	hrtimer_init(&hr_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);

	hr_timer.function = &my_hrtimer_callback;

	printk("starting timer to fire in %ldms (%ld)\n", delay_in_ms, jiffies);

	hrtimer_start(&hr_timer, ktime, HRTIMER_MODE_REL);

	return 0;
}


void cleanup_module(void)
{
	int ret;

	ret = hrtimer_cancel(&hr_timer);
	if (ret)
		printk("the timer was wtill in use ...\n");

	printk("hrtimer module uninstalling\n");

	return;
}

```
