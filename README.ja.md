# PanchiraMac

**[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)**

> MacBook の開閉角度で 3D キャラクター周囲のカメラを制御する macOS アプリ。

MacBook を開くとカメラがキャラクターの足元から頭上へ滑らかに移動します。ドラッグで左右回転、スクロールでズーム。

---

## 機能

- **蓋の角度 → 垂直カメラ** — IOKit がヒンジ角度（0°–130°）をリアルタイム取得し、カメラ仰角にマッピング
- **ドラッグ → 水平回転** — 画面をドラッグしてカメラを左右に周回
- **スクロール → ズーム** — 2本指スクロールまたはマウスホイールでズームイン・アウト
- **低角度時の自動ズームイン** — 蓋が 0° に近づくほど最大 25% 追加ズームイン
- **クラムシェル検出** — クラムシェルモード（蓋を閉じた状態）ではメッセージを表示
- **カスタムモデルのアップロード** — 任意の `.usdz` ファイルを読み込んでデフォルトキャラクターを置換
- **デフォルトでフルスクリーン** — 起動時に自動でフルスクリーンに切り替え

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
