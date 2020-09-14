# Input Device Driver.(Key input)
=====


* Android key Layout file 의 각 필드는 다음과 같다.
-----

| 'scancode' | 커널에서 올라오는 값 |
| 'keycode'  | 안드로이드로 올라가는 키 값 | 

data/keyboards/Generic.kl
```
key 1     ESCAPE
key 2     1   
key 3     2   
key 4     3   
key 5     4   
key 6     5   
key 7     6   
key 8     7   
key 9     8   
key 10    9   
key 11    0   
key 12    MINUS
key 13    EQUALS
key 14    DEL 
key 15    TAB 
key 16    Q   
key 17    W   
key 18    E   
key 19    R   
key 20    T   
key 21    Y   
key 22    U   
key 23    I   
key 24    O   
key 25    P   
```

- 커널 레벨에서 인식되는 키 값과 해당 키 값이 안드로이드로 리포팅되는 값. 
- 그리고 해당 키가 동작하는 방식등에 대한 정의.  
| 'WAKE'         | 디바이스 활성화 및 애플리케이션 키 이벤트 전달      |
| 'WAKE_DROPPED' | 디바이스 활성화 및 애플리케이션에 키 이벤트 미 전달 |
