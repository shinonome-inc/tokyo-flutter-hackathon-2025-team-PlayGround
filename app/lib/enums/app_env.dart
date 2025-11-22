import 'package:app/utils/app_env_utils.dart';

/// アプリケーションの実行環境
enum AppEnv {
  dev('dev'),
  prod('prod');

  const AppEnv(this.value);

  final String value;

  static AppEnv fromString(String value) => AppEnvUtils.fromString(value);
}
