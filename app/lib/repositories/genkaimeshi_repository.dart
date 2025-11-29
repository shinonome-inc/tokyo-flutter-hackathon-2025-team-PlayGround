import 'package:app/enums/app_env.dart';
import 'package:app/models/recipe.dart';
import 'package:dio/dio.dart';

/// 限界飯APIのリポジトリクラス。
class GenkaimeshiRepository {
  GenkaimeshiRepository({Dio? dio, AppEnv environment = AppEnv.dev})
    : _dio = dio ?? Dio() {
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

  /// レシピ一覧を取得する。
  Future<List<Recipe>> fetchRecipes() async {
    try {
      final response = await _dio.get<List<dynamic>>('/recipes');
      if (response.statusCode == 200 && response.data != null) {
        final recipes = response.data!
            .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
            .toList();
        return recipes;
      } else {
        throw Exception('レシピの取得に失敗しました');
      }
    } on DioException catch (e) {
      throw Exception('ネットワークエラー: ${e.message}');
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
    }
  }
}
