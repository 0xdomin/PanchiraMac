# PanchiraMac

**[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)**

> 一款 macOS 应用，通过 MacBook 屏幕开合角度控制 3D 角色周围的摄像机。

打开 MacBook 盖子，摄像机会从角色脚下平滑移动至头顶。拖拽可左右旋转，滚动可缩放。

---

## 功能

- **盖子角度 → 垂直摄像机** — 通过 IOKit 实时读取铰链角度（0°–130°），映射到摄像机仰角
- **拖拽 → 水平旋转** — 在屏幕任意位置拖拽，使摄像机绕角色左右环绕
- **滚动 → 缩放** — 双指滑动或鼠标滚轮进行缩放
- **低角度自动放大** — 盖子角度接近 0° 时，最多额外放大 25%
- **翻盖检测** — 在翻盖模式（盖子关闭）下显示提示信息
- **自定义模型上传** — 加载任意 `.usdz` 文件以替换默认角色
- **默认全屏启动** — 启动时自动切换至全屏

## 系统要求

- macOS 15.0 或更高版本
- Apple Silicon Mac（M1 或更高）
- 从源码构建需要 Xcode 16.0 或更高版本

## 构建与运行

```bash
git clone https://github.com/0xdomin/PanchiraMac.git
cd PanchiraMac
xcodebuild -project PanchiraMac.xcodeproj -scheme PanchiraMac -configuration Release build
```

或在 Xcode 中打开 `PanchiraMac.xcodeproj`，点击 ▶ 按钮。

## 工作原理

通过 **IOKit HID** 以约 30Hz 的频率读取 MacBook 铰链角度，并实时反映到 **RealityKit** 的摄像机位置。`PerspectiveCameraComponent` 实体根据角度、拖拽方位角和缩放半径每帧重新定位。

```
LidAngleSensor (IOKit, 30Hz)
  └─ angle (0°–130°)
       ├─ elevation  → 摄像机高度
       ├─ drag delta → 摄像机水平方位角
       └─ scroll     → 轨道半径（缩放）
```

## 自定义角色

点击底部栏的 **📁+** 按钮，从磁盘选择 `.usdz` 文件，无需重启即可立即替换角色。
