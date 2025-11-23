import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:app/config/amplifyconfiguration.dart';
import 'package:flutter/foundation.dart';

/// Amplifyを初期化する
Future<void> configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugins([auth]);
    await Amplify.configure(amplifyconfig);
  } on AmplifyAlreadyConfiguredException {
    debugPrint('Amplify was already configured.');
  }
}
