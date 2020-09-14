# Input Device Driver.(Key input)
=====


* Android key Layout file 의 각 필드는 다음과 같다.
-----

| 의미     | 설명                        |
|:--------:|:----------------------------|
| scancode | 커널에서 올라오는 값        |
| keycode  | 안드로이드로 올라가는 키 값 | 

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

| 의미         | 설명                                                |
|:------------:|:----------------------------------------------------|
| WAKE         | 디바이스 활성화 및 애플리케이션 키 이벤트 전달      |
| WAKE_DROPPED | 디바이스 활성화 및 애플리케이션에 키 이벤트 미 전달 |


make update-api
-----
AOSP의 API를 수정한 경우, API를 업데이트 해야 한다. 
> (참고로 공식적으로 API를 원하지 않는 경우 KeyEvent.java에서 @hide를 명시하지 않을 경우 빌드 시, error가 발생하므로 이에 주의한다. 만일 key를 공식으로 사용하려면 clean build 후 make update-api를 실행하면 doc을 업데이트하며 다음 platform 빌드 시 발생하는 문제를 회피할 수 있다.)


/frameworks/base/api/current.txt
/frameworks/base/api/system-current.txt
/frameworks/base/api/test-current.txt


KeyEvent
-----
https://developer.android.com/reference/android/view/KeyEvent

 key press는 연속된 키 이벤트로 설명된다.
 key press은 ACTION_DOWN키 이벤트로 시작된다. 키가 반복될만큼 충분히 길게 유지되면(누르고 있으면) getRepeatCount() 함수는 0이 아닌 값을 갖는다. 
 마지막 키 이벤트는 ACTION_UP 이다. 
 키 누름이 취소되면 key up 플래그에 FLAg_CANCELED가 설정된다. 

 키 이벤트는 일반적으로 key code(getKeyCode()), scan code(getScanCode()), meta state(getMetaState())를 함께 수행한다. 
 - key code : 
 > 키 코드 상수는 class KeyEvent에서 정의된다.
 - scan code :
 > OS 로 부터 전달받은 코드이며, KeyCharacterMap을 사용하여 해석하지 않는 한 App layer 에서 의미가 없다.
 - Meta state : 
 > META_SHIFT_ON 또는 META_ALT_ON 과 같은 키 수정자의 눌린 상태를 설명한다.
 
  Key Code 는 일반적으로 Input device 의 개별키와 일대일로 대응한다. 많은 키와 키 조합은 서로 다른 입력장치에서 매우다른 기능을 제공하므로 해석할때 주의해야 한다.
  KeyCharacterMap 키를 문자에 매핑할 때 항상 입력장치와 관련된 키를 사용해야 한다. 
  동시에 활성화된 여러 키 입력장치가 있으며 각 장치에는 고유한 키 문자 맵이 있다. 

