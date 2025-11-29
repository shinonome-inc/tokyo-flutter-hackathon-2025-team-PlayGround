import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:app/services/amplify_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_user_provider.g.dart';

/// 認証中のユーザー情報を扱うプロバイダー
@Riverpod(keepAlive: true)
Future<AuthUser?> authUser(Ref ref) async {
  final amplifyService = AmplifyService.instance;

  final isSignedIn = await amplifyService.isSignedIn();
  if (!isSignedIn) {
    return null;
  }

  try {
    final authUser = await amplifyService.getCurrentUser();
    return authUser;
  } on Exception {
    return null;
  }
}
