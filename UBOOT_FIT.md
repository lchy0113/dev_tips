# UBOOT FIT

## New uImage
u-boot가 지원하는 부트이미지의 포맷은 다양하고, 타겟보드 별로 지원되는 부트이미지의 포맷을 지정하여 보드를 부팅시킬 수 있다. 
커널을 빌드한 후에 'make uImage'명령을 실행하면, uImage라는 이름의 u-boot가 인식하는 헤더가 붙은 별도의 부트이미지를 만들어낸다.

여기서 설명하려고 하는 내용은 기존의 uImage보다 좀 더 확장된 형태의 부트 이미지이다.

## What is 'new UImage'?
최근의 u-boot는 FDT를 지원하는데, 기존의 non-FDT타입의 플랫폼과 함께 지원하기 위해서…

플랫폼이 부팅하기 위해서는 커널이미지가 반드시 필요하고, 부팅 방식에 따라 램디스크이미지와 FDT바이너리가 필요하다. 
그리고 이러한 것들은 u-boot에서 부팅시 특정 메모리에 적재할 수 있고 해당 메모리를 bootm명령의 파라미터로 지정하여 정상적으로 부팅이 가능하도록 할 수 있다. 필요한 경우 생략 가능하다. 
예를 들면, FDT바이너리가 필요없는 경우, 기존의 전형적인 리눅스 부팅 방식, 혹은 램디스크가 필요하지 않은 경우이다.

uImage포맷도 이러한 이미지들을 직접 포함할 수는 있지만, 제한적인 갯수와 형태에 국한되며 다양한 방식의 부팅을 할 수는 없다.
그러한 이유로 새로운 형식의 부팅이미지가 필요하게 되었고, 좀 더 유연하고 다양한 형식의 바이너리를 포함하는 uImage형식이 만들어지게 되었다.


**New uImage**는 아래의 내용을 지원한다.
 1. 새로운 포맷을 지원하고 구현하기 위한 기능을 추가하기 위해 **libfdt**를 사용하게 되었고, 기존의 **u-boot**소스를 많이 고치지 않아도 되었으며 잘 관리될 수 있었다. 


 - 용어 
 1. FIT (Flattened uImage Tree)는 완전히 FDT와 같은 형식을 가지며 호환하게 동작을 한다. 
  .its - Image Tree Source 
  .itb - Image Tree Blob 
  FIT는 sub-nodes(images, hashes, configurations)를 구별하기 위해 각각의 식별자를 정의해야 하며, 
  각 sub-node의 "unit name"은 각각의 식별자로 구성되어야 한다.


 - 이미지 생성 과정
 아래는 **new uImage**가 생성되는 과정을 보여준다. 이미지 소스 파일(.its)과 구성될 이미지 파일들을 **mkImage**를 이용해서 최종 결과물인
 **new uImage**(.itb)를 만들어내게 된다. **mkImage**는 u-boot에 포함된 툴이며, 내부적으로는 DTC(Device Tree Compiler)를 사용해서 이러한 과정을 수행한다.


 - 루트노드
uImage의 레이아웃은 아래와 같다.
/ o image-tree
```bash
  |- description = "image description"
  |- timestamp = <12399321>
  |- #address-cells = <1>
  |
  o images
  | |
  | o img@1 {...}
  | o img@2 {...}
  | ...
  |
  o configurations
  |- default = "cfg@1"
  |
  o cfg@1 {...}
  o cfg@2 {...}
  ...
```
