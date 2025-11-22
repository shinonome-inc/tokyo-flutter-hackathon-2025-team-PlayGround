import 'package:app/enums/app_env.dart';

/// AppEnv に関するユーティリティ
class AppEnvUtils {
  AppEnvUtils._();

  /// 文字列から AppEnv を取得する。
  ///
  /// 不正な値の場合は [ArgumentError] をスローする。
  static AppEnv fromString(String value) {
    final result = AppEnv.values.where((e) => e.value == value).firstOrNull;
    if (result == null) {
      throw ArgumentError.value(value, 'value', '無効な環境名です');
    }
    return result;
  }

  /// dev環境かどうかを判定する。
  static bool isDev(AppEnv env) => env == AppEnv.dev;

  /// prod環境かどうかを判定する。
  static bool isProd(AppEnv env) => env == AppEnv.prod;
}
