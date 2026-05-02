# Chime Bell 🔔 (정시의 울림)

정각마다 사용자가 설정한 알람 소리를 재생해주는 Flutter 기반의 백그라운드 서비스 앱입니다. 안드로이드 시스템의 전력 최적화 정책(Doze 모드 등) 하에서도 정시에 정확하게 알람을 제공하도록 설계되었습니다.

## 🚀 주요 기능

- **고정밀 정시 알람**: 일회성 알람 체인 예약 방식을 사용하여 시스템 지연 없이 매시간 정각에 사운드 재생
- **정시 보이스 알림**: 종소리 출력 후 사용자에게 친근한 안내 보이스 재생 (고정 시간 및 매일 1회 랜덤 시각)
- **지능형 스케줄링**: 랜덤 보이스 시각이 사용자의 방해 금지(DND) 시간과 겹치지 않도록 자동 회피
- **오디오 채널 최적화**: '알람(Alarm)' 채널을 사용하여 진동/무음 모드에서도 출력 보장 (시스템 알람 볼륨 연동)
- **배터리 최적화 대응**: 배터리 제한 없음 설정 가이드 및 시스템 Doze 모드 대응 로직 탑재
- **다국어 지원**: 한국어 및 영어 실시간 전환 지원
- **개발자 진단 도구**: 빌드 정보 탭(7회)을 통한 히든 디버그 메뉴 진입, 가상 시각 테스트 및 로그 뷰어 제공

## 🛠 기술 스택

- **Framework**: Flutter (Dart)
- **Background Service**: `android_alarm_manager_plus`
- **Audio**: `audioplayers`
- **Storage**: `shared_preferences`

## 📂 프로젝트 구조

```text
lib/
├── services/            # 비즈니스 로직 및 서비스 레이어
│   ├── settings_service.dart   # 설정 데이터 관리 및 지능형 시간 선택 로직 (Singleton)
│   ├── alarm_scheduler.dart    # Android 시스템 알람 예약 관리 (One-Shot 체인 방식)
│   └── alarm_executor.dart     # 백그라운드 Isolate 실행 및 사운드 재생 엔진
├── ui/                  # UI 레이어
│   ├── settings_screen.dart    # 메인 대시보드 화면 및 디버그 진입로
│   ├── settings_page.dart      # 상세 설정 및 가이드 페이지
│   └── debug_screen.dart       # 개발자 진단 및 로그 관리 화면
├── main.dart            # 앱 초기화 및 백그라운드 서비스 진입점
└── build_info.dart      # 빌드 메타데이터 (빌드 스크립트에 의해 자동 갱신)
```

## ⚙️ 빌드 및 개발 가이드

본 프로젝트는 빌드 시간 기록 및 메타데이터 동기화를 위해 전용 빌드 스크립트를 사용합니다.

### 1. 빌드 시간 갱신 및 실행
정상적인 컴파일과 빌드 정보 반영을 위해 아래 스크립트를 통한 빌드를 권장합니다.
```powershell
# 빌드 시간 갱신 및 APK 빌드
powershell -ExecutionPolicy Bypass -File .\build.ps1

# 특정 기기에 릴리즈 모드 실행
powershell -ExecutionPolicy Bypass -File .\build.ps1 -run -device <DEVICE_ID>
```

### 2. 디버그 메뉴 진입
메인 화면 하단의 `Build: YYYY-MM-DD HH:mm` 텍스트를 **7회 연속 탭**하면 개발자용 진단 메뉴(`DebugScreen`)에 진입할 수 있습니다.
