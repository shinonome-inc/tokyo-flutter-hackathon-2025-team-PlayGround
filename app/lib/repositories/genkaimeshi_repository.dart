import 'package:app/enums/app_env.dart';

/// 限界飯APIのリポジトリクラス。
class GenkaimeshiRepository {
  factory GenkaimeshiRepository() {
    return _instance;
  }

  GenkaimeshiRepository._internal();

  static final GenkaimeshiRepository _instance =
      GenkaimeshiRepository._internal();

  AppEnv _currentEnvironment = AppEnv.dev;
  AppEnv get currentEnvironment => _currentEnvironment;

  static const Map<AppEnv, String> _baseUrls = {
    AppEnv.dev:
        'https://a71hr6sq8c.execute-api.ap-northeast-1.amazonaws.com/dev',
    AppEnv.prod: 'https://a71hr6sq8c.execute-api.ap-northeast-1.amazonaws.com/',
  };
  String get baseUrl => _baseUrls[_currentEnvironment]!;

  void setEnvironment(AppEnv environment) {
    _currentEnvironment = environment;
  }
}
