# Serial 

## serial_core, uart_driver, serial_console
> BUG_ON(in_interrupt()); // 이 구문이 인터럽트 핸들러 안에서 수행하면 BUG!!

uart ip device driver는 커널에서 drivers/tty/serial/ 에서 존재하게 되고, 
상위 framework는 serial_core.c입니다.
drivers/tty/serial/ 는 serial_core kernel framework와 hw device driver가 존재하게 됩니다. 
보통 serial_core.o + uart_ip_device_driver.o 조합으로 구성되어 있습니다.

serial_core는 자기에에게 등록 될 수 있는 함수 uart_register_driver와 uart_add_one_port를 제공합니다.

### uart_register_driver 함수 #1
uart_register_driver함수 struct uart_driver구조체를 매개 변수로 받습니다.
구조체 내용은 <첨부1>을 참고합니다.

uart_register_driver의 주석 내용을 확인하면, 
<uart driver(hw)를 core driver(serial_core)에 등록한다. 
이 함수 안에서 tty layer에 등록하고 core driver를 초기화 한다.
normal driver(tty layer)등록 이후, /proc/tty/driver/"named"를 가진다.
(named는 uart driver(hw) name으로 정해 지는 것으로 보임)
struct uart_driver->port는 NULL이어야만 한다. 
uart_register_driver 함수 호출 이후에 uart_add_one_port를 호출 하여 
각 port 구조체가 등록 될 것이다.>

정리하면, uart_register_driver함수는 serial_core에서 제공해 주는 함수로
struct tty_driver를 생성하여 tty layer에 등록하도록 도와주는 함수 입니다.

```bash
+----------------------------------------------+
| tty layer <-> serial_core <-> hw uart driver |
+----------------------------------------------+
```

또 다른 의미로는 hw uart driver가 가진 struct uart_driver 구조체를 
초기화 하는 것으로도 설명 할 수 있습니다.
왜냐하면 이 초기화된 struct uart_drvier 구조체를 이용하여
uart_add_oe_port 함수를 호출하여 hw uart driver가 가지고 있는 
struct uart_port를 등록 할 수 있기 때문 입니다.
(즉, uart_port를 등록하기 위한 key입니다. )

### uart_register_driver 함수 #2
소스레벨에서 분석해보면, 
```c
int uart_register_driver(struct uart_driver *drv) drivers/tty/serial/serial_core.c
	|
	+-> */
		struct tty_driver *normal 을 alloc_tty_driver(drv->nr) 를 이용하여 생성. 
		drv->nr 은 hw uart driver의 hw 개수 혹은 (=port 개수 = ip)
		drv->tty_driver = normal; 수행하여 hw uart driver 가 생성한 tty driver를 가르키도록 하고,
		drv->state에 memory alloc하여 struct uart_state도 만들어 준다. (drv->nr 개수 만큼)
		normal->driver_name	= drv->driver_name;
		normal->name		= drv->dev_name;
		normal->major		= drv->major;
		normal->minor_start	= drv->minor;
		normal->type		= TTY_DRIVER_TYPE_SERIAL;
		normal->subtype		= SERIAL_TYPE_NORMAL;
		normal->init_termios	= tty_std_termios;
		normal->init_termios.c_cflag = B9600 | CS8 | CREAD | HUPCL | CLOCAL;
		normal->init_termios.c_ispeed = normal->init_termios.c_ospeed = 9600;
		normal->flags		= TTY_DRIVER_REAL_RAW | TTY_DRIVER_DYNAMIC_DEV;
		normal->driver_state    = drv;
		위와 같이 수행하고, 
		tty_set_operations(normal, &uart_ops);를 수행하여, 
		serial_core.c 내부에 있는 uart_ops를 tty_driver->ops에 연결 한다.
		uart_ops를 <첨부2>를 참고한다. 
		uart_ops는 대부분 struct uart_port의 ops 함수를 호출한다. 
		struct uart_port의 ops는 hw uart driver에서 선언되어 있으면 hw를 control하는 코드 이다. 

		for (i = 0; i < drv->nr; i++) {
			struct uart_state *state = drv->state + i;
			struct tty_port *port = &state->port;

			tty_port_init(port);
			port->ops = &uart_port_ops;
			port->close_delay     = HZ / 2;	/* .5 seconds */
			port->closing_wait    = 30 * HZ;/* 30 seconds */
		}

		drv->nr 개수 만큼 반복하여 tty_port_init 함수를 호출하여 port를 init하는데 매개변수는 
		struct tty_port 이다.
		struct tty_port는 위에서 생성한 state(struct uart_state)그조체 안에 있는 port이다.
		struct uart_state->port <첨부1-1> 참고한다.

		tty_port_init 함수의 주 역할은 tty_port 구조체의 값을 초기화 하는 역할이고,
		port->ops가 중요하다. 여기에 uart_port_ops를 연결하는데 <첨부2-1>
		이 이후, tty_register_driver(normal);를 호출하여 tty_layer에 등록한다. 
		tty_register_driver 안에서 character driver를 등록한다.
		이로써 매개변수 struct uart_driver *drv는 초기화 되었다. 
		struct uart_driver *drv는 hw uart driver 에서 static으로 가지고 있다.
		*/
```

```bash
+------------------------------------------------------------------------------+
|                                                                              |
|    +-------------------+                                                     |   
| +->|struct tty_driver  |                                                     |   
| |  |                   |                                                     |   
| |  |                   |                                                     |   
| |  |  driver_state ----+--> +------------------+                             |   
| |  |                   |    |struct uart_driver|       +------------------+  |
| |  +-------------------+    |                  |  +--> |struct console    |  |        
| +---------------------------+-- tty_driver     |  |    |                  |  |
|                +------------+-- state          |  |    |                  |  |
|    	         |            |   con -----------+--+    +------------------+  |  
|                |            +------------------+                             |
|                |                                                             |
|                |                                                             |
|                +--->  +-------------------------+[0]                         |
|                       |struct uart_state(0)     |                            |
|                       |tty_port(st tty_port)    |      +------------------+  |
|                       |uart_port(st uart_port) -+--->  |struct uart_port  |  |
|                       +-------------------------+      +------------------+  |
|                       +-------------------------+[1]                         |
|                       |struct uart_state(1)     |                            |
|                       |tty_port(st tty_port)    |      +------------------+  |
|                       |uart_port(st uart_port) -+--->  |struct uart_port  |  |
|                       +-------------------------+      +------------------+  |
|                       +-------------------------+[2]                         |
|                       |struct uart_state(2)     |                            |
|                       |tty_port(st tty_port)    |      +------------------+  |
|                       |uart_port(st uart_port) -+--->  |struct uart_port  |  |
|                       +-------------------------+      +------------------+  |
|                       +------------------------ +[3]                         |
|                       |struct uart_state(3)     |                            |
|                       |tty_port(st tty_port)    |      +------------------+  |
|                       |uart_port(st uart_port) -+--->  |struct uart_port  |  |
|                       +-------------------------+      +------------------+  |            
+------------------------------------------------------------------------------+
```
위 그림은 구조체 개념도 입니다. 
struct tty_driver가 user space와 담당하는 모듈이고, 
struct uart_driver가 hw driver를 호출하고 등록/제거 하며,  tty_driver와 유기적으로 동작합니다.

struct uart_driver, struct console, struct uart_port 이 3 구조체는 hw uart driver에서 static변수로 가지고 등록되는 형식이고, 
struct tty_driver, struct uart_state(struct tty_port) 이 2 구조체는 uart_register_driver함수를 호출하면 동적으로 생성됩니다.


### uart_add_one_port 함수 #1
소스 레벨에서 분석해보면
```c
int uart_add_one_port(struct uart_driver 8drv, struct uart_port *uport) drivers/tty/serial/serial_core.c
```

<첨부1>-start
```c
struct uart_driver {
	struct module		*owner;
	const char		*driver_name;
	const char		*dev_name;
	int			 major;
	int			 minor;
	int			 nr;
	struct console		*cons;

	/*
	 * these are private; the low level driver should not
	 * touch these; they should be initialised to NULL
	 */
	struct uart_state	*state;
	struct tty_driver	*tty_driver;
};


```
<첨부1>-end


<첨부1-1>-start
```c
struct uart_state {
	struct tty_port		port;

	enum uart_pm_state	pm_state;
	struct circ_buf		xmit;

	struct uart_port	*uart_port;
};

```
<첨부1-1>-end


<첨부2>-start
```c
struct uart_ops {
	unsigned int	(*tx_empty)(struct uart_port *);
	void		(*set_mctrl)(struct uart_port *, unsigned int mctrl);
	unsigned int	(*get_mctrl)(struct uart_port *);
	void		(*stop_tx)(struct uart_port *);
	void		(*start_tx)(struct uart_port *);
	void		(*throttle)(struct uart_port *);
	void		(*unthrottle)(struct uart_port *);
	void		(*send_xchar)(struct uart_port *, char ch);
	void		(*stop_rx)(struct uart_port *);
	void		(*enable_ms)(struct uart_port *);
	void		(*break_ctl)(struct uart_port *, int ctl);
	int		(*startup)(struct uart_port *);
	void		(*shutdown)(struct uart_port *);
	void		(*flush_buffer)(struct uart_port *);
	void		(*set_termios)(struct uart_port *, struct ktermios *new,
				       struct ktermios *old);
	void		(*set_ldisc)(struct uart_port *, int new);
	void		(*pm)(struct uart_port *, unsigned int state,
			      unsigned int oldstate);
	void		(*wake_peer)(struct uart_port *);

	/*
	 * Return a string describing the type of the port
	 */
	const char	*(*type)(struct uart_port *);

	/*
	 * Release IO and memory resources used by the port.
	 * This includes iounmap if necessary.
	 */
	void		(*release_port)(struct uart_port *);

	/*
	 * Request IO and memory resources used by the port.
	 * This includes iomapping the port if necessary.
	 */
	int		(*request_port)(struct uart_port *);
	void		(*config_port)(struct uart_port *, int);
	int		(*verify_port)(struct uart_port *, struct serial_struct *);
	int		(*ioctl)(struct uart_port *, unsigned int, unsigned long);
#ifdef CONFIG_CONSOLE_POLL
	int		(*poll_init)(struct uart_port *);
	void		(*poll_put_char)(struct uart_port *, unsigned char);
	int		(*poll_get_char)(struct uart_port *);
#endif
};

```
<첨부2>-end


<첨부2-1>-start
```c
static const struct tty_port_operations uart_port_ops = {
	.activate	= uart_port_activate,
	.shutdown	= uart_port_shutdown,
	.carrier_raised = uart_carrier_raised,
	.dtr_rts	= uart_dtr_rts,
};
```
<첨부2-1>-end


<첨부2-2>-start
```c
struct uart_port {
	spinlock_t		lock;			/* port lock */
	unsigned long		iobase;			/* in/out[bwl] */
	unsigned char __iomem	*membase;		/* read/write[bwl] */
	unsigned int		(*serial_in)(struct uart_port *, int);
	void			(*serial_out)(struct uart_port *, int, int);
	void			(*set_termios)(struct uart_port *,
				               struct ktermios *new,
				               struct ktermios *old);
	int			(*startup)(struct uart_port *port);
	void			(*shutdown)(struct uart_port *port);
	void			(*throttle)(struct uart_port *port);
	void			(*unthrottle)(struct uart_port *port);
	int			(*handle_irq)(struct uart_port *);
	void			(*pm)(struct uart_port *, unsigned int state,
				      unsigned int old);
	void			(*handle_break)(struct uart_port *);
	unsigned int		irq;			/* irq number */
	unsigned long		irqflags;		/* irq flags  */
	unsigned int		uartclk;		/* base uart clock */
	unsigned int		fifosize;		/* tx fifo size */
	unsigned char		x_char;			/* xon/xoff char */
	unsigned char		regshift;		/* reg offset shift */
	unsigned char		iotype;			/* io access style */
	unsigned char		unused1;

#define UPIO_PORT		(0)
#define UPIO_HUB6		(1)
#define UPIO_MEM		(2)
#define UPIO_MEM32		(3)
#define UPIO_AU			(4)			/* Au1x00 and RT288x type IO */
#define UPIO_TSI		(5)			/* Tsi108/109 type IO */

	unsigned int		read_status_mask;	/* driver specific */
	unsigned int		ignore_status_mask;	/* driver specific */
	struct uart_state	*state;			/* pointer to parent state */
	struct uart_icount	icount;			/* statistics */

	struct console		*cons;			/* struct console, if any */
#if defined(CONFIG_SERIAL_CORE_CONSOLE) || defined(SUPPORT_SYSRQ)
	unsigned long		sysrq;			/* sysrq timeout */
#endif

	/* flags must be updated while holding port mutex */
	upf_t			flags;

#define UPF_FOURPORT		((__force upf_t) (1 << 1))
#define UPF_SAK			((__force upf_t) (1 << 2))
#define UPF_SPD_MASK		((__force upf_t) (0x1030))
#define UPF_SPD_HI		((__force upf_t) (0x0010))
#define UPF_SPD_VHI		((__force upf_t) (0x0020))
#define UPF_SPD_CUST		((__force upf_t) (0x0030))
#define UPF_SPD_SHI		((__force upf_t) (0x1000))
#define UPF_SPD_WARP		((__force upf_t) (0x1010))
#define UPF_SKIP_TEST		((__force upf_t) (1 << 6))
#define UPF_AUTO_IRQ		((__force upf_t) (1 << 7))
#define UPF_HARDPPS_CD		((__force upf_t) (1 << 11))
#define UPF_LOW_LATENCY		((__force upf_t) (1 << 13))
#define UPF_BUGGY_UART		((__force upf_t) (1 << 14))
#define UPF_NO_TXEN_TEST	((__force upf_t) (1 << 15))
#define UPF_MAGIC_MULTIPLIER	((__force upf_t) (1 << 16))
/* Port has hardware-assisted h/w flow control (iow, auto-RTS *not* auto-CTS) */
#define UPF_HARD_FLOW		((__force upf_t) (1 << 21))
/* Port has hardware-assisted s/w flow control */
#define UPF_SOFT_FLOW		((__force upf_t) (1 << 22))
#define UPF_CONS_FLOW		((__force upf_t) (1 << 23))
#define UPF_SHARE_IRQ		((__force upf_t) (1 << 24))
#define UPF_EXAR_EFR		((__force upf_t) (1 << 25))
#define UPF_BUG_THRE		((__force upf_t) (1 << 26))
/* The exact UART type is known and should not be probed.  */
#define UPF_FIXED_TYPE		((__force upf_t) (1 << 27))
#define UPF_BOOT_AUTOCONF	((__force upf_t) (1 << 28))
#define UPF_FIXED_PORT		((__force upf_t) (1 << 29))
#define UPF_DEAD		((__force upf_t) (1 << 30))
#define UPF_IOREMAP		((__force upf_t) (1 << 31))

#define UPF_CHANGE_MASK		((__force upf_t) (0x17fff))
#define UPF_USR_MASK		((__force upf_t) (UPF_SPD_MASK|UPF_LOW_LATENCY))

	/* status must be updated while holding port lock */
	upstat_t		status;

#define UPSTAT_CTS_ENABLE	((__force upstat_t) (1 << 0))
#define UPSTAT_DCD_ENABLE	((__force upstat_t) (1 << 1))

	int			hw_stopped;		/* sw-assisted CTS flow state */
	unsigned int		mctrl;			/* current modem ctrl settings */
	unsigned int		timeout;		/* character-based timeout */
	unsigned int		type;			/* port type */
	const struct uart_ops	*ops;
	unsigned int		custom_divisor;
	unsigned int		line;			/* port index */
	resource_size_t		mapbase;		/* for ioremap */
	struct device		*dev;			/* parent device */
	unsigned char		hub6;			/* this should be in the 8250 driver */
	unsigned char		suspended;
	unsigned char		irq_wake;
	unsigned char		unused[2];
	struct attribute_group	*attr_group;		/* port specific attributes */
	const struct attribute_group **tty_groups;	/* all attributes (serial core use only) */
	void			*private_data;		/* generic platform data pointer */
};
```
<첨부2-2>-end


<첨부3-1>-start
```c

```
<첨부3-1>-end

## block
```bash
+------------------------------------------------+
|                                                |
|                                                |
|                                                |
|                    (rxd)    (txd)    (txen)    | 
|                      |        |        |       |
|                     (R)      (D)   (DE)(RE)    |
| ZT485LEEN            +---+----+---+----+       |
|                          |        |            |
|                       (485_a)  (485_b)         |
|                          |        |            |
+------------------------------------------------+
```



## reference code
drivers/tty/serial/atmel_serial.c

```dts
RS485 example for Atmel USART:
	usart0: serial@fff8c000 {
		compatible = "atmel,at91sam9260-usart";
		reg = <0xfff8c000 0x4000>;
		interrupts = <7>;
		atmel,use-dma-rx;
		atmel,use-dma-tx;
		linux,rs485-enabled-at-boot-time;
		rs485-rts-delay = <0 200>;		// in milliseconds
	};

```


- linux device code
 * ha_driver : ssh://git@git.kdiwin.com:7999/teamhnrnd/ha_driver.git
 * kernel : ssh://git@git.kdiwin.com:7999/teamhnrnd/tcc892x-bsp.git
 			|
			+-> LINUX_TCC8925_BB_BSP_130906_R1444_homenet/linux/kernel/drivers/tty/serial/tcc_serial.c
			


- review code(tcc8985)

```c
static int __init pl011_init(void)	drivers/tty/serial/amba-pl011.c

```


```c
static void uart_start(struct tty_struct *tty) drivers/tty/serial/serial_core.c
	|
	+-> static voi dpl011_start_tx(struct uart_port *port)	drivers/tty/serial/amba-pl011.c  

```



[2022-07-28 10:35:10.792] [   71.936435] uart_write(652)
[2022-07-28 10:35:10.792] [   71.939318] uart_flush_chars(569)