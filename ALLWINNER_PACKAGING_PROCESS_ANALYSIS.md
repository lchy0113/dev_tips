# Allwinner Packaing Process Analysis
-----

- introduction to firmware packaging.
- Packaging script analysis.
- Analysis of firmware components.


<hr/>
## introduction to firmware packaging.
> firmware packaging은 compile된 bootloader, kernel, root file system을 하나의 image file에 write 하는 것을 의미.
> 이미지를 nand, eMMC, or sd card에 flashing하여 시스템을 동작 가능케 함.

<hr/>
## Packaging script analysis.
- script flow
> lichee directory에서 ./build.sh을 실행하고 컴파일이 완료되면 packaging을 실행 할 수 있다. 전체 packaging process는 아래 그림과 같다. 
![](./image/ALLWINNER_PACKAGING_PROCESS_ANALYSIS-1.png)

> 아래 명령어로 실행.
```
./build.sh pack
```



