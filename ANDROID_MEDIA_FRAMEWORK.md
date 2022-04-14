# Android Meida Framework

 안드로이드 미디어 프레임워크는 상위 어플리케이션을 자바 기반의 패키지에서 시작해서, 
 C/C++ 영역으로 구성된 네이티브 미디어 프레임워크와 
 바인더 인터페이스를 통한 미디어 서비스 프레임워크,
 그리고 제일 아래쪽의 하드웨어에 직접 접근해서 소리를 만들어내거나 화면에 영상을
 내보내는 오디오 비디오 코덱과 하드웨어 추상 레이어에 이르기까지 매우 방대한 영역에 걸쳐 있는 
 복잡한 시스템 입니다. 

 미디어 프레임워크의 구조를 역할 기준으로 분류할 경우, 
 출력 부분에 해당하는 미디어 플레이어 부분,
 입력 부분에 해당하는 미디어 레코더 부분,
 그리고 양쪽 모두에 관계가 되는 미디어 스캐너 부분이 있습니다. 


 제일 상위단에는 어플리캐이션에 미디어 관련 프로그래밍 인터페이스를 제공하는 android.media 자바 패키지가 있고, 
 그 아래에는 자바와 네이티브 미디어 프레임워크 사이의 중재를 담당하는 JNI(Java Native Interface)영역이 있습니다.
 그리고 그 아래에는 실제로 안드로이드 멀티미디어의 처리를 담당하는 네이티브 미디어 프레임워크가 위치하는 구조로 되어 있습니다.

 android.media 패키지에서 제공하는 자바 클래스에는 다음과 같은 것들이 있습니다. 
 | AsyncPlayer                 	| 별도의 스레드를 이용한 비동기 오디오 플레이어    	|
 |-----------------------------	|--------------------------------------------------	|
 | AudioFormat                 	| 오디오 포맷 및 채널 설정을 위한 상수 접근        	|
 | AudioManager                	| 볼륨 및 벨소리 모드 제어                         	|
 | AudioRecord                 	| 하드웨어로부터 오디오 녹음                       	|
 | AudioTrack                  	| 단일 오디오 리소스 재생                          	|
 | CamcorderProfile            	| 캠코더 어플리케이션을 위한 캠코더 프로파일       	|
 | CameraProfile               	| 카메라 어플리케이션을 위한 이미지 캡쳐 프로파일  	|
 | ExifInterface               	| JPEG 파일의 Exif 태그 관리                       	|
 | FaceDetector                	| 비트맵 그래픽에서 얼굴 인식                      	|
 | FaceDetector.Face           	| 비트맵 그래픽에서 인식된 얼굴의 위치 정보        	|
 | JetPlayer                   	| JET 컨텐츠 재생 및 제어                          	|
 | MediaMetadataRetriever      	| 미디어 파일로부터 메타데이터 추출                	|
 | MediaPlayer                 	| 오디오 비디오 파일 및 스트림의 재생              	|
 | MediaRecorder               	| 오디오 비디오 레코드                             	|
 | MediaRecorder.AudioEncoder  	| 오디오 인코딩 정의                               	|
 | MediaRecorder.AudioSource   	| 오디오 소스 정의                                 	|
 | MediaRecorder.OutputFormat  	| 출력 포맷 정의                                   	|
 | MediaRecorder.VideoEncoder  	| 비디오 인코딩 정의                               	|
 | MediaRecorder.VideoSource   	| 비디오 소스 정의                                 	|
 | MediaScannerConnection      	| 어플리케이션에서 미디어 스캐너 접근 제공         	|
 | Ringtone                    	| 벨소리나 알림음같은 간단한 재생 지원             	|
 | RingtoneManager             	| 벨소리나 알림음같은 사운드 관리                  	|
 | SoundPool                   	| 어플을 위한 오디오 리소스 재생 및 관리           	|
 | ThumbnailUtils              	| 미디어 프로바이더를 위한 섬네일 생성             	|
 | ToneGenerator               	| DTMF를 비롯한 각종 톤 재생                       	|

  어플리케이션에서 이런 자바 클래스를 통해서 제공된 API는 JNI 레이어를 거쳐서 네이티브 미디어 프레임워크로 전달되는데,
  각 네이티브 미디어 프레임워크의 역할을 조금 더 자세히 살펴보면, 
  우선 libmedia.so는 미디어 프레임워크에서 네이티브 프록시 역할을 합니다.

  JNI 레이어를 통해서 C/C++ 함수 호출로 변경된 응용 프로그램에서의 요구사항을 받아서 
  바인더 인터페이스를 통해서 미디어 서버 프로세스로 전달하게 됩니다. 
  자기가 어떤 일을 많이 한다기 보다는, 함수 호출을 중계해주는 역할을 주로 하기에 프록시(proxy:대리인)라고 
  부릅니다. 차후에 NDK가 강화되면서 네이티브 미디어 어플리케이션을 만들 수 있도록 하는 사전 포석의 성격이 있다고 
  생각됩니다.

  libmediaplayerservice.so 는 미디어 서버 프로세스에서 만들어지는 세가지 주요 서비스, 
  즉, 미디어 플레이어, 미디어 레코더, 그리고 메타데이터 추출기(Metadata Retriever)의 서비스 인터페이스를 제공합니다.
  미디어 플레이어 서비스의 경우 플레이어 타입에 따라서 Stagefright 플레이어나 MIDI 플레이어를 생성하고,
  어플리케이션에서의 요청을 각각의 플레이어로 전달하는 역할을 합니다.
  미디어 레코더 서비스의 경우에도 마찬가지로 StagefrightRecorder를 생성하고 어플리케이션에서의 
  요청을 중계하는 역할을 합니다. 메타데이터 추출기도 역시 플레이어의 종류에 따라서 StagefrightMetadataRetriever 나
  MidMetadataRetriever를 생성하고 비디오 프레임 캡쳐나 오디오 앨범 아트 추출 등 다양한 요청을 중계하는 역할을 합니다. 
  

- 출처 :https://m.blog.naver.com/PostView.naver?isHttpsRedirect=true&blogId=kdr0923&logNo=50160071930
