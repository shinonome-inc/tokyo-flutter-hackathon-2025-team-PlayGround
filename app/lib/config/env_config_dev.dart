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

  @override
  String get cognitoIdentityPoolId =>
      'ap-northeast-1:20d4e700-f3da-4c01-88a5-3c64c361d3bf';

  @override
  String get s3BucketName => 'genkaimeshi-recipe-recipe-images';
}
