REST API  
====


# 1. REST API의 이해와 설계.
-----
# 1-개념 소개.
 REST는 웹의 창시자(HTTP) 중의 한 사람인 Roy Fielding의 2000년 논문에 의해서 소개되었다.
 현재의 아키텍쳐가 웹의 본래 설계의 우수성을 많이 사용하지 못하고 있다고 판단했기 때문에, 웹의 장점을 최대한 활용할 수 있는 네트워크 기반의 아키텍쳐를 소개했는데 그것이 바로 Representational safe transfer (REST)이다.


## 1.1. REST의 기본.
-----

 REST는 요소로는 크게 *리소스*, *메서드*, *메세지* 3가지 요소로 구성된다.
 예를 들어서 "이름이 Terry인 사용자를 생성한다." 라는 호출이 있을 때, 
 "사용자"는 생성되는 리소스, "생성한다"라는 행위는 메서드, 그리고 "이름이 Terry인 상요자는"는 메시지가 된다. 
 이를 REST 형태로 표현해보면,
 HTTP POST , http://myweb/users/
 ```
 {
   "user":{
      "name":"terru"
   }
 }
 ```
 와 같은 형태로 표현되며, 생성한다의 의미를 갖는 메서드는 HTTP Post 메서드가 되고, 
 생성하고자 하는 대상이 되는 사용자 라는 리소스는 http://myweb/users 라는 형태의 URI로 표현이 되며,
 생성하고자 하는 사용자의 디테일한 내용은 JSON 문서를 이용해서 표현된다.

## 1.2. HTTP 메서드
-----

 REST에서는 앞에서 잠깐 언급한바와 같이, 행위에 대한 메서드를 HTTP 메서드를 그대로 사용한다.
 HTTP에는 여러가지 메서드가 있지만 REST에서는 CRUD(Create Read Update Delete)에 해당 하는 4가지의 메서드만 사용한다.
 
 | 메서드 | 의미   | Idempotent |
 |--------|--------|------------|
 | POST   | Create | No         |
 | GET    | Select | Yes        |
 | PUT    | Update | Yes        |
 | DELETE | Delete | Yes        |

 각각 Post, Put, Get, Delete는 각각의 CRUD 메서드에 대응된다. 
 여기에 Idempotent라는 분류가 추가 했는데, Idempotent는 여러 번 수행을 해도 결과가 같은 경우를 의미한다. 
 예를들어, a++ 는 Idempotent 하지 않다고 하지만(호출시마다 값이 증가 되기 때문에), a=4와 같은 명령은 반복적으로 수행해도 Idempotent하다.(값이 같기 때문에)

 POST 연산의 경우에는 리소스를 추가하는 연산이기 때문에, Idempotent하지 않지만 나머지 GET, PUT, DELETE는 반복 수행해도 Idempotent 하다. 
 GET 의 경우, 게시물의 조회수 카운트를 늘려준다던가 하는 기능을 수행했을 때는 Idempotent하지 않은 메서드로 정의해야 한다. 
 Idempotent의 개념에 대해서 왜 설명을 하냐 하면, REST는 각 개별 API를 상태 없이 수행하게 된다. 그래서, 해당 REST API를 다른 API와 함께 호출하다가 실패하였을 경우, 트렌젝션 복구를 위해서 다시 실행해야 하는 경우가 있는데, Idempotent 하지 않은 메서드들의 경우는 기존 상태를 저장했다가 다시 원복해줘야 하는 문제가 있지만, Idempotent한 메서드의 경우에는 반복적으로 다시 메서드를 수행해주면 된다. 
 예를 들어 게시물 조회를 하는 API가 있을때, 조회시 마다 조회수를 올리는 연산을 수행한다면 이 메시드를 Idempotent 하다고 볼수 없고, 조회를 하다가 실패하였을 때는 올라간 조회수를 다시 -1로 빼줘야 한다. 즉, idempoten하지 않은 메서드에 대해서는 트렌젝션에 대한 처리가 별다른 주의가 필요하다. 

## 1.3. REST의 리소스.
-----

 REST는 리소스 지향 아키텍쳐 스타일이라는 정의 답게 모든 것을 리소스 즉 명사로 표현을 하며, 각 세부 리소스에는 id 를 붙인다.
 즉, 사용자라른 리소스 타입을 http://myweb//user 라고 정의했다면, terry라는 id를 갖는 리소스는 http://myweb/users/terry 라는 형태로 정의한다. 
 REST의 리소스가 명사의 형태를 띄우다 보니, 명령(Operation)성의 API를 정의하는 것에서 혼돈이 올 수 있다. 
 예를 들어서 "Push 메세지를 보낸다"는 보통 기존의 RPC(Remote Procedure Call)이나 함수성 접근해서는 /myweb/sendpush 형태로 잘못 정의가 될 수 있지만, 이러한 동사형을 명사형으로 바꿔서 적용해보면 리소스 형태가 표현하기가 조금 더 수월해진다.
 "Push 메시지 요청을 생성한다."라는 형태로 정의를 변경하면, API 포맷은 POST/myweb/push 형태와 같이 명사형으로 정의가 될 수 있다. 물론 모든 형태의 명령이 이런 형태로 정의가 가능한 것은 아니지만, 되도록이면 리소스 기반의 명사 형태로 정의를 하는게 REST형태의 디자인이 된다. 

 REST API의 간단한 예제,
 그러면 간단한 REST API의 예제를 살펴보도록 하자. 간단한 사용자 생성 API를 살펴보면, 
 
 * 사용자 생성
 다음은 http://myweb/users 라는 리소스를 이름은 terry, 주소는 seoul 이라는 내용(메시지)로 HTTP Post 를 이용해서 생성하는 정의이다. 
 ```
 HTTP Post, http://myweb/users/
 {
   "name":"terry",
   "address":"seoul"
 }
 ```

## 1.4. 조회.
-----

 다음은 생성된 리소스 중에서 http://myweb/users 라는 사용자 리소스중에, id가 terry 인 사용자 정보를 조회해오는 방식이다. 조회이기 때문에, HTTP Get을 사용한다.
 HTTP Get, http://myweb/users/terry
 업데이트
 다음은 http://myweb/users 라는 사용자 리소스중에, id가 terry 인 사용자 정보에 대해서, 주소를 “suwon”으로 수정하는 방식이다. 수정은 HTTP 메서드 중에 PUT을 사용한다.
 ```
 HTTP PUT, http://myweb/users/terry
 {
   "name":"terry",
   "address":"suwon"
 }
 ```

## 1.5. 삭제.
-----

 마지막으로 http://myweb/users 라는 사용자 리소스중에, id가 terry 사용자 정보를 삭제하는 방법이다. 
 HTTP DELETE, http://myweb/users/terry

 API 정의를 보면 알겠지만 상당히 간단하다. 단순하게 리쏘쓰를 URI로 정해준 후에, 거기에 HTTP 메서드를 이용해서 CRUD를 구현하고 메시지를 JSON으로 표현하여 HTTP Body에 실어 보내면 된다. POST URI에 리소스 id가 없다는 것을 빼면 크게 신경쓸 부분이 없다. 

