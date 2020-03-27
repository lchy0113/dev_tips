## [ANDROID_SDK_CODE_MANAGEMENT]
=====

* ANDROID SDK CODE 형상 관리 가이드 작성.


1. download gerrit.
-----
* docker-gerrit을 git을 통해 내려받는다.
```
$ git clone https://gerrit.googlesource.com/docker-gerrit

$ git branch 
* (HEAD deatched at v3.1.2)
 master
```

2. Docker Volume Directory 생성.
-----
```
$ mkdir -p /home/gerrit/external/gerrit
$ mkdir -p /home/gerrit/external/gerrit/cache
$ mkdir -p /home/gerrit/external/gerrit/db
$ mkdir -p /home/gerrit/external/gerrit/etc
$ mkdir -p /home/gerrit/external/gerrit/git
$ mkdir -p /home/gerrit/external/gerrit/index
$ mkdir -p /home/gerrit/external/gerrit/ldap
```

3. 설치구성 파일 변경.
-----


3.1. docker-compose.yaml 파일 변경.
-----

* Port forwarding 변경. 
- 29418:29418 을 20001:29418 로 변경.
- 80:8080 을 20000:8080 로 변경. 

* volumes 변경.
- /external/gerrit/etc:/var/gerrit/etc 을 /home/gerrit/external/gerrit/etc:/var/gerrit/etc 로 변경.
- /external/gerrit/git:/var/gerrit/git 을 /home/gerrit/external/gerrit/git:/var/gerrit/git 로 변경.
- /external/gerrit/db:/var/gerrit/db 을/home/gerrit/external/gerrit/db:/var/gerrit/db 로 변경.
- /external/gerrit/index:/var/gerrit/index 을 /home/gerrit/external/gerrit/index:/var/gerrit/index 로 변경.
- /external/gerrit/cache:/var/gerrit/cache 을 /home/gerrit/external/gerrit/cache:/var/gerrit/cache 로 변경.
- /external/gerrit/ldap/var:/var/lib/ldap 을 /home/gerrit/external/gerrit/ldap/var:/var/lib/ldap 로 변경.
- /external/gerrit/ldap/etc:/etc/ldap/slapd.d 을 /home/gerrit/external/gerrit/ldap/etc:/etc/ldap/slapd.d 로 변경.

* WEB URL 변경.
- http://localhost 을 http://192.168.27.12:20000 로 변경.

* 변경된 docker-compose.yaml 파일.
```
gerrit@AOA:~/external$ cat docker-compose.yaml 
version: '3'

services:
  gerrit:
    image: gerritcodereview/gerrit
    ports:
      - "20001:29418"
      - "20000:8080"
    depends_on:
      - ldap
    volumes:
      - /home/gerrit/external/gerrit/etc:/var/gerrit/etc
      - /home/gerrit/external/gerrit/git:/var/gerrit/git
      - /home/gerrit/external/gerrit/db:/var/gerrit/db
      - /home/gerrit/external/gerrit/index:/var/gerrit/index
      - /home/gerrit/external/gerrit/cache:/var/gerrit/cache
    environment:
      - CANONICAL_WEB_URL=http://192.168.27.12:20000
        #entrypoint: /entrypoint.sh init

  ldap:
    image: osixia/openldap
    ports:
      - "389:389"
      - "636:636"
    environment:
      - LDAP_ADMIN_PASSWORD=secret
    volumes:
      - /home/gerrit/external/gerrit/ldap/var:/var/lib/ldap
      - /home/gerrit/external/gerrit/ldap/etc:/etc/ldap/slapd.d

  ldap-admin:
    image: osixia/phpldapadmin
    ports:
      - "6443:443"
    environment:
      - PHPLDAPADMIN_LDAP_HOSTS=ldap

```

3.2. gerrit 파일 변경.
-----

```
gerrit@AOA:~/external$ cat gerrit/etc/gerrit.config
[gerrit]
  basePath = git
	canonicalWebUrl = http://192.168.27.12:20000
	serverId = dac7616e-d97a-421d-b317-4cdb3bf1e4f6

[index]
  type = LUCENE

[auth]
  type = ldap
  gitBasicAuth = true
	gitBasicAuthPolicy = HTTP

[ldap]
  server = ldap://ldap
  username = cn=admin,dc=example,dc=org
  accountBase = dc=example,dc=org
  accountPattern = (&(objectClass=person)(uid=${username}))
  accountFullName = displayName
  accountEmailAddress = mail
	groupBase = dc=example,dc=org

[sendemail]
  smtpServer = localhost

[sshd]
  listenAddress = *:29418

[httpd]
  listenUrl = http://*:8080/

[cache]
  directory = cache

[container]
  user = root
	javaOptions = "-Dflogger.backend_factory=com.google.common.flogger.backend.log4j.Log4jBackendFactory#getInstance"
	javaOptions = "-Dflogger.logging_context=com.google.gerrit.server.logging.LoggingContext#getInstance"
	javaHome = /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.x86_64/jre
	javaOptions = -Djava.security.egd=file:/dev/./urandom
[receive]
	enableSignedPush = false
[core]
	packedGitOpenFiles = 512
```

3.3. secure.config 파일 변경.
-----

```
gerrit@AOA:~/external$ sudo cat gerrit/etc/secure.config 
[sudo] password for gerrit: 
[ldap]
  password = secret
```


3.4. Gerrit DB 와 Git repositories 초기화.
-----
The external filesystem needs to be initialized with gerrit.war beforehand:
(github.com/lchy0113/dev_tips/file/gerrit-3.0.0war)
All-Projects and All-Users Git repositories created in Gerrit
System Group UUIDs created in Git repositories


4. 실행.
-----

4.1. Gerrit docker 실행. 
----- 
docker-compose.yaml 파일에서 entrypoint 주석을 해제한 후 아래 명령어 실행.
```
$ docker-compose up gerrit
```

4.2. Gerrit docker 데몬으로 실행.
-----
```
$ docker-compose up -d
```


5. Test.
-----

5.1. Testing Connections.
-----
아래 명령어를 입력하여 연결을 시험한다.
```
lchy0113@AOA:~$ ssh -p 20001 192.168.27.12
Enter passphrase for key '/home/lchy0113/.ssh/id_rsa': 

  ****    Welcome to Gerrit Code Review    ****

  Hi lchy0113, you have successfully connected over SSH.

  Unfortunately, interactive shells are disabled.
  To clone a hosted Git repository, use:

  git clone ssh://lchy0113@192.168.27.12:29418/REPOSITORY_NAME.git

Connection to 192.168.27.12 closed by remote host.
Connection to 192.168.27.12 closed.
```


5.2. Create Projects
-----
아래 링크를 참조.
- [linux-script](https://github.com/lchy0113/linux-script)

## 참고 사이트
-----
- [gerrit docker](https://hub.docker.com/r/gerritcodereview/gerrit)
