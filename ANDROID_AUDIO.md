# ANDROID AUDIO
> Android Audio System (Audio Flinger)

## Android Sound System
 사운드 시스템은 시스템에 중요한 역할을 담당하는 드라이버이며, 또한 복잡도가 높은 드라이버 및 구조를 가지고 있습니다.
 복잡함의 가장 큰 원인은 효과적으로 소리를 출력하고, 마이크를 통한 입력, 폰의 경우에는 다양한 출력 형태를 제공해 줘야 하기 때문입니다.

## ALSA (Advanced Linux Sound Architecture)
 ALSA는 여러 응용프로그램부터의 사운드 데이터를 믹싱(mixing) 할 수 있는 인터페이스를 제공하는 구조로 만들어졌습니다. 
 기존 리눅스 시스템 구조에 향상된 오디오 기능을 부여하게 됩니다. 관련 장치 파일들은 /dev/snd에 존재하며 직접 액세스는 하지 않습니다. 
 alsa-lib를 통해서 ALSA의 모든 기능을 이용할 수 있는 구조로 되어 있습니다. 또한 관련 장치에 대한 제어도 이미 준비되어 있는 유틸리티를 이용하는 구조로 되어 있습니다.
 (alsa-utils), amixer(console버전), alsamixer(gui버전)

```bash
/ # ls -alh /dev/snd/
total 0
drwxr-xr-x  2 root   root       120 2014-05-25 17:25 .
drwxr-xr-x 16 root   root      3.3K 2014-05-25 17:25 ..
crw-rw----  1 system audio 116,   0 2014-05-25 17:25 controlC0
crw-rw----  1 system audio 116,  24 2014-05-25 17:25 pcmC0D0c
crw-rw----  1 system audio 116,  16 2014-05-25 17:25 pcmC0D0p
crw-rw----  1 system audio 116,  33 2014-05-25 17:25 timer
```

## ALSA 시스템 구조
 리눅스 커널 소스의 sound/soc/* 에 존재하며, 전체 구조 중 SoC에 해당하는 부분의 architecture부분이 분리되어 있습니다.

![](./image/ANDROID_AUDIO-01.png)


## ALSA 시스템의 주요 기능
 - control interface : 가능한 장치들을 체크하고, 사운드 카드의 레지스터를 관리하기 위한 일반적인 목적(general-purpose)을 위한 기능.
 - pcm interface : 일반적인 디지털 오디오 어플리케이션이 이용하는 디지털 오디오 캡쳐와 출력을 위한 인터페이스.
 - raw midi interface : 전자 음악 장비의 표준인 midi(musical instrument digital interface) 지원. api는 사운드 카드의 midi 버스로 접근을 제공. midi 이벤트와 직접 동작하고 프로그래머는 프로토콜과 타이밍에 대한 관리. 
 - time interface : 사운드 이벤트의 동기화에 사용되는 사운드 카드의 하드웨어 타이밍의 접근 제공.
 - sequencer interface : midi 프로그래밍을 위한 고수준 인터페이스로 보다 많은 midi 프로토콜과 타이밍을 관리.
 - mixer interface : 사운드 볼륨의 제어와 입력 시그널의 선택과 사운드 카드의 장비 제어. 컨트롤 인터페이스의 제일 위에 위치.


## ALSA API
 응용 프로그램에서 ALSA는 ALSA lib에서 제공하는 API를 이용하여 접근하도록 기능을 제공하고 있습니다. ALSA 라이브러리 API를 기술한 링크는 다음과 같습니다.
 - http://www.alsa-project.org/alsa-doc/alsa-lib/
 - http://www.alsa-project.org/~tiwai/alsa-driver-api/index.html
 - http://alsa.opensrc.org/index.php/Asynchronous_Playback_(Howto)


<hr/>

## Android Sound Subsystem 구조
 Android sound subsystem의 class구조와 흐름은 다음과 같습니다.

![](./image/ANDROID_AUDIO-02.png)


### Android Sound HAL
 Android Sound system은 다른 서브 시스템과 마찬가지 2가지 구조로 이루어져 있습니다.
 1) Audio service : service
 2) Audio user : client 

### Android Audio Service(server 구성)
 audio service를 구성하는 부분은 audioflinger입니다. 이 audio service는 init process가 실행되면서 init.rc의 내용에 따라 mediaserver를 구동시킵니다. 
 mediaserver는 데몬(daemon) 프로세서로 항상 동작대기 상태에 있으며, client의 요청에 따라 특정 동작에 대한 요청을 받아들이고, 
 HAL을 통해서 이를 실행하는 역할을 합니다.

### Android Audio User(client 구성)
 audio client는 JAVA에서의 응용프로그램이 실행되거나 할때 생성됩니다.
 sound play의 경우는 AudioTrack class를 생성해서 audioflinger쪽에 서비스를 요청하게 됩니다. 
 sound record의 경우에는 Audio Record class를 생성해서 audioflinger쪽에 서비스를 요청하게 됩니다.
 실제로 모든 서비스의 실행 및 동작은 서버 쪽에서 이루어집니다.

### Android Sound System 초기화
 Android Sound System의 초기화는 init process가 init.rc의 내용을 실행시킬 때, mediaserver가 실행되고, 
 AudioFlinger가 초기화 되면서 시작됩니다. 
 시스템의 init과정에서 AudioFlinger가 생성이 될때, AudioHardwareInterface가 초기화 됩니다.
 이 AudioHardwareInterface는 Android Audio Device의 Hardware Abstraction Layer라고 얘기 할 수 있습니다.

### 초기화 후, Routing 설정
 AudioFlinger system 초기화 시, 하드웨어 초기화가 끝나면 Audio System의 Routing에 대한 정보를 설정하게 됩니다.
  * 출력 : 스피커 혹은 헤드셋, bluetooth등.
  * 입력 : 마이크 혹은 line-in 등.
 Audio system의 기반이 되는 HAL을 제어하는 AudioFlinger는 다음과 같이 mediaserver daemon이 시작되면서 시작합니다.

<br />

<hr/> 

## Android audio system : from AudioTrack to AudioFlinger

### 1.  Overview of Android Audio Framework 
> Android 7.0-Nougat

![Android audio system architecture diagram](./image/ANDROID_AUDIO-04.png)

 오디오는 Android platform 내에서 매우 중요한 부분  입니다. 오디오 데이터 input & output, audio stream 제어, audio device 관리, volume 조정, 등을 담당합니다. 

- Audio Application Framework  
  * AudioTrack : Android 애플리케이션 프레임워크 API에서 data playback 기능 담당.
  * AudioRecord : Android 애플리케이션 프레임워크 API에서 recording data 기능 담당.
  * AudioSystem : Android 애플리케이션 프레임워크 API에서 audio affairs(기능)에 대한 종합적인 관리 담당.
- Audio Native Framework : Audio Native Framework 
  * AudioTrack : Android native framework API에서 data playback 기능 담당.
  * AudioRecord : Android native framework API에서 recording data 기능 담당.
  * AudioSystem : Android native framework API에서 audio 기능에 대한 종합적인 관리 담당.
- Audio Service
  * AudioPolicyService : The maker of audio policy,    audio 장치 선택 및 전환, 볼륨 제어 정책 등 담당.
  * AudioFlinger : The executor of the audio strategy,     input 및 output stream 장치 관리와 audio stream data 처리 및 전송 담당.
- Audio HAL : Audio 장치 HAL,    AudioFlinger에서 Audio hardware devices를 호출 할 수 있도록 기능 담당

Audio는 MultiMedia와 밀접한 관련이 있습니다. MultiMedia는 Audio 및 Vide의 encoding 및 decoding을 담당합니다. 
MultiMedia는 AudioTrack을 통해 decodein된 데이터를 출력하고, AudioRecord에서 입력된 recording data는 MultiMedia로 encoding됩니다.


### 2. AudioTrack API Overview
 sound를 재생하려면 MediaPlayer & AudioTrack을 사용합니다. 둘 다 Application developers을 위한 Java API를 통해 제공합니다. 
 둘의 차이점은 아래와 같습니다.
 - MediaPlayer 
	 MediaPlay는 mp3, flac, wma, ogg, wav 등과 같은 여러 형식의 audio source를 재생할 수 있습니다.
 - AudioTrack
	 AudioTrack는 decording된 PCM data stream 형식의 audio sources만을 출력가능합니다. 



위의 Android 오디오 시스템 아키텍처 다이어그램에서: MediaPlayer는 네이티브 레이어에 해당 오디오 디코더와 AudioTrack을 생성하고 디코딩된 데이터는 AudioTrack에서 출력합니다.

  따라서 MediaPlayer에는 더 넓은 범위의 응용 프로그램 시나리오가 있으며 일반적으로 사용하는 것이 더 편리합니다. 매우 까다로운 사운드 지연이 필요한 일부 응용 프로그램 시나리오에만 AudioTrack이 필요합니다.
<br />

<hr/>

## ANDROID AUDIO SYSTEM ANALYSIS
- kernen, linux alsa architecture : 
	kernel-3.14/sound/soc/tcc/
	kernel-3.14/Documentation/sound/alsa/soc/
- android upper alsa interface :
	external/tinyalsa/
- hal :
	hardware/telechips/common/audio/
- android audio flinger :
	frameworks/av/services/audioflinger/

tinyalsa는 Android 4.0 에 AOSP코드에 포함되었으며, alsa 커널을 기반으로 하는 user-level audio interface 입니다. Android 4.0 이전에는 alsa-lib 가 사용되었습니다. Google이 tinyalsa를 출시한 이유는 alsa가 GPL 라이선스를 사용하기 때문일 수도 있고, alsa-lib의 라이브러리가 너무 복잡하고 번거롭기 때문일 수도 있습니다. 
tinyalsa의 main header file 과 data structre 는 아래 이미지와 같으며,  kernel alsa 와 ioctl을 통해 동작합니다.
![class tinyalsa](./image/ANDROID_AUDIO-03.png)

pcm device 는 tinyalsa에 의해 code를 읽고, Android에서 오디오 장치 노드로 보여집니다.   
Android에서 pcm device는 최대 하나의 mixer device 를 가질 수 있습니다.   

    	/dev/snd/controlC%u" (usually controlC0)  
    	/dev/snd_pcmC%uD%uc  (usually pcmC0D0c)  
    	/dev/snd/pcmC%uD%u%p (usually pcmC0D0p)  

pcm device에서 C 의미는 Card, D 의미는 Device, c 의미는 Capture, p 의미는 playback을 나타냅니다.   
PCM sound card가 추가되면  C의 값은 +1 증가되며, 그 외의 값은 변화되지 않습니다.   
pcmC1D0c,   pcmC1D0p  
  
tinyalsa가 제공하는 external header파일은 "asoundlib.h"로써 기본적인 pcm 및 mixer 기능을 제공합니다.  
기능 구현 파일은 pcm.c(pcm api 구현)와 mixer.c(mixer api 구현) 입니다. soundlib.h 의 정보를 보면 tinypcminfo, tinyplay, tinycap, tinymix 함수가 작성되었습니다.  
 이 4가지 기능은 system 명령으로 편리하게 동작됩니다.  
  
 tinypcminfo 는 tinypcminfo.c에서 구현되었습니다.  
 tinyplay 는 tinyplay.c 에서 구현되었습니다.  
 tinycap 은 tinycap.c 에서 구현되었습니다.   
 tinymix 는 tinymix.c에서 구현되었습니다.  
  
 이러한 명령어가 실행될때, tinypcminfo가 먼저 pcm device의 capabilities를 체크합니다.  
  
mixer 를 이용한 제어
```bash
//Original state
root@pone :/data /local /tmp # tinymix -D 1
Mixer name : 'mixer_name_xx'
Number of controls : 2
ctl type num name value
0 BOOL 1 Mic Capture Switch Off
1 INT 1 Mic Capture Volume 256
 
//details
root@pone :/ data /local /tmp # tinymix -D 1 0
Mic Capture Switch : Off
root@pone :/data/local /tmp # tinymix -D 1 1
Mic Capture Volume : 256 ( range 0 -> 256 )
  
//set
root@pone :/data/local /tmp # tinymix -D 1 0 1
root@pone :/data /local/tmp # tinymix -D 1 1 250
   
//modified state
root@pone :/data/local /tmp # tinymix -D 1
Mixername : 'mixer_name_xx'
Numberof controls : 2
ctl type num name value
0 BOOL 1 Mic Capture Switch On
1 INT 1 Mic Capture Volume 250
```

tinyplay : playback process
```c
external/tinyalsa/tinyplay.c
main()
  + Parameter analysis
  + play_sample()
      + pcm_open()
      |   + snprintf(fn, sizeof(fn), "/dev/snd/pcmC%uD%u%c", card, device,
      |   |          flags & PCM_IN ? 'c' : 'p');
      |   + pcm->fd = open(fn, O_RDWR|O_NONBLOCK); // Open / dev/snd equipment
      |   | 
      |   + ioctl(pcm->fd, SNDRV_PCM_IOCTL_HW_PARAMS, &params)
      |   + ioctl(pcm->fd, SNDRV_PCM_IOCTL_SW_PARAMS, &sparams)
      |
      + do { pcm_write() } while()
      |   + // pcm_write()
      |   + if (!pcm->running) {
      |   |   pcm_prepare(pcm); // ioctl(pcm->fd, SNDRV_PCM_IOCTL_PREPARE)
      |   |   ioctl(pcm->fd, SNDRV_PCM_IOCTL_WRITEI_FRAMES, &x)
      |   |   return 0;
      |   | }
      |   |
      |   + // Write data through ioctl
      +   + ioctl(pcm->fd, SNDRV_PCM_IOCTL_WRITEI_FRAMES, &x)
```

pcm_open(), pcm_prepare(), pcm_write() 함수는 ioctl을 통해 커널과 상호작용한다.

<br />

<hr/>

```bash

frameworks/av/media/mediaserver/mediaserver.rc
	|
	+-> service media /system/bin/mediaserver
		    class main
		    user media
		    group audio camera inet net_bt net_bt_admin net_bw_acct drmrpc mediadrm
		    ioprio rt 4
		    writepid /dev/cpuset/foreground/tasks /dev/stune/foreground/tasks

```

<br />

<hr/>

 - reference 
   * https://programmer.ink/think/qualcomm-8155-audio-data-from-hal-to-dsp.html

 - audio sample
 오디오 샘플링 속도는 녹음 장비가 단위 시간당 얼마나 많은 아날로그 신호를 샘플링하는지를 말하며 샘플링 주파수가 높을수록 기계적 파동 의 파형이 더 사실적이고 자연스럽습니다 . 오늘날의 주류 캡처 카드에서 샘플링 주파수는 일반적으로 11025Hz, 22050Hz, 24000Hz, 44100Hz 및 48000Hz의 5가지 레벨로 나뉩니다.11025Hz는 AM 방송의 음질을 달성할 수 있고 22050Hz 및 24000Hz는 FM 방송을 달성할 수 있습니다. 44100Hz는 CD 음질의 이론적인 한계이며 48000Hz가 더 정확합니다.

   * 공통 샘플 속도
     디지털 오디오 분야에서 일반적으로 사용되는 샘플링 속도는 다음과 같습니다.
	 8,000Hz - 전화에서 사용되는 샘플 속도, 사람의 음성에 충분
	 11,025Hz - AM 방송에 사용되는 샘플링 레이트
	 22,050Hz 및 24,000Hz - FM 라디오에서 사용되는 샘플 속도
	 32,000Hz - miniDV 디지털 비디오 캠코더용 샘플링 속도, DAT(LP 모드)
	 44,100Hz - MPEG-1 오디오(VCD, SVCD, MP3)에서 사용되는 샘플링 속도에도 일반적으로 사용되는 오디오 CD
	 47,250Hz - 상업용 PCM 레코더에서 사용되는 샘플 속도
	 48,000Hz - miniDV, 디지털 TV, DVD, DAT, 영화 및 전문 오디오에서 사용되는 디지털 사운드의 샘플 속도
	 50,000Hz - 상업용 디지털 레코더에서 사용되는 샘플 속도
	 96,000 또는 192,000Hz - DVD-Audio, 일부 LPCM DVD 오디오 트랙, BD-ROM(Blu-ray Disc) 오디오 트랙 및 HD-DVD(High Definition DVD) 오디오 트랙에서 사용되는 샘플 속도
	 2.8224MHz - Direct Stream Digital의 1비트 시그마-델타 변조 프로세스에서 사용하는 샘플링 속도입니다.
