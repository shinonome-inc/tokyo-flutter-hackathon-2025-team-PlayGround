import 'package:app/config/env_config.dart';
import 'package:app/enums/app_env.dart';

/// dev環境の設定
class EnvConfigDev extends EnvConfig {
  const EnvConfigDev();

  @override
  AppEnv get env => AppEnv.dev;

  @override
  String get cognitoUserPoolId => 'ap-northeast-1_zSxVTsMtg';

  @override
  String get cognitoAppClientId => '7bms99sgfbmjuv7t4avqjuve2a';

  @override
  String get cognitoDomain => 'genkaimeshi-recipe-dev-auth';
}
