/// アプリケーションの実行環境
enum AppEnv {
  dev('dev'),
  prod('prod');

  const AppEnv(this.value);

  final String value;

  /// 文字列から AppEnv を取得する。一致しない場合は dev を返す。
  static AppEnv fromString(String value) =>
      AppEnv.values.where((e) => e.value == value).firstOrNull ?? AppEnv.dev;
}
