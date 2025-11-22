import 'package:app/enums/app_env.dart';

/// 環境設定の抽象クラス
abstract class EnvConfig {
  const EnvConfig();

  AppEnv get env;
  String get cognitoUserPoolId;
  String get cognitoAppClientId;
  String get cognitoDomain;

  /// AWSリージョン（全環境共通）
  String get awsRegion => 'ap-northeast-1';
}
