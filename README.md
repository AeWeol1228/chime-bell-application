# Chime Bell 🔔

정각마다 사용자가 설정한 알람 소리를 재생해주는 Flutter 기반의 백그라운드 서비스 앱입니다.

## 🚀 주요 기능

- **매 정시 알람**: 매시간 00분마다 지정된 사운드 재생
- **방해 금지 모드 (DND)**: 특정 시간대(예: 취침 시간)에는 알람이 울리지 않도록 설정
- **주말 제외 설정**: 토요일과 일요일에는 알람을 자동으로 비활성화
- **볼륨 조절**: 알람 소리의 크기를 개별적으로 조절 및 미리듣기 지원
- **다크 모드 지원**: 시스템 설정에 따른 라이트/다크 테마 자동 전환
- **디버그 메뉴**: 개발자용 테스트 알람 및 빌드 정보 확인 기능

## 🛠 기술 스택

- **Framework**: Flutter (Dart)
- **Background Service**: `android_alarm_manager_plus`
- **Audio**: `audioplayers`
- **Storage**: `shared_preferences` (사용자 설정 저장)

## 📂 프로젝트 구조

```text
lib/
├── services/            # 비즈니스 로직 및 서비스 레이어
│   ├── settings_service.dart   # 설정 데이터 관리 (Singleton)
│   ├── alarm_service.dart      # 알람 스케줄링 제어
│   └── background_service.dart # 백그라운드 Isolate 실행 로직
├── ui/                  # UI 레이어
│   ├── settings_screen.dart    # 메인 설정 화면
│   └── debug_screen.dart       # 개발자 진단 화면
├── main.dart            # 앱 초기화 및 진입점
└── build_info.dart      # 빌드 메타데이터 (자동 생성)
```

## 📄 파일별 역할 상세

### Services
- **`SettingsService`**: 사용자의 알람 활성화 여부, DND 시간, 볼륨 등의 설정을 `SharedPreferences`에 저장하고 관리합니다. 싱글톤 패턴으로 구현되어 앱 전체에서 동일한 상태를 유지합니다.
- **`AlarmService`**: Android 시스템의 알람 관리자에게 정시 실행 명령을 전달합니다. `android_alarm_manager_plus`를 사용하여 정확한 시간에 백그라운드 Isolate를 깨웁니다.
- **`BackgroundService`**: 앱이 종료된 상태에서도 실행되는 독립적인 로직입니다. 현재 시간이 DND 범위 내에 있는지, 혹은 주말인지를 판단하여 실제로 소리를 재생할지 최종 결정합니다.

### UI
- **`SettingsScreen`**: 직관적인 인터페이스를 통해 사용자가 알람 환경을 설정할 수 있도록 합니다. 각 설정 변경 시 즉시 서비스 레이어와 통신하여 반영합니다.
- **`DebugScreen`**: 1분 후 즉시 울리는 테스트 알람을 통해 서비스 작동 여부를 빠르게 진단할 수 있습니다.

## ⚙️ 빌드 및 배포

본 프로젝트는 빌드 시간 기록 및 APK 생성을 자동화하기 위한 스크립트를 포함하고 있습니다.

1.  **기기 연결 (ADB)**:
    ```powershell
    adb connect <IP_ADDRESS>:<PORT>
    ```
2.  **자동 빌드 스크립트 실행**:
    ```powershell
    ./build.ps1
    ```
3.  **앱 설치**:
    ```powershell
    flutter install
    ```

## 📝 개발 일지
자세한 개발 과정 및 트러블슈팅 내역은 `Chime_Bell_Dev_Log.txt`를 참조하세요.
