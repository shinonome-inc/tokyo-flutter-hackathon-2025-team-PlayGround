import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:app/enums/app_env.dart';
import 'package:app/models/recipe.dart';
import 'package:dio/dio.dart';

/// 限界飯APIのリポジトリクラス。
class GenkaimeshiRepository {
  GenkaimeshiRepository({Dio? dio, AppEnv environment = AppEnv.dev})
    : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _getBaseUrl(environment);
    _dio.interceptors.add(_AuthInterceptor());
  }

  static final GenkaimeshiRepository instance = GenkaimeshiRepository();

  final Dio _dio;

  static const Map<AppEnv, String> _baseUrls = {
    AppEnv.dev:
        'https://a71hr6sq8c.execute-api.ap-northeast-1.amazonaws.com/dev/v1',
    AppEnv.prod:
        'https://a71hr6sq8c.execute-api.ap-northeast-1.amazonaws.com/v1',
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
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
    }
  }

  Future<Recipe> fetchRecipeByRecipeId(String recipeId) async {
    try {
      final response = await _dio.get<dynamic>('/recipes/$recipeId');
      if (response.statusCode == 200 && response.data != null) {
        final recipe = Recipe.fromJson(response.data! as Map<String, dynamic>);
        return recipe;
      } else {
        throw Exception('レシピIDによってレシピを取得することができませんでした');
      }
    } on Exception catch (e) {
      throw Exception('予期せぬエラーが発生しました: $e');
    }
  }
}

/// Cognitoアクセストークンを自動的にリクエストヘッダーに付与するインターセプター
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        final cognitoSession = session as CognitoAuthSession;
        final accessToken =
            cognitoSession.userPoolTokensResult.value.accessToken.raw;

        options.headers['Authorization'] = 'Bearer $accessToken';
            }
    } on AuthException catch (e) {
      safePrint('Auth error in interceptor: ${e.message}');
    }

    handler.next(options);
  }
}
