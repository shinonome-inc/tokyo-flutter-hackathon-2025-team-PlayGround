import 'package:app/config/env_config.dart';
import 'package:app/enums/app_env.dart';

/// dev環境の設定
class EnvConfigDev extends EnvConfig {
  const EnvConfigDev();

  @override
  AppEnv get env => AppEnv.dev;

  @override
  String get cognitoUserPoolId => 'ap-northeast-1_0rnubSZZr';

  @override
  String get cognitoAppClientId => '6tlq8t9lhkl0h3ju5p6vtokcvs';

  @override
  String get cognitoDomain => 'genkaimeshi-recipe-dev-auth';
}
