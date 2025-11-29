import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:app/enums/app_env.dart';
import 'package:app/models/recipe.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 限界飯APIのリポジトリクラス。
class GenkaimeshiRepository {
  GenkaimeshiRepository({Dio? dio, AppEnv environment = AppEnv.dev})
    : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _getBaseUrl(environment);
    _dio.interceptors.add(_AuthInterceptor());
    if (kDebugMode) {
      _dio.interceptors.add(_LogInterceptor());
    }
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

  /// レシピを新規作成する。
  Future<Map<String, dynamic>> createRecipe({
    required String title,
    required String overview,
    String? imageUrl,
    String? notes,
    bool isAiGenerated = false,
    required List<Map<String, String>> ingredients,
    required List<Map<String, dynamic>> steps,
  }) async {
    try {
      final requestData = {
        'title': title,
        'overview': overview,
        'imageUrl': imageUrl,
        'notes': notes,
        'isAiGenerated': isAiGenerated,
        'ingredients': ingredients
            .map((ingredient) => {
                  'name': ingredient['name'],
                  'amount': ingredient['amount'],
                })
            .toList(),
        'steps': steps
            .map((step) => {
                  'orderNumber': step['orderNumber'],
                  'description': step['description'],
                })
            .toList(),
      };

      final response = await _dio.post<Map<String, dynamic>>(
        '/recipes',
        data: requestData,
      );

      if (response.statusCode == 201 && response.data != null) {
        return response.data!;
      } else {
        throw Exception('レシピの作成に失敗しました');
      }
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
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

/// HTTPリクエストとレスポンスのログを出力するインターセプター
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    safePrint('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    safePrint('Headers: ${options.headers}');
    if (options.data != null) {
      safePrint('Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    safePrint('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    safePrint('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    safePrint('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    safePrint('Message: ${err.message}');
    if (err.response?.data != null) {
      safePrint('Error Data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}
