import 'package:app/config/env_config.dart';
import 'package:app/config/env_config_dev.dart';
import 'package:app/main_common.dart';

/// dev環境のエントリーポイント
Future<void> main() async {
  const EnvConfig envConfig = EnvConfigDev();
  await mainCommon(envConfig);
}
