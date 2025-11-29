import 'package:app/config/amplify_initializer.dart';
import 'package:app/config/env_config.dart';
import 'package:app/providers/env_config_provider.dart';
import 'package:app/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリケーションの共通エントリーポイント
Future<void> mainCommon(EnvConfig envConfig) async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureAmplify(envConfig: envConfig);
  runApp(
    ProviderScope(
      overrides: [
        envConfigProvider.overrideWithValue(envConfig),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Genkaimeshi Recipe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
