# PanchiraMac

**[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)**

> 맥북 뚜껑 각도로 3D 캐릭터 주변 카메라를 제어하는 macOS 앱.

맥북 뚜껑을 열면 카메라가 캐릭터 발 아래에서 머리 위까지 부드럽게 이동합니다. 드래그로 좌우 회전, 스크롤로 줌.

---

## 기능

- **뚜껑 각도 → 카메라 상하** — IOKit이 힌지 각도(0°–130°)를 실시간으로 읽어 카메라 높이에 매핑
- **드래그 → 수평 회전** — 화면 어디서나 드래그해 카메라를 좌우로 공전
- **스크롤 → 줌** — 두 손가락 스크롤 또는 마우스 휠로 줌인·아웃
- **저각도 자동 줌인** — 뚜껑이 0°에 가까워질수록 최대 25% 추가 줌인
- **클램쉘 감지** — 클램쉘 모드(뚜껑 닫힘)에서는 안내 메시지 표시
- **커스텀 모델 업로드** — 원하는 `.usdz` 파일을 불러와 기본 캐릭터 교체
- **기본 전체화면** — 실행 시 자동으로 전체화면 전환

## 요구사항

- macOS 15.0 이상
- Apple Silicon Mac (M1 이상)
- 소스 빌드 시 Xcode 16.0 이상

## 빌드 및 실행

```bash
git clone https://github.com/0xdomin/PanchiraMac.git
cd PanchiraMac
xcodebuild -project PanchiraMac.xcodeproj -scheme PanchiraMac -configuration Release build
```

또는 `PanchiraMac.xcodeproj`를 Xcode에서 열고 ▶ 버튼을 누르세요.

## 동작 원리

**IOKit HID**를 통해 약 30Hz로 맥북 힌지 각도를 읽고, **RealityKit**의 카메라 위치에 실시간 반영합니다. `PerspectiveCameraComponent` 엔티티가 각도·드래그 방위각·줌 반경을 기반으로 매 프레임 재배치됩니다.

```
LidAngleSensor (IOKit, 30Hz)
  └─ angle (0°–130°)
       ├─ elevation  → 카메라 높이
       ├─ drag delta → 카메라 수평 방위각
       └─ scroll     → 공전 반경 (줌)
```

## 커스텀 캐릭터

하단 바의 **📁+** 버튼을 클릭해 디스크에서 `.usdz` 파일을 선택하면 앱 재시작 없이 즉시 교체됩니다.
