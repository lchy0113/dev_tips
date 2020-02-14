MINICOM tip 
====

- MINICOM configuration.
```
$ cat /etc/minicom/minirc.richgold 
# Machine-generated file - use "minicom -s" to change parameters.
pu port             /dev/ttyUSB0
pu baudrate         115200
pu bits             8
pu parity           N
pu stopbits         1
pu rtscts           No
pu histlines        5000
pu linewrap         Yes
pu addcarreturn     Yes
```

- MINICOM COMMAND.
```
LOGDIR=/home/$(whoami)/Develop/Log

if [ ! -d $LOGDIR ]; then
	echo "...Make $LOGDIR".
	mkdir -p $LOGDIR
fi

sudo minicom -c on  -a on -C $LOGDIR/richgold_$(date '+%Y-%m-%d__%T').log nhn1033

```
