list_head
----
linux kernel 에서 사용하는 list_head 이중 연결 리스트 분석.

list_head 는 2.6.39.4 kernel 의 경우 /include/linux/types.h 에 정의하고 있다. 
list_head 의 동작 구현은 /include/linux/lish.h 에 있다. 

```c
struct list_head {
	struct list_head *next, *prev;
};
```
![](./image/LIST_HEAD_1.png)
![](./image/LIST_HEAD_22.png)
