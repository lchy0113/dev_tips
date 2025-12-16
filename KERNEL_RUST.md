
KERNEL_RUST
====

kernel rust 디렉토리 설명

```bash
kernel/
├── rust/
│   ├── alloc/
│   ├── bindings/
│   ├── core/
│   ├── macros/
│   ├── kernel/
│   └── Makefile
```


rust/kernel/  
 - C의 include/linux/ 에 해당
 - Rust 커널 API  
 - 예:
   * kernel::device
   * kernel::file
   * kernel::error
> Rust 드라이버가 직접 사용하는 핵심 레이어  

rust/bindings/
 - C커널 API를 Rust에서 쓰기 위한 바인딩  
 - bindgen 으로 생성됨  
 - 예:
   * struct device  
   * struct file_operations  
> C언어와 Rust 코드 연결부  

rust/core/, rust/alloc/

rust/macros/
