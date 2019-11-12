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
