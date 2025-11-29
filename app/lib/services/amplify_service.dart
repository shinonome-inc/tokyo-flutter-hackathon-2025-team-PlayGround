import 'package:amplify_flutter/amplify_flutter.dart';

/// Amplify認証サービス
class AmplifyService {
  AmplifyService._();

  static final AmplifyService instance = AmplifyService._();

  /// 現在の認証セッションを取得する
  Future<AuthSession> fetchAuthSession() async {
    return Amplify.Auth.fetchAuthSession();
  }

  /// 現在ログイン中のユーザー情報を取得する
  Future<AuthUser> getCurrentUser() async {
    return Amplify.Auth.getCurrentUser();
  }

  /// ユーザーがサインインしているかどうかを確認する
  Future<bool> isSignedIn() async {
    final session = await fetchAuthSession();
    return session.isSignedIn;
  }
}
