# Chime Bell 🔔

정각마다 사용자가 설정한 알람 소리를 재생해주는 Flutter 기반의 백그라운드 서비스 앱입니다. 안드로이드 시스템의 전력 최적화 정책을 우회하여 정시에 정확하게 알람을 제공하도록 설계되었습니다.

## 🚀 주요 기능

- **고정밀 정시 알람**: `oneShotAt` 체인 예약 방식을 사용하여 시스템 지연 없이 매시간 00분 정각에 사운드 재생
- **방해 금지 모드 (DND)**: 특정 시간대(예: 취침 시간)에는 알람이 울리지 않도록 설정
- **주말 제외 설정**: 토요일과 일요일에는 알람을 자동으로 비활성화
- **볼륨 조절**: 알람 소리의 크기를 개별적으로 조절 및 미리듣기 지원
- **진단 로깅**: 시스템 예약 시간과 실제 실행 시간을 기록하여 정밀도 분석 가능
- **다크 모드 지원**: 시스템 설정에 따른 라이트/다크 테마 자동 전환
- **디버그 메뉴**: 개발자용 테스트 알람, 실행 로그 확인 및 빌드 정보 확인

## 🛠 기술 스택

- **Framework**: Flutter (Dart)
- **Background Service**: `android_alarm_manager_plus`
- **Audio**: `audioplayers`
- **Storage**: `shared_preferences` (사용자 설정 저장)

## 📂 프로젝트 구조

```text
lib/
├── services/            # 비즈니스 로직 및 서비스 레이어
│   ├── settings_service.dart   # 설정 데이터 관리 및 로깅 (Singleton)
│   ├── alarm_service.dart      # 알람 스케줄링 (One-Shot 체인 방식)
│   └── background_service.dart # 백그라운드 Isolate 실행 및 재스케줄링
├── ui/                  # UI 레이어
│   ├── settings_screen.dart    # 메인 설정 화면
│   └── debug_screen.dart       # 개발자 진단 화면 (로그 뷰어 포함)
├── main.dart            # 앱 초기화 및 진입점
└── build_info.dart      # 빌드 메타데이터 (자동 생성)
```

## 📄 파일별 역할 상세

### Services
- **`SettingsService`**: 사용자의 설정 저장뿐만 아니라, 진단용 로그 파일(`execution_log.txt`) 기록 기능을 담당합니다.
- **`AlarmService`**: 안드로이드 OS에 정밀 알람을 요청합니다. 시스템 최적화(Batching)를 피하기 위해 주기적 알람 대신 매번 일회성 알람(`oneShotAt`)으로 예약합니다.
- **`BackgroundService`**: 알람 트리거 시 실행됩니다. DND 및 주말 조건을 체크하여 소리를 재생하며, **동시에 다음 1시간 뒤의 알람을 즉시 예약**하여 서비스 체인을 유지합니다.

### UI
- **`SettingsScreen`**: 배터리 최적화 제외 권한 설정 및 Doze 모드 우회 옵션 등을 포함한 종합 설정 화면입니다.
- **`DebugScreen`**: 상세 실행 로그를 실시간으로 확인하고 삭제할 수 있는 관리자 도구를 제공합니다.

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

## 📝 개발 일지
자세한 트러블슈팅 내역(특히 정시 지연 문제 해결 과정)은 `Chime_Bell_Dev_Log.txt`를 참조하세요.
