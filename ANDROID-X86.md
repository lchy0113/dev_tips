Android-x86 
-----


# prepare

 - install the following build dependencies 

```bash
sudo apt install -y build-essential libepoxy-dev libdrm-dev libgbm-dev libx11-dev libvirglrenderer-dev libpulse-dev libsdl2-dev libgtk-3-dev libsdl1.2-dev ninja-build
```

 - download latest qemu sources using follow command

```bash
git clone https://git.qemu.org/git/qemu.git
```


 - run qemu

```bash
./configure --enable-sdl --enable-opengl --enable-virglrenderer --enable-system --enable-modules --audio-drv-list=pa --target-list=x86_64-softmmu --enable-kvm --enable-gtk --enable-slirp --enable-debug
```


 - make

```bash
make

sudo adduser (your user name) kvm

sudo chmod 666 /dev/kvm

sudo touch /lib/udev/rules.d/99-kvm.rules
// add line KERNEL=="kvm", GROUP="kvm", MODE="0666"
```


 - install qemu-utils

```bash
sudo apt install qemu-utils
```

 - cd to the directory where you want create the virtual hard disk

```bash
qemu-img create -f qcow2 Android.img 10G
```

 - Download android-x86 image 

 - cd to directory were u git cloned qemu

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



 - boot directly to image 

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
