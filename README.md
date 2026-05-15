# PanchiraMac

**[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)**

> Close your MacBook lid.

---

## Features

- The camera moves as you open and close your MacBook lid — no touch required
- Load any `.usdz` file to swap in your own 3D character
- Completely free and open source

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
