# PanchiraMac

**[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)**

> MacBook の蓋を閉めてみてください。

---

## 機能

- MacBook の開閉に合わせてカメラが動く — タッチ操作不要
- 好きな `.usdz` ファイルを読み込んで自分だけの 3D キャラクターに交換可能
- 完全無料のオープンソース

## 動作要件

- macOS 15.0 以降
- Apple Silicon Mac（M1 以降）
- ソースからビルドする場合は Xcode 16.0 以降

## ビルドと実行

```bash
git clone https://github.com/0xdomin/PanchiraMac.git
cd PanchiraMac
xcodebuild -project PanchiraMac.xcodeproj -scheme PanchiraMac -configuration Release build
```

または `PanchiraMac.xcodeproj` を Xcode で開き、▶ ボタンを押してください。

## 仕組み

**IOKit HID** を通じて約 30Hz で MacBook のヒンジ角度を読み取り、**RealityKit** のカメラ位置にリアルタイム反映します。`PerspectiveCameraComponent` エンティティが角度・ドラッグ方位角・ズーム半径に基づいて毎フレーム再配置されます。

```
LidAngleSensor (IOKit, 30Hz)
  └─ angle (0°–130°)
       ├─ elevation  → カメラの高さ
       ├─ drag delta → カメラの水平方位角
       └─ scroll     → 軌道半径（ズーム）
```

## カスタムキャラクター

下部バーの **📁+** ボタンをクリックしてディスクから `.usdz` ファイルを選択すると、アプリを再起動せずに即座に置き換えられます。
