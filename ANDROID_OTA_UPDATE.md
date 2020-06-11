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


# Android - Recovery
=====

 안드로이드 시스템의 Recovery에 대해 살펴보자.

-------------------------------------------------------------

 보통 디바이스에 Recovery를 실행시키기 위한 파티션이 따로 있고, 부트로더(대부분 LK)에서 특정 조건으로 Recovery를 실행시킵니다. 
 그 조건은 팩토리 리셋을 시킨다던가, 다운로드 모드에 진입하는 조건들 입니다. 

# 1. make recovery image
-----

 아래 Makefile 을 보면 Recovery 이미지가 생성되는 과정을 확인 할 수 있습니다. 
 [android/build/core/Makefile]
```
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTFS) $(MKBOOTIMG) $(MINIGZIP) $(ADBD) \
		$(INSTALLED_RAMDISK_TARGET) \									// $(PRODUCT_OUT)/ramdisk.img		// <<-[1]
		$(INSTALLED_BOOTIMAGE_TARGET) \									// $(PRODUCT_OUT)/boot.img			// <<-[2]
		$(INTERNAL_RECOVERYIMAGE_FILES) \								// $(PRODUCT_OUT)/recovery.img		// <<-[3]
		$(recovery_initrc) $(recovery_sepolicy) $(recovery_kernel) \	// $(call include-path-for, recovery)/etc/init.rc
		$(TARGET_RECOVERY_INIT_RC) \
		$(INSTALLED_2NDBOOTLOADER_TARGET) \
		$(recovery_build_props) $(recovery_resource_deps) \
		$(recovery_fstab) \
       	$(recovery_nand_fstab) \
		$(recovery_emmc_fstab) \
		$(recovery_sdboot_fstab) \
		$(RECOVERY_INSTALL_OTA_KEYS) \
		$(INSTALLED_VENDOR_DEFAULT_PROP_TARGET) \
		$(BOARD_RECOVERY_KERNEL_MODULES) \
		$(DEPMOD)
		$(call build-recoveryimage-target, $@)
```
 크게 아래 이미지로 구성된다고 볼수 있습니다. 
 1> [1] 램디스크 이미지(Root File System).
 2> [2] 커널 이미지.
 3> [3] android/bootable/recovery 에 있는 코드들.
 4> android/bootable/recovery/etc/init.rc

 recovery를 실행시키는 파트를 확인하려면, android/bootable/recovery/etc/init.rc 코드를 열어서 보면 상세 정보를 확인 할 수 있습니다.
 아래 코드를 보면 init process와 파일 시스템을 마운트하고 recovery를 서비스 형태로 실행시킵니다.
```
 1 import /init.recovery.${ro.hardware}.rc
 2 
 3 on early-init
 4    # Set the security context of /postinstall if present.
 5      restorecon /postinstall
 6
 7      start ueventd
 8  
 9 on init
10     export ANDROID_ROOT /system
11     export ANDROID_DATA /data
12     export EXTERNAL_STORAGE /e_sdcard
13 
14    symlink /system/etc /etc
15 
16 

86 service recovery /sbin/recovery
87     seclabel u:r:recovery:s0
```
 보통 안드로이드 모바일에서 Recovery 모드는 3가지 시나리오를 지원합니다. 
 1> 세팅 메뉴에서 팩토리 리셋을 선택하였을 때, 리부팅 된 다음에 진입.
 2> 전원이 꺼진 상태에서 키맵(제조사 마다 다름)으로 팩토리 리셋에 진입.
 3> GOTA upgrade.

 가끔 Recovery 모드에서 팩토리 리셋이 제대로 안된다. 등 화면이 깨진다. 등등 이슈가 있는 경우, 
 아래 폴더에 로그를 열어 디버깅을 할수 있습니다.
```
/cache/recovery/last_log, last_log.2
```

 아래 recovery 모드 실행 시, 아래 로그를 볼 수 있습니다.
```
 locale is [en-US]
 stage is []
 reason is [(null)]
 I:brightness : 127 (50%)
 cannot find/open a drm device: No such file or directory
 fb0 reports (possibly inaccurate):
   vi.bits_per_pixel = 32
   vi.red.offset	=	16	.length =	8
   vi.green.offset	=	 8	.length	=	8
   vi.blue.offset	=	 0	.length	=	8
 framebuffer: 0 (1024 x 600)
 		erasing_text: en-US (91 x 38 @ 1170)
  	 no_command_text: en-US (166 x 38 @ 1170)
		 error_text : en-US (66 x 38 @ 1170)
	 installing_text: en-US (304 x 38 @ 1368)
 SELinux: Loaded file_contexts
 Command: "/sbin/recovery" "--update_package=/data/update/full_ota_update.zip"
```

 그러면 recovery mode 에서 주로 쓰이는 Factory Reset Feature 에 대해서 좀 살펴보겠습니다.
 Factory Reset 은 크게 세팅 메뉴로 동작시킬 수 있고, 각 제조사가 정의한 모드를 통해 동작 시킬 수 있습니다. 
 
 세팅 메뉴에서 Factory Reset 을 성택할 시 동작 순서는 아래와 같다.
 1> /cache/recovery/command 파일을 생성하고 여기에 argument 값 --wipe_data 를 write 한다.
 2> 리부팅 됨.
 3> LK(Little Kernel) 에서 misc 파티션에 아래와 같은 값을 써줌.
 ```
 bootMessage.command="boot-recovery"
 bootMessage.status[0] = (cahr)0;
 bootMessage.recovery="recovery\n --wipe_data\n"
 ```
 4> Recovery가 실행(android/bootable/recovery)가 되고 /cache/recovery/command 파일을 찾아서 --wipe_data 값이 있는지 확인.
 5> /cache, /data 파티션을 날려버림. 

 Recovery mode 코드에서 이해야할 중요한 포인트는 어떤 방법으로 argument 를 읽어오며, 이에 따라 어떤 동작을 수행하는지, 
 각 파티션은 어떻게 erase 하는지 중요하다. 

 대표적인 동작 별 argument 는 아래와 같습니다.
 - Factory Reset : --wipe_out, GOTA : --update_package
 
# Recovery 코드 분석
-----

 bootloader나 커널의 실행 시작 포인트는 reset vector 입니다. 
 데몬 형태의 프로세스들은 main 으로 시작합니다. 

 [1] : recovery 시작.
 [2] : boot argument load.
 [3] : boot argument 값에 따라 recovery 동작에 대한 정의.
 [4] : recovery mode 동작 이후 디바이스를 shutdown 시키는 argument.
 [5] : 언어 모드를 설정.
 [6][7] : 화면에 출력할 UI와 text 를 초기화.
 [8] : argument를 로그에 출력함.
 [9] : property를 로그에 출력함.
 [10] : update_package이 NULL 인 경우, 실행 안함.
 [11] : 베터리 레벨이 낮으면 return.
 [12] : GOTA package update.
 [13] : Factory Reset.
 [14] : Package 업데이트 중 실패 시, reboot을 칠 예외 코드 등록.
 [15] : Factory Reset.
 [16] : 디바이스 셧다운.
 [17] : 부트로더로 다시 리부팅.
 [18] : 디폴트로 리부팅 시킴. 


```
int main(int argc, char **argv) {
    // We don't have logcat yet under recovery; so we'll print error on screen and
    // log to stdout (which is redirected to recovery.log) as we used to do.
    android::base::InitLogging(argv, &UiLogger);

    // Take last pmsg contents and rewrite it to the current pmsg session.
    static const char filter[] = "recovery/";
    // Do we need to rotate?
    bool doRotate = false;

// (..skip..)
	
    printf("Starting recovery (pid %d) on %s", getpid(), ctime(&start));		// <<-[1]

    load_volume_table();
    has_cache = volume_for_path(CACHE_ROOT) != nullptr;

// (..skip..)


    std::vector<std::string> args = get_args(argc, argv);						// <<-[2]
    std::vector<char*> args_to_parse(args.size());
    std::transform(args.cbegin(), args.cend(), args_to_parse.begin(),
                   [](const std::string& arg) { return const_cast<char*>(arg.c_str()); });

    const char *update_package = NULL;
    bool should_wipe_data = false;
    bool should_prompt_and_wipe_data = false;
    bool should_wipe_cache = false;
    bool should_wipe_ab = false;
    size_t wipe_package_size = 0;
    bool show_text = false;
    bool sideload = false;
    bool sideload_auto_reboot = false;
    bool just_exit = false;
    bool shutdown_after = false;
    int retry_count = 0;
    bool security_update = false;

    int arg;
    int option_index;
    while ((arg = getopt_long(args_to_parse.size(), args_to_parse.data(), "", OPTIONS,
                              &option_index)) != -1) {
        switch (arg) {
        case 'n': android::base::ParseInt(optarg, &retry_count, 0); break;
        case 'u': update_package = optarg; break;
        case 'w': should_wipe_data = true; break;
        case 'c': should_wipe_cache = true; break;
        case 't': show_text = true; break;
        case 's': sideload = true; break;
        case 'a': sideload = true; sideload_auto_reboot = true; break;
        case 'x': just_exit = true; break;
        case 'l': locale = optarg; break;
        case 'p': shutdown_after = true; break;									// <<- [4]
        case 'r': reason = optarg; break;
        case 'e': security_update = true; break;
        case 0: {
            std::string option = OPTIONS[option_index].name;
            if (option == "wipe_ab") {
                should_wipe_ab = true;
            } else if (option == "wipe_package_size") {
                android::base::ParseUint(optarg, &wipe_package_size);
            } else if (option == "prompt_and_wipe_data") {
                should_prompt_and_wipe_data = true;
            }
            break;
        }
        case '?':
            LOG(ERROR) << "Invalid command argument";
            continue;
        }
    }

    if (locale.empty()) {														// <<- [5] : start
        if (has_cache) {
            locale = load_locale_from_cache();
        }

        if (locale.empty()) {
            locale = DEFAULT_LOCALE;
        }
    }																			// <<- [5] : end

    printf("locale is [%s]\n", locale.c_str());
    printf("stage is [%s]\n", stage.c_str());
    printf("reason is [%s]\n", reason);

    Device* device = make_device();
    if (android::base::GetBoolProperty("ro.boot.quiescent", false)) {
        printf("Quiescent recovery mode.\n");
        ui = new StubRecoveryUI();
    } else {
        ui = device->GetUI();

        if (!ui->Init(locale)) {
            printf("Failed to initialize UI, use stub UI instead.\n");
            ui = new StubRecoveryUI();
        }
    }

    // Set background string to "installing security update" for security update,
    // otherwise set it to "installing system update".
    ui->SetSystemUpdateText(security_update);									// <<- [6]

    int st_cur, st_max;
    if (!stage.empty() && sscanf(stage.c_str(), "%d/%d", &st_cur, &st_max) == 2) {
        ui->SetStage(st_cur, st_max);
    }

    ui->SetBackground(RecoveryUI::NONE);										// <<- [7]
    if (show_text) ui->ShowText(true);

    sehandle = selinux_android_file_context_handle();
    selinux_android_set_sehandle(sehandle);
    if (!sehandle) {
        ui->Print("Warning: No file_contexts\n");
    }

    device->StartRecovery();

    printf("Command:");
    for (const auto& arg : args) {
        printf(" \"%s\"", arg.c_str());											// <<- [8]
    }
    printf("\n\n");

    property_list(print_property, NULL);										// <<- [9]
    printf("\n");

// (..skip..)

    if (update_package != NULL) {												// <<- [10]
        // It's not entirely true that we will modify the flash. But we want
        // to log the update attempt since update_package is non-NULL.
        modified_flash = true;

        if (!is_battery_ok()) {													// <<- [11]
            ui->Print("battery capacity is not enough for installing package, needed is %d%%\n",
                      BATTERY_OK_PERCENTAGE);
            // Log the error code to last_install when installation skips due to
            // low battery.
            log_failure_code(kLowBattery, update_package);
            status = INSTALL_SKIPPED;
        } else if (bootreason_in_blacklist()) {
            // Skip update-on-reboot when bootreason is kernel_panic or similar
            ui->Print("bootreason is in the blacklist; skip OTA installation\n");
            log_failure_code(kBootreasonInBlacklist, update_package);
            status = INSTALL_SKIPPED;
        } else {
            status = install_package(update_package, &should_wipe_cache,		// <<- [12]
                                     TEMPORARY_INSTALL_FILE, true, retry_count);
            if (status == INSTALL_SUCCESS && should_wipe_cache) {
                wipe_cache(false, device);										// <<- [13]
            }
            if (status != INSTALL_SUCCESS) {
                ui->Print("Installation aborted.\n");
                // When I/O error happens, reboot and retry installation RETRY_LIMIT
                // times before we abandon this OTA update.
                if (status == INSTALL_RETRY && retry_count < RETRY_LIMIT) {
                    copy_logs();
                    set_retry_bootloader_message(retry_count, args);
                    // Print retry count on screen.
                    ui->Print("Retry attempt %d\n", retry_count);

                    // Reboot and retry the update
                    if (!reboot("reboot,recovery")) {							// <<- [14]
                        ui->Print("Reboot failed\n");
                    } else {
                        while (true) {
                            pause();
                        }
                    }
                }
 
// (..skip..)

    } else if (should_wipe_data) {
        if (!wipe_data(device)) {												// <<- [15]
            status = INSTALL_ERROR;
        }

// (..skip..)

    // Save logs and clean up before rebooting or shutting down.
    finish_recovery();

    switch (after) {
        case Device::SHUTDOWN:													// <<- [16]
            ui->Print("Shutting down...\n");
            android::base::SetProperty(ANDROID_RB_PROPERTY, "shutdown,");
            break;

        case Device::REBOOT_BOOTLOADER:											// <<- [17]
            ui->Print("Rebooting to bootloader...\n");
            android::base::SetProperty(ANDROID_RB_PROPERTY, "reboot,bootloader");
            break;

        default:
            ui->Print("Rebooting...\n");										// <<- [18]
            reboot("reboot,");
            break;
    }
    while (true) {
        pause();
    }
    // Should be unreachable.
    return EXIT_SUCCESS;
}

```


 Recovery를 디버깅할 때 가장 중요한 함수는 get_args() 입니다. 
 좀 더 상세히 살펴보면, 
 [1] : misc 파티션에서 boot message 를 읽어 옵니다. 
 [2] : boot command 에 대한 로그를 출력합니다.
 [3] : \n 단위로 스트링을 파싱해 준다. 
    ex. argument 가 "recovery \n --wipe_data" 인 경우, 
	 이렇게 되는 것입니다.  
	 tokens[0] = recovery, tokens[1] = --wipe_data
 [4] : COMMAND_FILE  를 읽어서 처리를 하는 루틴인데, 세팅 메뉴로 팩토리 리셋을 선택 하는 경우 동작합니다. 

```
// command line args come from, in decreasing precedence:
//   - the actual command line
//   - the bootloader control block (one per line, after "recovery")
//   - the contents of COMMAND_FILE (one per line)
static std::vector<std::string> get_args(const int argc, char** const argv) {
  CHECK_GT(argc, 0);

  bootloader_message boot = {};
  std::string err;
  if (!read_bootloader_message(&boot, &err)) {									// <<- [1]
    LOG(ERROR) << err;
    // If fails, leave a zeroed bootloader_message.
    boot = {};
  }
  stage = std::string(boot.stage);

  if (boot.command[0] != 0) {
    std::string boot_command = std::string(boot.command, sizeof(boot.command));
    LOG(INFO) << "Boot command: " << boot_command;								// <<- [2]
  }

  if (boot.status[0] != 0) {
    std::string boot_status = std::string(boot.status, sizeof(boot.status));
    LOG(INFO) << "Boot status: " << boot_status;
  }

  std::vector<std::string> args(argv, argv + argc);

  // --- if arguments weren't supplied, look in the bootloader control block
  if (args.size() == 1) {
    boot.recovery[sizeof(boot.recovery) - 1] = '\0';  // Ensure termination
    std::string boot_recovery(boot.recovery);
    std::vector<std::string> tokens = android::base::Split(boot_recovery, "\n");
    if (!tokens.empty() && tokens[0] == "recovery") {
      for (auto it = tokens.begin() + 1; it != tokens.end(); it++) {			// <<- [3]
        // Skip empty and '\0'-filled tokens.
        if (!it->empty() && (*it)[0] != '\0') args.push_back(std::move(*it));
      }
      LOG(INFO) << "Got " << args.size() << " arguments from boot message";
    } else if (boot.recovery[0] != 0) {
      LOG(ERROR) << "Bad boot message: \"" << boot_recovery << "\"";
    }
  }

  // --- if that doesn't work, try the command file (if we have /cache).
  if (args.size() == 1 && has_cache) {
    std::string content;
    if (ensure_path_mounted(COMMAND_FILE) == 0 &&								// <<- [4]
        android::base::ReadFileToString(COMMAND_FILE, &content)) {
      std::vector<std::string> tokens = android::base::Split(content, "\n");
      // All the arguments in COMMAND_FILE are needed (unlike the BCB message,
      // COMMAND_FILE doesn't use filename as the first argument).
      for (auto it = tokens.begin(); it != tokens.end(); it++) {
        // Skip empty and '\0'-filled tokens.
        if (!it->empty() && (*it)[0] != '\0') args.push_back(std::move(*it));
      }
      LOG(INFO) << "Got " << args.size() << " arguments from " << COMMAND_FILE;
    }
  }

  // Write the arguments (excluding the filename in args[0]) back into the
  // bootloader control block. So the device will always boot into recovery to
  // finish the pending work, until finish_recovery() is called.
  std::vector<std::string> options(args.cbegin() + 1, args.cend());
  if (!update_bootloader_message(options, &err)) {
    LOG(ERROR) << "Failed to set BCB message: " << err;
  }

  return args;
}

```

 마지막으로 misc 파티션에 명시된 recovery argument 을 읽어와 boot.command 변수에 write 해주는 함수는
 write_bootloader_message() 입니다. 

 예를 들어, boot.recovery = "recovery"+"--wipe_data"

```
bool write_bootloader_message(const std::vector<std::string>& options, std::string* err) {
  bootloader_message boot = {};
  strlcpy(boot.command, "boot-recovery", sizeof(boot.command));
  strlcpy(boot.recovery, "recovery\n", sizeof(boot.recovery));
  for (const auto& s : options) {
    strlcat(boot.recovery, s.c_str(), sizeof(boot.recovery));
    if (s.back() != '\n') {
      strlcat(boot.recovery, "\n", sizeof(boot.recovery));
    }
  }
  return write_bootloader_message(boot, err);
}
```
