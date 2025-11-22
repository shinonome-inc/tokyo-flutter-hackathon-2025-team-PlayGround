import 'package:app/config/env_config.dart';
import 'package:app/enums/app_env.dart';

/// prod環境の設定
class EnvConfigProd extends EnvConfig {
  const EnvConfigProd();

  @override
  AppEnv get env => AppEnv.prod;

  @override
  String get cognitoUserPoolId => 'ap-northeast-1_To5RV6lYN';

  @override
  String get cognitoAppClientId => '22tilfokgug18gkaq4148o5479';

  @override
  String get cognitoDomain => 'genkaimeshi-recipe-prod-auth';
}
