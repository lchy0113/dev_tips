Android-x86 
-----


# prepare

## install the following build dependencies 

```bash
sudo apt install -y build-essential libepoxy-dev libdrm-dev libgbm-dev libx11-dev libvirglrenderer-dev libpulse-dev libsdl2-dev libgtk-3-dev libsdl1.2-dev ninja-build
```

## download latest qemu sources using follow command

```bash
git clone https://git.qemu.org/git/qemu.git
```


## run qemu

```bash
./configure --enable-sdl --enable-opengl --enable-virglrenderer --enable-system --enable-modules --audio-drv-list=pa --target-list=x86_64-softmmu --enable-kvm --enable-gtk --enable-slirp --enable-debug
```


# make

```bash
make

sudo adduser (your user name) kvm

sudo chmod 666 /dev/kvm

sudo touch /lib/udev/rules.d/99-kvm.rules
// add line KERNEL=="kvm", GROUP="kvm", MODE="0666"
```


# install qemu-utils

```bash
sudo apt install qemu-utils
```

## cd to the directory where you want create the virtual hard disk

```bash
qemu-img create -f qcow2 Android.img 10G
```

## Download android-x86 image 
	url : https://www.android-x86.org/download

## cd to directory were u git cloned qemu

```bash
cd qemu/build/x86_64-softmmu/

// sample
qemu-system-x86_64 -boot d \
    -enable-kvm \
    -smp 2 \
    -cdrom "/path/to/android/iso" \
    -name linuz \
    -device virtio-vga,virgl=on,xres=1280,yres=720 \
    -cpu host \
    -device AC97 \
    -m 2048 \
    -display sdl,gl=on \
    -drive file=/path/to/android/Android.img,if=virtio \
    -object rng-random,id=rng0,filename=/dev/urandom \
    -device virtio-rng-pci,rng=rng0 \
    -device virtio-keyboard \
    -boot menu=off \
    -device virtio-tablet \
    -machine type=q35 \
    -serial mon:stdio \
    -net nic -net user,hostfwd=tcp::4444-:5555

```

```bash
qemu-system-x86_64 -boot d \
	-enable-kvm \
	-smp 2 \
	-cdrom "/home/lchy0113/Downloads/android-x86/android-x86_64-9.0-r2.iso" \
	-name linuz \
	-device virtio-vga-gl,xres=1280,yres=720 \
	-cpu host \ 
	-device AC97 \
	-m 2048 \
	-display sdl,gl=on \
	-drive file=/home/lchy0113/Private/qemu_related/android-x86/Android.img,if=virtio \
	-object rng-random,id=rng0,filename=/dev/urandom \
	-device virtio-rng-pci,rng=rng0 \
	-device virtio-keyboard \
	-boot menu=off \
	-device virtio-tablet \
	-machine type=q35  \
	-serial mon:stdio  \
	-net nic -net user,hostfwd=tcp::4444-:5555
```

## install android-x86 sdk 11
```bash
~/Private/qemu_related/qemu/build/x86_64-softmmu$ ./qemu-system-x86_64 -boot d -enable-kvm -smp 4 -cdrom "/home/lchy0113/Develop/android-x86/android_x86_64-11.iso" -name lunuz -device virtio-vga-gl,xres=1280,yres=720  -cpu host -m 4096 -display sdl,gl=on -drive file=/home/lchy0113/Develop/android-x86/Android-11.img,if=virtio -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 -device virtio-keyboard  -boot menu=off  -device virtio-tablet  -machine type=q35  -serial mon:stdio  -net nic -net user,hostfwd=tcp::4444-:5555

```

# boot

## boot directly to image 

```bash
qemu-system-x86_64 -boot c \
    -enable-kvm \
    -smp 2 \
    -name linuz \
	-device virtio-vga-gl,xres=1280,yres=720 \
    -cpu host \
    -device AC97 \
    -m 2048 \
    -display sdl,gl=on \
	-drive file=/home/lchy0113/Develop/android-x86/Android.img,if=virtio \
    -object rng-random,id=rng0,filename=/dev/urandom \
    -device virtio-rng-pci,rng=rng0 \
    -device virtio-keyboard \
    -boot menu=off \
    -device virtio-tablet \
    -machine type=q35 \
    -serial mon:stdio \
	-net nic -net user,hostfwd=tcp::4444-:5555
```
 - -qemu-system-x86_64 : the qemu computer emulator for PC 64-bit
 - -enable-kvm : the virtual machine. With this, your virtualization runs faster.
 - -smp 2 : determine to use 2 CPU cores intestad of 1.
 - -m 2048 : determine to use 2 GigaByte of RAM.
 - -net nic & -net user : -net 옵션을 이용해서 네트워크 카드를 설정한다. 네트워크 설정을 위해서는 2개의 -net 옵션을 이용해야 한다. 기본값은 -net nic -net user


## boot android-x86 sdk 11

```bash
./qemu-system-x86_64 -boot c -enable-kvm -smp 4 -name richgold -device virtio-vga-gl,xres=1280,yres=720 -cpu host -m 4096 -display sdl,gl=on -drive file=/home/lchy0113/Develop/android-x86/Android-11.img,if=virtio -object rng-random,id=rng0,filename=/dev/urandom  -device virtio-rng-pci,rng=rng0 -device virtio-keyboard -boot menu=off -device virtio-tablet -machine type=q35 -serial mon:stdio -net nic -net user,hostfwd=tcp::4444-:5555
```
</br>
</br>

-----

# network 구성

> study 하고 싶음. (https://www.qemu.org/docs/master/system/devices/net.html#)

## host 네트워크 상태 확인

 eno2 인터페이스를 사용.
```bash
eno2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.12  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::f84c:3dce:cacc:a8c7  prefixlen 64  scopeid 0x20<link>
        ether 04:d4:c4:e0:c7:77  txqueuelen 1000  (Ethernet)
        RX packets 197553  bytes 100214827 (100.2 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 560539  bytes 733269271 (733.2 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 128  base 0x9000
```

 routing 정보 확인

 > 192.168.0.0/24 로 들어오고 나가는 패킷이 라우팅 되어 있는것을 확인
```bash
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.0.1     0.0.0.0         UG    100    0        0 eno2
169.254.0.0     0.0.0.0         255.255.0.0     U     1000   0        0 eno2
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
172.22.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-d2983195817d
192.168.0.0     0.0.0.0         255.255.255.0   U     100    0        0 eno2
```
