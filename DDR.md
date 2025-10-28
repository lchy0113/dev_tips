----
DDR
====

<br/>
<br/>
<br/>
<br/>
<hr>

# 1. DDR4 내부 동작

DDR4는 단순한 메모리 셀이 아니라, *클럭 위상과 데이터 타이밍을 정렬해서 읽고 쓰는* 고속 동기 DRAM이다.  
 - DRAM 내부에는 **DLL(Delay Locked Loop)** 이 존재.  
 - DLL 은 **외부 클럭(CK)**과 **내부 데이터 신호(DQS)** 의 위상을 맞추기 위해 **정확한 지연(Delay)** 을 생성.  
 - 이 동기 과정이 완료되기 까지 필요한 시간이 바로 **tDLLK(DLL Lock Time)**  이다.
 즉, "클럭 위상 기준점을 고정하는데 필요한 안정화 시간"  

<br/>
<br/>
<br/>
<br/>
<hr>

# 2. Hynix와 Piecemaker의 tRCD/tRP/tRC 값의 의미가 있나?  

 tRCD, tRP, tRC 는 Row 활성화부터 데이터 접근, 프리차지까지 걸리는 내부 셀 동작 타이밍.  

| 파라미터 | 의미                                                    | DLL과의 간접 관계                                                  |
| -------- | ------------------------------------------------------- | ------------------------------------------------------------------ |
| **tRCD** | Row 활성화(Activate) → Column 접근(Read/Write) 간 지연  | DLL이 내부 DQS와 CK 위상 맞추는 동안 “데이터 라인 안정화” 여유 필요|
| **tRP**  | Precharge(다음 Row 준비)까지의 시간                     | DLL이 리셋·재위상 맞추는 동안 bank 전환 안정성에 영향              |
| **tRC**  | Row Cycle 전체 시간 (tRCD + tRAS + tRP)                 | 한 cycle 동안 DLL이 다시 위상을 조정할 수 있는 전체 마진           |

*Piecemaker는 이 세 항목이 모두 0.25 ns 길다.*  
JEDEC 한계치(14.06 ns) 에 더 가까운 "타이트한" 설계라는 뜻.  

<br/>
<br/>
<br/>
<br/>
<hr>

# 3. DLL Lock 과 연결되는 매커니즘

부트 시, DDR 초기화 과정은 아래 순서르 따른다.  

```bash
Reset → CKE HIGH → Mode Register Set (MRS) → ZQ Calibration → DLL Lock (tDLLK) → Normal Operation
```

 이때, **DLL이 안정화 되기 전에 **   
 컨트롤러가 READ/WRITE 또는 Refresh 명령을 빠르게 보내면,   
 DQS/CK 위상이 맞지 않아 데이터 캡처 실패 ->  **초기화 실패** 가 발생할수 있음.   
 
 Piecemaker는 다음 두 가지 이유로 DLL 안정화 대기(tDLLK) 가 더 중요.  

 1. **내부 셀 액세스 타이밍이 Hynix보다 느림(tRCD/tRP/tRC 길음)**  
  → DLL이 위상 정렬을 끝내기도 전에 셀 데이터가 준비되지 않거나 sampling timing이 교차함.  
 2. **데이터 시트에 "Wait for both tDLLK and tZQinit completed" 명시됨**   
  → 제조사가 실제로 DLL 안정화 시간이 더 필요함을 인정한 것.  

  즉, Piecemaker의 긴 tRCD/tRP/tRC 값은 DLL Lock 안정 시간과도 일관된 경향을 보여줌.  

  

