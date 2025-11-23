# CORDING GUIDE

## 環境

- dev 環境（開発環境）
- prod 環境（本番環境）
  ※stg 環境は使用しない

## 各フレームワーク共通

### 原則

- KISS（Keep It Simple, Stupid）原則を厳守すること
- DRY（Don't Repeat Yourself）原則を厳守すること
- YAGNI（You Aren't Gonna Need It）原則を遵守すること
- PIE（Prefer Interfaces to Implementations）原則を厳守すること
- SLAP（Single Level of Abstraction Principle）原則を遵守すること
- OCP（Open/Closed Principle）原則を遵守すること
- 名前重要の原則を遵守すること
- 単一責任の原則を厳守すること

### コメントアウト

- 日本語で記述すること
- 関数やクラスにドキュメントコメントを記述する
- 変数やコンストラクタにはドキュメントコメントを記述しない
- ドキュメントコメント以外の通常コメントアウトは原則書かない（関数名などコードだけで意図が伝わるようにする）
- コード上での表現が困難な場合のみ通常コメントアウトを記述する（How ではなく Why にのみ記述）

### その他共通項目

- if 文の{}を省略しないこと
- `&&`や`||`が必要な複雑な条件式がある場合は説明変数を用いること
- 肥大化（目安 80 行）したコードは細分化すること
- ネストの多重化を避けること（早期 return を使用して）
- ビジネスロジックや状態管理ロジック、repository ロジックと関連のないロジックは utils に切り分けること

## セキュリティ

- 機密情報は Git の差分に含まないこと
- GitHub Actions の Secrets などの機密情報を CI/CD のログ出力に含まないこと（必ずマスクすること）

## Flutter

### Dart

- Effective Dart に準ずること

### アーキテクチャ

- MVVM + Repository を採用すること
- Model は freezed を用いること
- View は ConsumerStatefulWidget、ConsumerWidget、StatelessWidget、StatefulWidget のいずれかを用いること
- ViewModel は Riverpod Generator を用いること

## インフラ

- 原則コンソールや CLI ではなく Tarraform で IaC を実現すること
- 原則 AWS を利用すること
- 例外として一部インフラとして Google Cloud を利用する

## Terraform

- `infra/README.md`を必ず参照すること
- 環境やサービスごとにディレクトリやファイルを分けること
