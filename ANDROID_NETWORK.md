# Android Network.
![](./image/ANDROID_NETWORK_1.png)

**Control / Monitor API** : like the control bus of a device. The primary responsibilities of these API :
> 1) Monitor network connections (Wi-Fi, mobile, Ethernet, etc).
> 2) Send broadcast intents when network connectivity changes.
> 3) Attempt to "fail over" to another network when connectivity changes.
> 4) Provide an API that allows applications to query the coarse-grained or fine-grained state of the available network.
> 5) Provide an API that allows applications to request and select networks for their data traffic.
> 6) start/stop the assigned network, etc.


## Android M network's mechanism of connectivity & magagement. 

### Networkrequest.
 Android Multi-network의 connectivity & management를 메커니즘을 알기 위해, 명확해야 할 2가지 중요한 개체인 **Networkrequest**와 **NetworkAgent**가 있다. 

