# Serial 

## block
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

