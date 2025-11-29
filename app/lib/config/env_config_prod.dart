import 'package:app/config/env_config.dart';
import 'package:app/enums/app_env.dart';

/// prod環境の設定
class EnvConfigProd extends EnvConfig {
  const EnvConfigProd();

  @override
  AppEnv get env => AppEnv.prod;

  @override
  String get cognitoUserPoolId => 'ap-northeast-1_j52wZRfww';

  @override
  String get cognitoAppClientId => '16uvvgc5qql0p9j3q1hrbnkdek';

  @override
  String get cognitoDomain => 'genkaimeshi-recipe-prod-auth';

  @override
  String get cognitoIdentityPoolId => 'ap-northeast-1:38e8ebff-3cb2-4edf-a3b1-76567758d941';

  @override
  String get s3BucketName => 'genkaimeshi-recipe-prod-recipe-images';
}
