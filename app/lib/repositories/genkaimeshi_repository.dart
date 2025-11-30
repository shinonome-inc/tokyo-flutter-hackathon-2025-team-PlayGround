import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:app/enums/app_env.dart';
import 'package:app/models/presigned_url_response.dart';
import 'package:app/models/recipe.dart';
import 'package:app/models/user.dart';
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

  /// Presigned URLを生成する。
  ///
  /// [prompt] AIへのプロンプト（例: 簡単に作れるレシピを提案して）
  /// [requiresImageUpload] 画像アップロードが必要かどうか
  Future<PresignedUrlResponse> generatePresignedUrl({
    required String prompt,
    bool requiresImageUpload = true,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'prompt': prompt,
        'requiresImageUpload': requiresImageUpload,
      };

      final response = await _dio.post<Map<String, dynamic>>(
        '/recipes/ai-generate',
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data != null) {
        return PresignedUrlResponse.fromJson(response.data!);
      } else {
        throw Exception('Presigned URLの生成に失敗しました');
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

  /// レシピを新規作成する。
  Future<Map<String, dynamic>> createRecipe({
    required String title,
    required String overview,
    required List<Map<String, String>> ingredients,
    required List<Map<String, dynamic>> steps,
    String? imageUrl,
    String? notes,
    bool isAiGenerated = false,
  }) async {
    try {
      final requestData = {
        'title': title,
        'overview': overview,
        'imageUrl': imageUrl,
        'notes': notes,
        'isAiGenerated': isAiGenerated,
        'ingredients': ingredients
            .map(
              (ingredient) => {
                'name': ingredient['name'],
                'amount': ingredient['amount'],
              },
            )
            .toList(),
        'steps': steps
            .map(
              (step) => {
                'orderNumber': step['orderNumber'],
                'description': step['description'],
              },
            )
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
      throw Exception('予期せぬエラーが発生しました: $e');
    }
  }

  /// Presigned URLを使ってS3に画像をアップロードする。
  ///
  /// [uploadUrl] Presigned URL
  /// [imageBytes] アップロードする画像のバイトデータ
  /// [contentType] 画像のMIMEタイプ（例: 'image/jpeg', 'image/png'）
  Future<void> uploadImageToS3({
    required String uploadUrl,
    required List<int> imageBytes,
    Dio? dio,
    String contentType = 'image/jpeg',
  }) async {
    try {
      // S3へのアップロード用に新しいDioインスタンスを使用（認証ヘッダーが不要なため）
      final uploadDio = dio ?? Dio();
      final response = await uploadDio.put<void>(
        uploadUrl,
        data: imageBytes,
        options: Options(headers: {'Content-Type': contentType}),
      );

      if (response.statusCode != 200) {
        throw Exception('画像のアップロードに失敗しました');
      }
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
    }
  }

  /// AIレシピを生成する
  ///
  /// [prompt] AIへのプロンプト（例: 簡単に作れるレシピを提案して）
  /// [imageS3Key] S3にアップロードした画像のキー（オプション）
  Future<Recipe> generateAIRecipe({
    required String prompt,
    String? imageS3Key,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'prompt': prompt,
        if (imageS3Key != null) 'imageS3Key': imageS3Key,
      };

      final response = await _dio.post<Map<String, dynamic>>(
        '/recipes/ai-generate',
        data: requestBody,
      );
      if (response.statusCode == 200 && response.data != null) {
        return Recipe.fromJson(response.data!);
      } else {
        throw Exception('AIレシピの生成に失敗しました');
      }
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
    }
  }

  /// ユーザー一覧を取得する。
  Future<List<User>> fetchUsers() async {
    try {
      final response = await _dio.get<List<dynamic>>('/users');
      if (response.statusCode == 200 && response.data != null) {
        final users = response.data!
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
        return users;
      } else {
        throw Exception('ユーザーの取得に失敗しました');
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
      safePrint('Is user signed in: ${session.isSignedIn}');

      if (session.isSignedIn) {
        final cognitoSession = session as CognitoAuthSession;
        final accessToken =
            cognitoSession.userPoolTokensResult.value.accessToken.raw;
        options.headers['Authorization'] = 'Bearer $accessToken';
        safePrint('Authorization header added successfully');
        // トークンの最初の50文字だけログ出力（セキュリティ上の理由で全体は出力しない）
        final tokenPreview = accessToken.length > 50
            ? accessToken.substring(0, 50)
            : accessToken;
        safePrint('Token preview: $tokenPreview...');
      } else {
        safePrint('User is not signed in! 403 error is expected!');
      }
    } on AuthException catch (e) {
      safePrint('Auth error in interceptor: ${e.message}');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    safePrint('DioException occurred:');
    safePrint('  Status code: ${err.response?.statusCode}');
    safePrint('  Request path: ${err.requestOptions.path}');
    safePrint('  Request method: ${err.requestOptions.method}');
    safePrint('  Request headers: ${err.requestOptions.headers}');
    safePrint('  Response data: ${err.response?.data}');
    safePrint('  Response headers: ${err.response?.headers}');
    handler.next(err);
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
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    safePrint('''
✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}''');
    safePrint('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    safePrint('''
❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}''');
    safePrint('Message: ${err.message}');
    if (err.response?.data != null) {
      safePrint('Error Data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}
