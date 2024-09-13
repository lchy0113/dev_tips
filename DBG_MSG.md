linux kernel debug message 
====

dev_dbg 는 linux kernel 드라이버에서 디버그 메시지를 출력하는 함수.   
이 함수를 활성화 시키려면 아래 단계를 거쳐야 함.   


<br/>
<br/>
<br/>
<hr>
  
1. CONFIG_DYNAMIC_DEBUG 설정 확인

 - 커널이 *CONFIG_DYNAMIC_DEBUG* 옵션으로 컴파일 되었는지 확인.  
   이 옵션은 dynamic debug 를 활성화하는데 필요.  
 - 커널에서 아래 명령어 입력으로 확인.  
```bash
# cat /proc/config.gz | gunzip | grep DYNAMIC_DEBUG
CONFIG_DYNAMIC_DEBUG=y

or 

# cat /proc/config.gz | gunzip | grep CONFIG_DYNAMIC_DEBUG 
# CONFIG_DYNAMIC_DEBUG is not set
```
 - 설정되지 않은 경우, CONFIG_DYNAMIC_DEBUG=y 로 다시 컴파일.  

<br/>
<br/>
<br/>

2. debugfs 마운트 확인. 

 - debugfs 가 어느 노드에 mount되어 있는지 확인해야함.  
  대부분 */sys/kernel/debug* 에 마운트 됨.  
 
 - 터미널에서 아래 명령을 실행하여 확인.  
```bash
# mount | grep debugfs
debugfs on /sys/kernel/debug type debugfs (rw,seclabel,relatime,mode=755)
```

 - 마운트 되어 있지않다면 수동으로 마운트.  
```bash
mount -t debugfs none /sys/kernel/debug
```

<br/>
<br/>
<br/>

3. 드라이버 파일 활성화.  
  
  - 원하는 드라이버파일에 대한 dev_dbg() 로그 활성화.  
  - 터미널에서 다음 명령을 실행하여 활성화.  
	  <driverfilename.c> 는 실제 드라이버 파일 이름으로 대체.  

```bash
echo 'file <driverfilename.c> +p' > /sys/kernel/debug/dynamic_debug/control
```

 - 만약 소스파일 'svcsock.c' 의 1603 라인 출력 디버깅 켜기를 원하다면 아래와 같이 입력.  
```bash
echo 'file svcsock.c line 1603 +p' > /sys/kernel/debug/dynamic_debug/control

```


 - e.g
```bash
echo 'file vcnl4000.c +p' > /sys/kernel/debug/dynamic_debug/control

 # cat /sys/kernel/debug/dynamic_debug/control | grep vcnl
drivers/iio/light/vcnl4000.c:328 [vcnl4000]vcnl4000_probe =p "%s Ambient light/proximity sensor, Rev: %02x\012"
drivers/iio/light/vcnl4000.c:130 [vcnl4000]vcnl4200_init =p "device id 0x%x"
```
 
 - echo 'file <driverfilename.c> +p' > /sys/kernel/debug/dynamic_debug/control   
   명령은 Linux 커널에서 dev_dbg 디버그 메시지를 활성화 하는데 사용.  

   * echo : linux shell에서 text를 출력하는 명령. 
   * 'file <driverfilename.c> +p' : 활성화 하는 드라이버 파일 이름 지정. 
   * > : 리다이렉션 연산자.  
   * /sys/kernel/debug/dynamic_debug/control : dynamic_debug 인터페이스 경로 .  


 - change operation 

```bash
-    remove the given flags
+    add the given flags
=    set the flags to the given flags
```

 - the flags 

```bash
p    enables the pr_debug() callsite
f    include the function name in the printed message
l    include line number in the printed message
m    include module name in the printed message
t    include thread id in messages not generated from interrupt context
_    no flags are set. 
```


 - Debug message during Boot Process

 부팅 중, debug messages를 활성화 하기 위해선, **dyndbg="QUERY" 를 사용한다. 

 "modprobe foo" 모듈이 호출 될 때, modprobe는 foo.params를 위해 /proc/cmdline을 스캔한다.

```bash
#########
## for ps_vcnl4200 module
dyndbg="file drivers/input/sensors/psensor/ps_vcnl4200.c +p"

setenv bootargs 'storagemedia=emmc androidboot.storagemedia=emmc androidboot.mode=normal  androidboot.dtb_idx=0 androidboot.dtbo_idx=0 dyndbg="file drivers/input/sensors/psensor/ps_vcnl4200.c +p"'

#########
## for ak7755 module
dyndbg="file sound/soc/codecs/ak7755.c +p"

setenv bootargs 'storagemedia=emmc androidboot.storagemedia=emmc androidboot.mode=normal  androidboot.dtb_idx=0 androidboot.dtbo_idx=0 dyndbg="file sound/soc/codecs/ak7755.c +p"
```

 커널 로그에서 확인하지 못한다면 아래 명령어 수행.  
```bash
echo "8 4 1 7" > /proc/sys/kernel/printk
```
