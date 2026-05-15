# PanchiraMac

**[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)**

> 맥북 뚜껑을 닫아보세요.

---

## 기능

- 맥북 뚜껑을 열고 닫는 것만으로 카메라가 움직입니다 — 터치 불필요
- 원하는 `.usdz` 파일을 불러와 나만의 3D 캐릭터로 교체 가능
- 완전 무료 오픈소스

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
