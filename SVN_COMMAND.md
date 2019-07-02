SVN(Subversion)명령어 사용 방법  
====  
    
@ checkout 또는 co - 저장소(repository)에서 로컬 작업공간으로 소스를 받아오는 것.   
----  
$> svn checkout 저장소URL [PATH...]  
: 지정된 로컬경로에 저장소의 소스가 복사된다. 경로가 지정안되면 저장소URL의 맨마지막 디렉토리명이 저장될 디렉토리로 사용되어진다. -r 옵션으로 리비전을 지정한 경우엔 해당 리비전의 소스를 가져온다.

예제) svn checkout -r 99 http://repository/src src

설명) 저장소에서 리비전 번호 99의 src경로내의 소스를 가져온다.


@ update 또는 up - 저장소(repository)의 최신 내용으로 로컬 소스를 갱신 한다.
----
: 기본적으로 최신 리비전을 반영한다. 그러나 -r 옵션으로 리비전을 지정한 경우엔 그 리비전으로 맞춘다.


@ commit 또는 ci - 로컬에서 수정된 내용을 저장소에 적용시킨다.
----
$> svn commit [PATH...]
: 기본적으로 이 명령을 내리면 수정 사항을 코멘트할 수 있게 로그 편집기가 실행된다. lock된 파일이나 디렉토리는 commit성공후 자동적으로 unlock된다.
 

@ lock - 저장소의 파일이나 디렉토리를 잠근다.
----
$> svn lock TARGET
: lock이 걸린 파일이나 디렉토리는 다른 사용자가 변경하여 commit할 수 없다. 해당 경로의 작업이 너무 방대하여 그 동안 다른 사용자가 수정하지 못하도록 할때 유용.

 
@ unlock - 저장소의 잠근 파일이나 디렉토리를 풀어준다.
----
$> svn unlock TARGET
: lock의 반대. 기본적으로 lock을 건 사용자가 풀어줘야 한다.
 

@ add - 새 파일이나 디렉토리를 추가한다.
----
$> svn add PATH...
: add 명령은 지정된 PATH의 새로운 파일이나 디렉토리를 버전관리 대상에 등록할 뿐이므로, add후 commit 명령을 수행해야만 실제로 저장소에 해당 파일이 추가된다.

 
@ delete 또는 del, remove, rm - 파일이나 디렉토리를 제거한다.
----
$> svn delete PATH...(URL)
: delete 명령은 add와 반대로 해당 PATH의 파일이나 디렉토리을 버전관리 대상에서 삭제한다. 역시 commit 명령을 수행해야만 실제로 저장소에서 해당 목록이 제거된다. URL로 지정했을 경우 해당 목록은 즉시 저장소에서 제거된다.


@ copy 또는 cp - 로컬 사본이나 저장소 내용을 복사한다. 브랜치(branch)를 만들기 위해 사용.
----
$> svn copy SRC  DST
: SRC가 로컬경로이고 DST도 로컬경로일 경우, 로컬복사되고 commit시 저장소에 복사 목록이 추가 저장된다. SRC가 로컬경로이고 DST가 저장소URL일 경우, URL에 복사되고 즉시 commit됨. SRC가 저장소URL이고 DST가 로컬경로일 경우, 로컬로 checkout하고 commit시 저장소에 해당 사본이 추가.

 SRC가 저장소URL이고 DST도 저장소URL일 경우, 저장소 내에 브랜치(branch)를 만듬.


@ move 또는 mv, rename, ren - 파일이나 디렉토리의 이름을 바꾸거나 이동시킨다. 이 명령은 copy후 delete와 같다.
----
$> svn move SRC  DST
: SRC가 로컬경로이고 DST도 로컬경로일 경우, 로컬로 rename 또는 move되고 commit시 저장소에 반영된다. SRC가 저장소URL이고 DST도 저장소URL일 경우, 저장소에서 rename,move가 바로 commit됨.

	   
@ info - 해당 파일에 대한 정보를 출력한다.
----
$> svn info TARGET
: TARGET의 저장소 URL경로나 마지막 수정 일자등에 대한 정보를 보여준다.

	   
@ log - 해당 경로나 파일의 로그( 리비전에 따라 변경된 내역)를 볼수 있다.
----
$> svn log [PATH]
: 지정된 로컬 PATH에 대한 로그를 출력한다. -r 옵션을 지정하면 출력할 리비젼 범위등을 정할 수 있다.

 예제) svn log -r 30:100 test.c

 설명) 리비전 번호 30~100 내에서 test.c에 대한 로그를 출력한다.

	   
@ status 또는 stat, st - 로컬 경로의 파일이나 디렉토리의 상태를 보여준다.
----
$> svn status [PATH]
: 해당 파일이 수정, 추가되었는지 등의 정보를 보여준다. -u 옵션을 주면 저장소의 최신 리비젼이 얼마인지 알려준다.
	   

@ diff 또는 di - 서로 다른 리비젼 간에 차이점을 출력해준다.
----
$> svn diff [-r N:M] TARGET
: 지정된 파일이나 경로에 대해 이전 리비젼하고 차이점을 보여준다. -r 을 지정하면 리비젼 N과 M사이의 차이점을 출력해준다.
예제) svn -r 30:45 test

설명) test 경로내에서 리비젼 번호 30과 45의 차이점을 출력해준다.

 
@ merge - 두 source 사이에 변경 내용을 작업 경로에 적용해준다.
----
1. $ svn merge URL1[@N] URL2[@M] [PATH]
2. $ svn merge [-r N:M] SOURCE [PATH]

: 1. URL1[리비젼 N]과 URL2[리비젼 M]을 비교하여, 변경 내용을 작업경로에 적용한다.
  2. SOURCE의 리비젼 N과 M을 비교하여, 해당 작업경로에 적용한다.

merge는 branch로 분리된 source에 대해 각각의 변경 내용을 현재의 작업에 병합하고자 할때 유용하다.

		 

@ blame 또는 praise, annotate, ann - 지정한 파일이나 URL의 내용 수정내역을 각 라인별로 보여준다.
----
$> svn blame TARGET
: 해당 파일의 각 라인에 대해 리비젼과 작성자를 나타내 준다. 누가 언제 어떤행을 수정했는지 알수 있음.

		 

@ import - 파일과 디렉토리를 저장소에 추가한다.
----
$> svn import [PATH] URL
		 

: URL에 지정된 PATH의 하위 디렉토리는 재귀적으로 추가되며, 필요시 상위 디렉토리가 자동으로 생성된다.

		 

@ export - 저장소에서 순수하게 프로그램 소스만 가져온다.
----
$> svn export URL [PATH]
: export는 버전관리를 위한 부속 파일들은 제외하고 순수한 소스만 받아오기 때문에, 주로 source release 용도로 사용되게된다. -r 옵션을 지정해서 해당 리비젼의 소스를 받아올 수 있다.


