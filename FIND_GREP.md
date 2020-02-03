find, grep, ripgrep
=====

find 
-----
홈 디렉토리 source에서 python 파일을 출력하는 예제.
```
$ find ~/source -name "*.py"
```

/work/path/test.nk 파일보다 이후에 생성된 파일을 출력하는 예제
```
$ find /work/path -newer /work/path/test.nk
```


grep 
-----
grep은 파이프와 자주 사용하는 명령어이다. 결과에서 필터링 할 때 자주 사용되는 명령어이다. 위 결과에서 test 문자가 들어간 경로만 출력한다.
```
$ find ~/source -name "*.py" | grep test
```


ripgrep
-----
수많은 파일 내부에서 문자를 검색할 때 자주 사용한다. grep 보다 속도가 빠르다.

소스 코드 : https://github.com/BurntSushi/ripgrep

기본 사용법
```
$ rg 검색어
```

파이썬 파일에서만 검색하는 방법.
```
$ rg -g '*.py' 검색어
```
