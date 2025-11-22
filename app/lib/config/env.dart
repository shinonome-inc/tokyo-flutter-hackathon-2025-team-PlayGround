import 'package:app/config/env_config.dart';
import 'package:app/config/env_config_dev.dart';
import 'package:app/config/env_config_prod.dart';
import 'package:app/enums/app_env.dart';
import 'package:app/utils/app_env_utils.dart';

// 環境切り替えは正当な用途であり、この1箇所に限定して使用するため、ignoreで無効化する。
// ignore: do_not_use_environment
final String _envString = String.fromEnvironment(
  'ENV',
  defaultValue: AppEnv.dev.value,
);

/// 現在の環境
final AppEnv currentAppEnv = AppEnv.fromString(_envString);

/// 現在の環境設定
EnvConfig get currentEnv => switch (currentAppEnv) {
  AppEnv.prod => const EnvConfigProd(),
  AppEnv.dev => const EnvConfigDev(),
};
