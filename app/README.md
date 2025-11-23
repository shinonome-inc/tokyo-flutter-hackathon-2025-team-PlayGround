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

## コマンド

このプロジェクトは FVM を使用して Flutter バージョンを管理しています。

### アプリケーションの実行

| コマンド | 説明 |
|---------|------|
| `fvm flutter run` | dev 環境でアプリを実行（デフォルト） |
| `fvm flutter run --dart-define=ENV=prod` | prod 環境でアプリを実行 |

### 環境切り替えについて

環境は `--dart-define=ENV=<env>` で切り替えます。

```bash
# dev 環境（デフォルト）
fvm flutter run

# prod 環境
fvm flutter run --dart-define=ENV=prod
```

ビルド時も同様に指定できます：

```bash
# prod 環境でビルド
fvm flutter build apk --dart-define=ENV=prod
fvm flutter build ios --dart-define=ENV=prod
```
