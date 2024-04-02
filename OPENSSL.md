# OPENSSL.md


## background
  
 libssl.so  관련 lib에러가 발생하는 경우, 솔루션 기술


 - python 오류 발생
```bash
ImportError: libssl.so.1.1: cannot open shared object file: No such file or directory
```


## solution

1. openssl-1.1.1o.tar.gz 다운로드 및 압축 해제

```bash
mkdir $HOME/opt 
cd $HOME/opt 
wget https://www.openssl.org/source/openssl-1.1.1o.tar.gz 
tar -zxvf openssl-1.1.1o.tar.gz 
rm openssl-1.1.1o .tar.gz
```

2. libssl.so.1.1 컴파일

```bash
cd openssl-1.1.1o 
./config 
make
```

3. libssl.so.1.1 을 지정된 위치로 이동(option)

```bash
mkdir $HOME/opt/lib 
mv libssl.so.1.1 $HOME/opt/lib 
mv libcrypto.so.1.1 $HOME/opt/lib
```

4. 환경 변수 구성

```bash
CD $HOME 
vim .bashrc

export LD_LIBRARY_PATH=$HOME/opt/lib:$LD_LIBRARY_PATH
```
