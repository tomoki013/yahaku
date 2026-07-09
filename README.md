# Yohaku

予定を増やすのではなく、余白だけを置くアプリ。

- Swift / SwiftUI / SwiftData
- ローカル完結（外部通信なし、ログインなし）
- 白黒UI
- 18言語対応（String Catalog）

## 構成

```text
Yohaku/
  YohakuApp.swift
  Models/YohakuBlock.swift
  Views/
    RootTabView.swift
    TodayView.swift
    WeekView.swift
    PatternView.swift
    AddYohakuView.swift
  Components/
    YohakuBlockCard.swift
    EmptyStateView.swift
    PatternGridView.swift
  Utilities/DateHelpers.swift
  Resources/Localizable.xcstrings
```

## ビルド方法（Mac + Xcode 15以降）

### 方法1: XcodeGen（推奨）

```sh
brew install xcodegen
xcodegen generate
open Yohaku.xcodeproj
```

### 方法2: 手動

1. Xcodeで新規 iOS App プロジェクト（SwiftUI / Swift）を `Yohaku` という名前で作成
2. 自動生成された `ContentView.swift` などを削除し、この `Yohaku/` フォルダの中身をプロジェクトに追加
3. Deployment Target を iOS 17.0 以上に設定
4. ビルドして実行

## 画面

- **Today** — 今日の余白だけを見る
- **Week** — 一週間の余白の配置を眺める
- **Shape** — 今月の余白が模様になる
