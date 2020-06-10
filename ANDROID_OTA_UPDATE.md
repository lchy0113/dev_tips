# 안드로이드 OTA 업데이트.
=====

 이 문서는 안드로이드 업데이트를 위해 OTA 이미지를 생성, 생성된 이미지를 업데이트 하는 내용을 기술한다.

 현장에 배포된 Android 기기는 OTA (Over-the-Air) 업데이트를 수신하여 시스템 및 응용 프로그램 소프트웨어에 설치할 수 있습니다. 
 OTA 업데이트는 기본 운영 체제 및 시스템 파티션에 설치된 읽기 전용 응용 프로그램을 업그레이드하도록 설계되었습니다. 이러한 업데이트는 사용자가 설치 한 응용 프로그램에는 영향을 미치지 않습니다.

 장치에는 다운로드 한 업데이트 패키지의 포장을 풀고 나머지 시스템에 적용하는 데 필요한 소프트웨어가 포함 된 특수 복구 파티션이 있습니다.

-------------------------------------------------------------

# 1. OTA update package.
-----

 Android 릴리즈 도구는 두 가지 유형의 업데이트 패키지를 빌드 할 수 있습니다. 
 - full update package 는 장치의 전체 최종 상태(system, boot, vendor, and recovery partitions)가 포함된다. 
   * 이 업데이트 package 크기는 큽니다.
   * package 는 현재 상태에 관계없이 새 버전을 설치 할 수 있습니다.

 - incremental update package 는 이전 빌드와 새 빌드의 차이점으로 생성된 여러 바이너리 패치가 포함되어 있습니다. 
   * 이 패치는 이미 장치에 있는 데이터에 적용되므로 update package가 더 작을 수 있습니다.
   * incremental update package 를 생성하려면 릴리즈 도구와 두 가지 빌드 버전, 이전 빌드 업데이트하려는 버전 및 새 빌드을 사용해야 합니다. 즉, 이전 빌드 버전을 유지해야 합니다.

 python tool ota_from_target_files (at build/tools/releasetools) 는 full 과 incremental update package 를 빌드 할 수 있습니다. 도구는 target_files zip file을 입력으로 사용합니다. 
 - 하나의 target_filesrget_files zip으로 전체 업데이트 패키지를 생성합니다.
 - incremental update package 를 생성하기 위한 2 개의 target_files zip (이전 및 새 버전) 이 필요합니다. 이 도구는 새 target_files zip 을 마지막 릴리즈의 zip 과 비교하고 incremental update packge에서 binary 차이를 생성합니다. 
 

# 2. Create a full update package.
-----

 tcc8985 의 소스 코드를 기반으로 플랫폼에 대한 full update package를 작성하려면 다음 단계를 수행하십시오.
 
 1. signed-target_files zip을 작성해야 합니다. 
 2. 소스 코드가 설치된 디렉토리로 이동하십시오.
 3. 다음 명령을 입력하세요. 
 ```
 $ make dist DIST_DIR=${DEV_DIST_DIR} -j${best_num}
 $ ./build/tools/releasetools/ota_from_target_files ${DEV_DIST_DIR}/full_tcc898x-target_files-eng.lchy0113.zip full_ota_update.zip
 ```
 full_ota_update.zip 파일은 tcc8985 에 설치될 update package 입니다. 

# 3. Create an incremental update package.
-----

 incremental update package 를 빌드하려면, ota_from_target_files 도구를 이전 버전 및 새 버전의 target_files zip 파일과 함께 사용하십시오.

 예를 들어, 버전 A에서 버전 B로 업데이트 할 incremental update package를 생성하려면 다음을 수행하십시오.

 1. 버전A, A-signed-target_files.zip 및 버전B, B-signed-target_files.zip에 대해 signed-target_files zip 을 작성해야 합니다. 
 2. 소스 코드가 설치된 디렉토리로 이동하십시오.
 3. 다음 명령을 입력하세요.
 ```
 $ ./build/tools/releasetools/ota_from_target_files -i A-signed-target_files.zip B-signed-target_files.zip A_to_B-incremental-ota-update.zip
 ```
 incremental update package는 incremental update package의 시작 지점과 동일한 이전 빌드를 실행하는 장치만 적용됩니다. 이 예에서 A_to_B-incremental-ota-update.zip은 A버전의 장치에만 설치 할 수 있습니다.


# 4. Update package with wipe data support.
-----

 ota_from_target_files 도구에는 ota update package 생성을 위한 여러 옵션이 포함되어 있습니다. 
 그 중 하나는 ota package가 설치 될 때 사용자 데이터 파티션을 지울 수 있다는 것입니다.

 이 도구의 --wipe_user_data 옵션을 사용하여 데이터 파티션 지우기 지원으로 업데이트 패키지를 작성하십시오. 
 ```
 $ ./build/tools/releasetools/ota_from_target_files --wipe_user_data ${DEV_DIST_DIR}/full_tcc898x-target_files-eng.lchy0113.zip full_ota_update.zip
 ```


# 5. Firmware update process.
-----

 펌웨어 업데이트 프로세스가 시작되면 다음 단계를 따릅니다.
 
 1. 장치가 recovery mode로 재부팅됩니다. recovery partition의 kernel은 boot partition의 kernel 대신 부팅됩니다.
 2. recovery binary는 init에 의해 시작됩니다. /cache/recovery/command 에서 update package를 가리키는 명령 행 인수를 찾습니다. 
 ```
 --update_package=/cache/some-filename.zip
 ```
 3. package에서 data를 가져와 boot, vendor, system partition 을 업데이트 하는데 사용됩니다.  system 파티션의 새로운 파일 중 하나에 새 recovery partition 의 내용이 포함되어 있습니다.
 4. 장치가 정상적으로 재부팅됩니다. 
 5. 새로 업데이트 된 boot partition 이 로드되고, 새로 업데이트 된 system partition 이 mount되고 시작됩니다. 


# 6. Release in a secure environment.
-----

 sign process는 private key 에 대한 access가 제한된 안전한 환경에서 이루어져야 합니다. (일반적으로 개발 서버는 artifacts를 생성하지만 보안 환경에서 외부에 서명됩니다. 
 
 외부 서명에 필요한 artifacts는 다음과 같습니다. :
 - 개발 서버에서 full_tcc898x_files-<build_id>.zip 파일을 생성합니다.
 - release 를 위한 private keys를 생성합니다. [Generate your release keys.][https://www.digi.com/resources/documentation/digidocs/embedded/android/pie/cc8x/android_t_sign-for-release.html#generate-your-release-keys] 
 - target_zip 파일에 서명하고 릴리즈 artifacts를 생성합니다. 

 안드로이드 소스에는 이러한 signing tools가 포함되어 있으며, 일부는 스크립트 및 기타는 컴파일 할 코드 파일입니다. 

