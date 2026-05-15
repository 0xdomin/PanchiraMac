# PanchiraMac

**[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)**

> A macOS app that uses your MacBook's lid angle to control the camera around a 3D character.

Open your MacBook lid — the camera smoothly rises from below the character's feet to above their head. Drag to rotate. Scroll to zoom.

---

## Features

- **Lid angle → vertical camera** — IOKit reads the physical hinge angle (0°–130°) and maps it to camera elevation in real time
- **Drag → horizontal rotation** — click and drag anywhere to orbit the camera left/right
- **Scroll → zoom** — two-finger scroll or mouse wheel zooms in and out
- **Auto zoom at low angles** — camera zooms in up to 25% extra as the lid approaches 0°
- **Clamshell detection** — shows a message instead of the 3D view when running in clamshell mode
- **Custom model upload** — load any `.usdz` file to replace the default character
- **Launches fullscreen** — opens in fullscreen by default

## Requirements

- macOS 15.0 or later
- Apple Silicon Mac (M1 or later)
- Xcode 16.0+ to build from source

## Build & Run

```bash
git clone https://github.com/0xdomin/PanchiraMac.git
cd PanchiraMac
xcodebuild -project PanchiraMac.xcodeproj -scheme PanchiraMac -configuration Release build
```

Or open `PanchiraMac.xcodeproj` in Xcode and press ▶.

## How It Works

PanchiraMac reads the MacBook hinge angle via **IOKit HID** (`ALSProximityMode` / `AppleSMC`) at ~30 Hz and maps it to a camera elevation angle in **RealityKit**. The 3D scene uses a `PerspectiveCameraComponent` entity that repositions every frame based on the current angle, drag azimuth, and zoom radius.

```
LidAngleSensor (IOKit, 30Hz)
  └─ angle (0°–130°)
       ├─ elevation  → camera Y position
       ├─ drag delta → camera azimuth (horizontal orbit)
       └─ scroll     → orbit radius (zoom)
```

## Custom Characters

Click the **📁+** button in the bottom bar to load a `.usdz` file from disk. The model replaces the current character instantly without restarting.
