import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:app/config/amplifyconfiguration.dart';
import 'package:app/config/env_config.dart';
import 'package:flutter/foundation.dart';

/// 現在の環境設定（main_dev.dartまたはmain_prod.dartで設定される）
EnvConfig? _currentEnvConfig;

/// 現在の環境設定を取得する
EnvConfig get currentEnv {
  if (_currentEnvConfig == null) {
    throw StateError('Environment config has not been initialized');
  }
  return _currentEnvConfig!;
}

/// Amplifyを初期化する
Future<void> configureAmplify({required EnvConfig envConfig}) async {
  _currentEnvConfig = envConfig;
  try {
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3();
    await Amplify.addPlugins([auth, storage]);
    await Amplify.configure(amplifyconfig);
  } on AmplifyAlreadyConfiguredException {
    debugPrint('Amplify was already configured.');
  }
}
