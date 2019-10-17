# 우분투 GIT 서버 구축.
-----

# GIT 설치.
-----
```
$ sudo add-apt-repository ppa:git-core/ppa
$ sudo apt-get update
$ sudo apt-get install git-core
$ git version
```

# GIT 접근 권한 관리.
-----
1. SSH 로 접근가능한 유저 계정 생성.

2. 대표계정(git)을 생성해 접근하는 사용자 관리.

3. gitolite 툴을 이용한 접근 관리.

# 대표 계정 (git) 을 생성해 접근하는 사용자 관리.
-----
- 대표 계정을 생성하고 저장소 권한 변경.
```
$ sudo adduser git 
$ su git
```

- git 사용자의 홈 디렉토리에 SSH-key 등록.
```
$ cd ~ //(사용자 계정)
$ cat id_rsa.pub >> /home/home/git/.ssh/autorized_keys
$ chmod 600 ~/.ssh/authorized_keys
```

- 보안을 위한 쉘기능 제한.
```
$ sudo vi /etc/passwd
  git:x:1001:1001:,,,:/home/git:/bin/bash

  을 아래로 변경.
  git:x:1001:1001:,,,:/home/git:/usr/bin/git-shell
```

# GIT 저장소 생성.
-----
```
$ su git 
$ cd ~ 
$ mkdir repos 

$ mkdir repos/RICHGOLD.git
$ git init --bare --shared 
--bare 옵션을 주면 원격 저장소가 생성.
--shared 옵션을 주면 자동으로 그룹 쓰기 권한을 추가. 
```

# 접근 시험.
-----
```
$ git clone ssh:git@192.168.56.2:/home/git/repos/RICHGOLD.git 
```
