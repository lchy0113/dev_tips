# Linux 기반의 오디오 제어 

Android 오디오아키텍처 요약

Android 플랫폼에서 오디오 코덱을 제어하는 데는 ALSA(Advanced Linux Sound 
Architecture) 기반의 tinyalsa 또는 alsalib을 사용하는 경우가 많고, 
이는 Android의 Audio HAL(Hardware Abstration Layer) 구현에 포함됨.

```plane
+-------------------------------+
|           App Layer          |
+-------------------------------+
|       Audio Framework         |
|  (AudioFlinger, AudioPolicy) |
+-------------------------------+
|       Audio HAL Interface     |
|       (audio_hw.c 등)        |
+-------------------------------+
|        tinyalsa / alsa-lib    |
+-------------------------------+
|        ALSA kernel driver     |
+-------------------------------+
|     I2S, I2C 등 H/W 인터페이스 |
+-------------------------------+
```

🔧 tinyalsa의 역할

 - tinyalsa는 AOSP에서 사용하는 경량 ALSA 라이브러리로, Android의 오디오 HAL 레벨에서 직접 ALSA 디바이스를 제어하기 위해 사용됩니다.
 - 사용 목적:
   * PCM 출력 (Playback) 및 입력 (Capture)
   * Mixer control (볼륨, Mux, Mute 등)
   * Routing control

audio_hw.c 또는 xxx_audio_hw.c 같은 HAL 파일 내에서 tinyalsa API를 사용해 직접 PCM 장치를 open/read/write/close 함.


⚙️ 참고: Tinyalsa vs alsa-lib

|    **항목**    |        **tinyalsa**       |          **alsa-lib**         |
|:--------------:|:-------------------------:|:-----------------------------:|
|      용도      | Android HAL에서 주로 사용 | 일반 Linux 데스크탑, 서버 등  |
|      특징      | 경량, AOSP에 포함         | 복잡하고 다양한 기능 제공     |
|       API      | 단순: pcm_open, mixer_get | 복잡: snd_pcm_open, snd_ctl_* |
| AOSP 포함 여부 | 포함 (external/tinyalsa)  | 미포함 (별도 포팅 필요)       |

<br/>
<br/>
<br/>
<hr>

## alsa-lib개요

Linux 플랫폼에서는 오디오 제어 시 일반적으로 **alsa-lib** 를 사용하며, 이는 ALSA 커널 드라이버와
사용자 공간(user-space) 간의 인터페이스 역할을 함.

✅ 1. alsa-lib 개요
 - 정식 명칭: Advanced Linux Sound Architecture library
 - 소스 위치: https://github.com/alsa-project/alsa-lib
 - 주요 파일: libasound.so, alsa/asoundlib.h
 - 역할:
   * snd_pcm_* (PCM 디바이스 제어)
   * snd_mixer_* (Mixer 제어)
   * snd_ctl_* (컨트롤 제어)
   * ~/.asoundrc, /etc/asound.conf 등 구성 파일 로딩

<br/>
<br/>
<br/>
<hr>

## Linux 플랫폼 오디오제어

✅ Linux 기반의 오디오 스택 개요

```plane
+-------------------------------+
|      Application Layer        |
|   (e.g., aplay, GStreamer)    |
+-------------------------------+
|       Audio Libraries         |
| alsa-lib, PulseAudio, PipeWire|
+-------------------------------+
|      ALSA Kernel Interface    |
|   (soundcore, snd_pcm, etc.)  |
+-------------------------------+
|        H/W Driver Layer       |
|     (I2S, Codec Driver 등)    |
+-------------------------------+
```

🔧 주요 오디오 제어 솔루션 5가지

1. alsa-lib (Advanced Linux Sound Architecture Library)
 - 표준 Linux 오디오 라이브러리. 사용자 공간에서 ALSA 디바이스를 제어.
 - 사용 방식은 복잡하지만, 강력한 기능을 제공.
 - 개발자 수준의 low-level control 가능.
 - API 예: snd_pcm_open, snd_pcm_writei, snd_ctl_*

2. asound.conf / .asoundrc
 - ALSA 장치의 라우팅, 믹싱, 변환을 구성하는 설정 파일.
 - 시스템 수준 또는 사용자 수준 오디오 라우팅 설정 가능.
 - 예: 특정 PCM을 default로 지정, dmix 사용 설정 등

3. 3. amixer / alsamixer (CLI 기반 믹서 도구)
 - ALSA mixer 인터페이스를 제어하는 CLI 도구
 - 볼륨 제어, mux 선택, 마이크 활성화/비활성화 등 수행
 - amixer, alsamixer 모두 mixer control을 편하게 설정 가능

4. PulseAudio (중간 레이어 사운드 서버)
 - 사용자가 여러 앱에서 동시에 오디오를 사용하는 데 필요한 사운드 서버
 - ALSA 위에서 동작하며, 네트워크 오디오 스트리밍 등 고급 기능 제공
 - 데스크탑 Linux에서는 기본 구성 (ex: Ubuntu)

5. PipeWire (신형 사운드/미디어 서버)
 - PulseAudio를 대체하기 위한 프로젝트
 - 오디오 + 비디오 처리를 통합적으로 관리
 - 최신 GNOME 기반 데스크탑에서 기본 채택 중 (예: Ubuntu 22.04 이상)


🔧 Embedded Linux에서는 어떻게 써야 할까?
 - 리소스가 적다면 alsa-lib + amixer 기반 제어를 선호
 - 오디오 코덱 제어는 Device Tree 또는 I2C 통해 codec driver에서 다룸
 - 필요 시 UCM (Use Case Manager) 또는 간단한 커스텀 Audio HAL 구현 가능

<br/>
<br/>
<br/>
<hr>

## AK7755 오디오 코덱을 Linux ALSA 환경에서 제어 예제

✅ 전제 조건
 - AK7755가 I2C로 연결되어 있고, 관련 커널 드라이버(sound/soc/codecs/ak7755.c)가 등록.
 - device tree 또는 platform data를 통해 등록된 상태
 - ALSA Mixer 컨트롤러로 제어 가능한 상태
 - amixer, alsamixer 또는 C 코드에서 alsa-lib API로 컨트롤 가능

✅ 1. amixer 또는 alsamixer를 통한 제어 예시
AK7755 드라이버는 ALSA mixer control에 여러 컨트롤 노드를 제공.

```bash
# 전체 Mixer 컨트롤 노드 확인
amixer -c 0 scontrols

# 예시 출력:
# Simple mixer control 'AK7755 DAC Playback Volume',0
# Simple mixer control 'AK7755 ADC Capture Switch',0

# DAC 볼륨 제어
amixer -c 0 sset 'AK7755 DAC Playback Volume' 80%

# ADC 마이크 입력 활성화
amixer -c 0 sset 'AK7755 ADC Capture Switch' on
```

✅ 2. C 코드 예시 (alsa-lib 기반)

```c
#include <alsa/asoundlib.h>

int main() {
    snd_mixer_t *handle;
    snd_mixer_elem_t *elem;
    snd_mixer_selem_id_t *sid;

    const char *card = "default"; // 또는 hw:0
    const char *selem_name = "AK7755 DAC Playback Volume";

    snd_mixer_open(&handle, 0);
    snd_mixer_attach(handle, card);
    snd_mixer_selem_register(handle, NULL, NULL);
    snd_mixer_load(handle);

    snd_mixer_selem_id_malloc(&sid);
    snd_mixer_selem_id_set_index(sid, 0);
    snd_mixer_selem_id_set_name(sid, selem_name);

    elem = snd_mixer_find_selem(handle, sid);
    if (!elem) {
        printf("Control not found\n");
        return 1;
    }

    // 볼륨 80% 설정 (range: 0~max)
    long minv, maxv;
    snd_mixer_selem_get_playback_volume_range(elem, &minv, &maxv);
    long set_vol = minv + (maxv - minv) * 0.8;
    snd_mixer_selem_set_playback_volume_all(elem, set_vol);

    snd_mixer_close(handle);
    snd_mixer_selem_id_free(sid);

    return 0;
}

```

✅ 3. DAPM 제어도 가능 (Platform 측)
AK7755는 **DAPM (Dynamic Audio Power Management)**을 사용하는 코덱이므로,
DAI 라우팅을 조정하면 자동으로 필요한 path를 power on/off 함.

만약 platform driver에서 route를 직접 설정하고 싶다면:

```c
static const struct snd_soc_dapm_route audio_routes[] = {
    {"Headphone", NULL, "AK7755 DAC"},
    {"AK7755 DAC", NULL, "Playback"},
    {"AK7755 ADC", NULL, "Mic Bias"},
    {"Capture", NULL, "AK7755 ADC"},
};
```
