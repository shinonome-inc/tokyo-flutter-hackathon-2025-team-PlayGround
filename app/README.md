# app

## ディレクトリ構造

```
app/
├── lib/
│   ├── main.dart               # アプリケーションエントリーポイント
│   ├── config/                 # アプリケーション設定
│   ├── constants/              # 定数定義
│   ├── enums/                  # Enum 定義
│   ├── extensions/             # 拡張メソッド
│   ├── models/                 # モデル
│   ├── providers/              # 状態管理（Riverpod など）
│   ├── repositories/           # データ取得層
│   ├── screens/                # 画面
│   │   └── xxx_screens/        # 各画面固有のファイルを配置
│   │       ├─ xxx_state.dart
│   │       ├─ xxx_provider.dart
│   │       └─ xxx_screen.dart
│   ├── utils/                  # ユーティリティ関数
│   └── widgets/                # UIコンポーネント
└── test/                       # テストファイル
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
