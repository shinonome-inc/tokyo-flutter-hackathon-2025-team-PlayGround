import 'package:app/enums/app_env.dart';
import 'package:app/utils/app_env_utils.dart';

/// AppEnv の拡張メソッド
extension AppEnvExtension on AppEnv {
  /// dev環境かどうかを判定する。
  bool get isDev => AppEnvUtils.isDev(this);

  /// prod環境かどうかを判定する。
  bool get isProd => AppEnvUtils.isProd(this);
}
