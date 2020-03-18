## Android Manifest.git
=====

```
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="origin" : 원격 저장소 이름.
    fetch=".."
	review="git://yourserver.com/" /> : repo upload에 의해서 review 시스템에 upload할 gerrit의 호스트네임. 

  <default revision="master" : 브랜치명
    remote="origin" />
  <project path="your/path" name="your/path" />

  : path : 로컬에 저장될 path.
  : name : git 저장소 이름.
  <project path="your/path2" name="your/path2" />
...
...


```
