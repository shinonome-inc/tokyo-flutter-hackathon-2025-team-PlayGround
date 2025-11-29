import 'package:app/config/env_config.dart';
import 'package:app/config/env_config_dev.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 環境設定のプロバイダー
/// 実行時にmain_dev.dartまたはmain_prod.dartでオーバーライドされる
final envConfigProvider = Provider<EnvConfig>(
  (ref) => const EnvConfigDev(), // デフォルトはdev環境
);
