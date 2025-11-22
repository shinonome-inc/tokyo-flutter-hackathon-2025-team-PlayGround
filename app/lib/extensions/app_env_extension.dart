import 'package:app/enums/app_env.dart';

/// AppEnv の拡張メソッド
extension AppEnvExtension on AppEnv {
  /// dev環境かどうかを判定する。
  bool get isDev => this == AppEnv.dev;

  /// prod環境かどうかを判定する。
  bool get isProd => this == AppEnv.prod;
}
