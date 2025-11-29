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

| コマンド                                | 説明                    |
| --------------------------------------- | ----------------------- |
| `fvm flutter run -t lib/main_dev.dart`  | dev 環境でアプリを実行  |
| `fvm flutter run -t lib/main_prod.dart` | prod 環境でアプリを実行 |

**注意**: 環境を切り替えるには、アプリを停止（Ctrl+C）してから、別のコマンドで再起動してください。

### 環境切り替えについて

環境は `-t` オプションでエントリーポイントを指定して切り替えます。有効な環境は `dev` または `prod` です。

```bash
# dev 環境（デフォルト）
fvm flutter run

# または明示的に指定
fvm flutter run -t lib/main_dev.dart

# prod 環境
fvm flutter run -t lib/main_prod.dart
```

ビルド時も同様に指定できます：

```bash
# dev 環境でビルド（デフォルト）
fvm flutter build apk
fvm flutter build ios

# または明示的に指定
fvm flutter build apk -t lib/main_dev.dart
fvm flutter build ios -t lib/main_dev.dart

# prod 環境でビルド
fvm flutter build apk -t lib/main_prod.dart
fvm flutter build ios -t lib/main_prod.dart
fvm flutter build web -t lib/main_prod.dart
```
