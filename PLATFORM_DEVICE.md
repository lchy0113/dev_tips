# PLATFORM DEVICE and DRIVER.
 플랫폼 디바이스는 리눅스 커널이 USB 또는 PCI 등과 같은 버스를 통해 동적으로 감지 할 수 없는 SOC(System-On-Chip)에 내장된 시스템 장치로 설명 할 수 있다. 

 커널은 플랫폼 디바이스 매커니즘을 제공하므로써 실제로 존재하는 하드웨어에 대해 알 수 있다. 
 이 글에서 플랫폼 디바이스의 커널 인터페이스에 대해 설명하며 디바이스 트리와의 통합을 위해 필요한 배경 자료가 될 수 있다.

## Platform drivers.
 플랫폼 디바이스는 struct platform_device 로 정의되며 <linux/platform_device.h>에서 찾을 수 있다. 이러한 장치는 가상 "플랫폼 버스"에 연결된 것으로 간주된다.
 따라서 플랫폼 디바이스의 드라이버는 플랫폼 버스에 등록해야 한다. 이 등록은 platform_driver 구조체를 통해 수행된다. 

```c
struct platform_driver {
	int (*probe)(struct platform_device *);
	int (*remove)(struct platform_device *);
	void (*shutdown)(struct platform_device *);
	int (*suspend)(struct platform_device *, pm_message_t state);
	int (*resume)(struct platform_device *);
	struct device_driver driver;
	const struct platform_device_id *id_table;
};
```
 *최소한 probe() 및 remove() 콜백을 제공*해야 하며, 다른 콜백은 전원 관리와 관련이 있으며 관련이 있는 경우 제공해야 한다.
 드라이버가 제공해야하는 다른 것은 버스 코드가 실제 장치를 드라이버에 바인딩하는 방법이다. 
 그 목적으로 사용할 수 있는 두가지 매커니즘이 있다. 첫 번째는 id_table 이다.
 id_table 구조체는 다음과 같다.

```c
struct platform_device_id {
	char name[PLATFORM_NAME_SIZE];
	kernel_ulong_t driver_data;
};
```

 ID 테이블이 있으면 플랫폼 버스는 새 플랫폼 디바이스의 드라이버를 찾을때 마다 이를 스캔한다. 
 장치 이름이 ID 테이블 항목의 이름과 일치하면 장치는 관리를 위해 드라이버에게 제공되며 일치하는 ID 테이블 항목에 대한 포인터도 드라이버에서 사용할 수 있다.
 ID 테이블을 제공하지 않는 경우, driver 필드에 드라이버 이름을 제공한다. 
 예를 들어, i2c-gpio 드라이버는 다음과 같은 플랫폼 디바이스로 설정된다. 

```c
static struct platform_driver i2c_gpio_driver = {
	.driver = {
		.name = "i2c-gpio",
		.owner = THIS_MODULE,
	},
	.probe = i2c_gpio_probe,
	.remove = __devexit_p(i2c_gpio_remove),
};
```

 이 설정을 통해 "i2c-gpio"로 식별되는 모든 장치가 이 드라이버에 바인딩 된다. 
 플랫폼 드라이버는 다음을 통해 반드시 자신을 커널에 알려야 한다.

```c
int platform_driver_register(struct platform_driver *driver);
```

 이 호출이 성공하면 드라이버의 probe() 함수가 호출 될 수 있다. 이 함수는 인스턴스화 할 장치를 설명하는 platform_device 포인터를 가져온다. 

```c
struct platform_device {
	const char *name;
	int id;
	struct device dev;
	u32 num_resoutces;
	struct resource *resource;
	const struct platform_device_id *id_entry;

	/* Others omitted */
};
```

 dev 필드는 필요한 상황 (예 : DMA 매핑 API) 에서 사용할 수 있다. 장치가 ID 테이블 항목을 사용하여 일치하면 id_entry 는 일치하는 항목을 가리킨다.
 resource 배열은 메모리 매핑된 I/O 레지스터 및 인터럽트를 포함한 다양한 리소스를 찾는데 사용할 수 있다. 
 리소스 배열에서 데이터를 가져오기위한 여러가지 도우미 함수가 있는데 다음은 몇가지 함수의 예를 보여준다.
```c
struct resource *platform_get_resource(struct platform_device *pdev, 
	unsigned int type, unsigned int n);

struct resource *platform_get_resource_byname(struct platform_device *pdev,
	unsigned int type, const char *name);

int platform_get_irq(struct platform_device *pdev, unsigned int n);
```

 "n"매개 변수는 index를 나타내며 0은 첫 번째 리소스를 나타낸다. 예를 들어 드라이버는 다음을 통해 두 번째 MMIO 영역을 찾을 수 있다.
```c
r = platform_get_resource(pdev, IORESOURCE_MEM, 1);
```


## Platform device.
 처음에 언급했듯이 플랫폼 디바이스는 본직적으로 검색 할 수 없으므로, 커널에 장치의 존재를 알리는 다른 방법이 있어야 한다.
 이는 일반적으로 관련 드라이버를 찾는 데 사용되는 정적 platform_device 구조체를 작성해야 한다. 
 예를 들어, 간단한 장치는 다음과 같이 설정 될 수 있다. 

```c
static struct resource foomatic_resources[] = {
{
	.start	= 0x10000000,
	.end	= 0x10001000,
	.flags	= IORESOURCE_MEM,
	.name	= "io-memory"
},
{
	.start	= 20,
	.end	= 20,
	.flags	= IORESOURCE_IRQ,
	.name	= "irq",
}
};

static struct platform_device my_foomatic = {
	.name	= "foomatic",
	.resource	= foomatic_resources,
	.num_resoutces	= ARRAY_SIZE(foomatic_resources),
};

 이 선언은 1페이지 MMIO 영역이 0x10000000 에서 시작하고 IRQ 20 을 사용하는 "foomatic"장치를 설명한다. 
 장치는 다음을 통해 시스템에 알린다.

```c
int platform_device_register(struct platform_device *pdev);
```

 플랫폼 디바이스와 관련 드라이버가 모두 등록되면 드라이버의 probe() 함수가 호출되고 장치가 인스턴스화된다.
 플랫폼 디바이스를 제거하려면 platform_device_unregister() 함수를 사용한다.

## Platform data
 위의 정보는 간단한 플랫폼 디바이스를 인스턴스화하는 데 적합하지만 사실 많은 장치들이 그보다 복잡하다. 
 위에서 설명한 간단한 i2c-gpio 드라이버조차도 i2c클럭으로 사용되는 GPIO 라인 수와 데이터 라인이라는 두 가지 추가 정보가 필요하다.
 이 정보를 전달하는 데 사용하는 게 "platform data"이다. 
 간단히 말해서 필요한 특정 정보를 포함하는 자료구조를 정의하고 이를 플랫폼 디바이스의  dev.platform_data 필드에 전달한다.

 i2c-gpio 예제에서 platform_data 구성은 다음과 같다.
```c
static struct i2c_gpio_platform_data my_i2c_plat_data = {
	.scl_pin = 100,
	.sda_pin = 101,
};

static struct platform_device my_gpio_i2c = {
	.name = "i2c-gpio",
	.id = 0,
	.dev = {
		.platform_data = &my_i2c_plat_data,
	}
};
```

 드라이버의 probe() 함수가 호출되면 Platform_data포인터를 가져와서 필요한 나머지 정보를 얻는데 사용할 수 있다. 

-----
* reference :
  - https://makersweb.net/embedded/17478
  - https://lwn.net/Articles/448499/

