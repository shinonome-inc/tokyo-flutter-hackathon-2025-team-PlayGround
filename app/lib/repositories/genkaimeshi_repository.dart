import 'package:app/enums/app_env.dart';
import 'package:app/models/recipe_detail.dart';
import 'package:dio/dio.dart';

/// 限界飯APIのリポジトリクラス。
class GenkaimeshiRepository {
  GenkaimeshiRepository({
    Dio? dio,
    AppEnv environment = AppEnv.dev,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _getBaseUrl(environment);
  }

  final Dio _dio;

  static const Map<AppEnv, String> _baseUrls = {
    AppEnv.dev:
        'https://a71hr6sq8c.execute-api.ap-northeast-1.amazonaws.com/dev',
    AppEnv.prod: 'https://a71hr6sq8c.execute-api.ap-northeast-1.amazonaws.com/',
  };

  static String _getBaseUrl(AppEnv environment) {
    return _baseUrls[environment]!;
  }
}
