## [ TCC_Android_CE_GIT_user_guide_V4.4 ]  
----------  
1. Setting a ssh key file.
```
$ cd .ssh
$ ssh git.telechips.com
or 
$ ssh android.telechips.com
```

2. Repo initialization & repo sync.  
Make a new folder for downloading android source code.  
Initialize the repo to download source file through below command.  
Branch information are listed.  
  
Pie for Lion (TCC899x) :  
$ repo init -u ssh://android.telechips.com/androidce/android/platform/manifest.git -b CE-Pie-V2.2  
Oreo for Alligator (TCC898x) :  
$ repo init -u ssh://android.telechips.com/androidce/android/platform/manifest.git -b CE-Oreo-mr1-898x-V1.0  
KitKat for TCC897x :  
$ repo init -u ssh://android.telechips.com/androidce/android/platform/manifest.git -b v15.04_r1-tcc-android-4.4.2  
KitKat for TCC892x and TCC893x :  
$ repo init -u ssh://android.telechips.com/androidce/android/platform/manifest.git -b v14.04_tcc-android-4.4.2  

```
$ mkdir Android_SDK
$ cd Android_SDK
$ repo init -u ssh://android.telechips.com/androidce/android/platform/manifest.git -b branch_name
$ repo sync
```

3. Patch Download.  
You can download the SDK patch code by yourself from below git when you need it.  
URL : ssh://android.telechips.com/androidce/android/telechips/sdk_patch.git  
  
Available Branch listed  
1. v14.04_r1 (for TCC892x, TCC893x)  
2. v15.04_r1 (for TCC897x)  
3. Not released patch for Alligator, Lion.  
  
for example about how to download v14.04 patch code  
```
$ git clone ssh://android.telechips.com/androidce/android/telechips/sdk_patch.git -b v14.04_r1  
```
  
for example about how to download v15.04 patch code  
```
$ git clone ssh://android.telechips.com/androidce/android/telechips/sdk_patch.git -b v15.04_r1
```

## [ Build Guide ]
----------  
1. Build code.
Set environment variables.
```
$> source build/environment
$> lunch full_tcc898x-eng
```
1.1 bootloader
1.1.1 move to lk directory.(bootable/bootloader/lk)
1.1.2 build.
```
$> make tcc898x_android_stb
```

1.2 kernel
1.2.1 move to kernel directory.(kernel)
1.2.2 build.
```
$> make tcc898x_android_stb_defconfig DDR=4
$> make 
```

1.3 android build.
```
$> make
```


## [ Firmware Download Guide ]
----------  
See the "TCC898x Consumer Android SDK-Getting Started V1.00 [A] .pdf" document in the Telechips Android SDK repo vendor directory.



## [ Partition Info ]
----------  
|    | NAME     | DEVICE | START ADDR | END ADDR | LENGTH   | SIZE (KB) |
|:--:|----------|--------|------------|----------|----------|-----------|
| 1  | boot     |        | 34         |          | 30720    | 15360     |
| 2  | system   |        | 30754      |          | 1638400  | 819200    |
| 3  | cache    |        | 1669154    |          | 307200   | 153600    |
| 4  | recovery |        | 1976354    |          | 30720    | 15360     |
| 5  | dtb      |        | 2007074    |          | 4096     | 2048      |
| 6  | splash   |        | 2011170    |          | 10240    | 5120      |
| 7  | misc     |        | 2021410    |          | 2048     | 1024      |
| 8  | tcc      |        | 2023458    |          | 2048     | 1024      |
| 9  | vendor   |        | 2025506    |          | 204800   | 102400    |
| 10 | sest     |        | 2230306    |          | 16384    | 8192      |
| 11 | userdata |        | 2246690    |          | 13023164 | 6511582   |
