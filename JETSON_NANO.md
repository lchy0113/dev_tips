# Jetson Nano 
-----

> Lineage Android OS for the Jetson Nano


## Lineage O/S

 - Android/lineage OS code 

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs
```


## Download 

 Tegra 장치에는 "Tegra Recovery 모드"(APX라고도 알려진 RCM)라는 고유한 부팅 모드가 제공됩니다. 
 Tegraflash는 최신 Tegra 장치에서 RCM 모드와 인터페이스하기 위한 공식 NVIDIA 도구입니다. 
 Tegraflash는 Linux에서만 사용할 수 있습니다. 또한 VM에서는 제대로 실행되지 않습니다.

 - 전원 Off 상태에서 FC REC 핀과 GND 핀을 연결 한 후, 전원 on합니다. 이후 FC REC 핀과 GND 핀을 해제 합니다.
