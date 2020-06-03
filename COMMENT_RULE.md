주석 작성 규칙(Rules for comment.) 
====

> 모든 주석은 영문으로 작성한다.

주석 작성 comment block
-----
* comment block 은 아래와 같이 사용.
```
 /**
  * @command
  */
```

주석 command
-----
> 아래 리스트 순으로 command를 작성.

* @file
> 파일 이름 표시. 

* @author
> 작성자 표시.

* @brief
> 설명 표시.

* @param
> 변수 설명 표시.

* @see
> 참고 사항 표시.

* @todo
> 추가적으로 처리 해야 하는 내용 표시.

* @deprecated
> 삭제 예정 표시.

예시.
-----
```
/**
 * @brief Debugging of noise occurrence during audio output. \n Changed out sample_rate from 441 kHz to 48 kHz.
 * @author changyong lee (lchyq113@kdiwin.com)
 * @see PDNHN1033-44 (http://its.kdiwin.com:8080/browse/PDNHN1033-44)
 */
```
