C Pointer  
====
  
<pre>
<code>
int a = 0;		//	int형 변수 두개 정의.
int b = 0;

				//	OK. 라고 쓴 줄은 컴파일 잘되고 실행도 잘 된다.
				//	Err! 라고 쓴 줄은 컴파일 안되는 잘못된 코드.

int *p1 = &a;	//	비상수를 가리키는 비상수 포인터.
p1 = &b;		//	OK. 다른 객체를 가리키게 바꿀 수 있고,
*p1 = 1; 		//	OK. 가리키는 객체의 값을 바꿀 수도 있다.

const int *p2 = &a;		//	상수를 가리키는 비상수 포인터.  
p2 = &b;				//	OK. 다른 객체를 가리키게 바꿀 수는 있지만,   
*p2 = 2;				//	Err! 가리키는 객체의 값을 바꿀 수는 없습니다.  
b = 2;					//	OK. 가리키고 있는 객체인 b는 사실은 비상수라서,   
						//	값을 바꿀 수는 있지만,  
						//	어쨋든 p2 를 통해 바꿀 수는 없다.  
  
int *const p3 = &a;		//	비상수를 가리키는 상수 포인터.  
p3 = &b					//	Err! 다른 객체를 가리키게 바꿀 수 없지만  
*p3 = 3; 				//	OK. 가리키는 객체의 값을 바꿀 수는 없다.  
  
const int *const p4 = &a;	//	상수를 가리키는 상수 포인터.  
p4 = &b						//	Err! 다른 객체를 가리키게 바꿀 수도 없고  
*p4 = 4;					//	Err! 가리키는 객체의 값을 바꿀 수도 없다.  
</code>
</pre>



연산자 우선순위   
====
| 1  	| () [] -> .                                    	| 왼쪽우선    	|
|----	|-----------------------------------------------	|-------------	|
| 2  	| ! ~ ++ -- + -(부호) *(포인터) * sizeof 캐스트 	| 오른쪽 우선 	|
| 3  	| *(곱셈) / %                                   	| 왼쪽 우선   	|
| 4  	| +(덧셈) -(뺄셈)                               	| 왼쪽 우선   	|
| 5  	| << >>                                         	| 왼쪽 우선   	|
| 6  	| < <= > >=                                     	| 왼쪽 우선   	|
| 7  	| == !=                                         	| 왼쪽 우선   	|
| 8  	| &                                             	| 왼쪽 우선   	|
| 9  	| ^                                             	| 왼쪽 우선   	|
| 10 	| |                                             	| 왼쪽 우선   	|
| 11 	| &&                                            	| 왼쪽 우선   	|
| 12 	| ||                                            	| 왼쪽 우선   	|
| 13 	| ? :                                           	| 오른쪽 우선 	|
| 14 	| = 복합대입                                    	| 오른쪽 우선 	|
| 15 	| ,                                             	| 왼쪽 우선   	|



C double pointer 
====

<pre>
<code>
#include <stdio.h>

#define rows 5
#define cols 10

int main(void)
{
	char **array;
	unsigned int i, j;

	/* 행 동적 메모리 할당 */
	array = (char **)malloc(sizeof(char*) * rows);
	if (array == NULL)	{
		printf("Not enought memory \n");
		return;
	}

	/* 열 동적 메모리 할당 */
	for (i=0; i<rows; i++)	{
		array[i] = (char *)malloc(sizeof(char) * cols);
		if (array[i] == NULL)	{
			printf("Not enought memory \n");
			return;
		}
		/* 배열에 값 저장 */
		for (j=0; j<cols; j++)
			array[i][j] = 'a';
	}

	array[3][3] = 'b';

	/* 값 출력 */	
	for(i=0; i<rows; i++)	{
		for(j=0; j<cols; j++)	
			printf("%c", array[i][j]);
		printf("\n");
	}

	/* 메모리 해제 */
	for(i=0; i<rows; i++)
		free(array[i]);
	free(array);

	return 0;
}
</code>
</pre>
