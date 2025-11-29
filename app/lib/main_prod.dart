import 'package:app/config/env_config.dart';
import 'package:app/config/env_config_prod.dart';
import 'package:app/main_common.dart';

/// prod環境のエントリーポイント
Future<void> main() async {
  const EnvConfig envConfig = EnvConfigProd();
  await mainCommon(envConfig);
}
