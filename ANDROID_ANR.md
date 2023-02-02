#  Android ANR

1. ANR
ANR 발생 시, 로그상에서 아래와 같은 ANR로그 출력
```bash
04-18 16:51:25.455505  1929  1973 E ActivityManager: ANR in com.wallpad.service
04-18 16:51:25.455505  1929  1973 E ActivityManager: PID: 15532
04-18 16:51:25.455505  1929  1973 E ActivityManager: Reason: Broadcast of Intent { act=MqttService.pingSender.paho2318508142796 flg=0x14 (has extras) }
04-18 16:51:25.455505  1929  1973 E ActivityManager: Load: 0.87 / 0.93 / 0.61
04-18 16:51:25.455505  1929  1973 E ActivityManager: CPU usage from 293053ms to 0ms ago (2022-04-18 16:46:29.196 to 2022-04-18 16:51:22.474):
04-18 16:51:25.455505  1929  1973 E ActivityManager:   64% 2534/com.company.wall: 34% user + 29% kernel / faults: 51350 minor 17 major
04-18 16:51:25.455505  1929  1973 E ActivityManager:   2.1% 7581/adbd: 0.4% user + 1.7% kernel / faults: 29680 minor 1 major
```

