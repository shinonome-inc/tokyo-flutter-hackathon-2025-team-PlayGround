import 'package:app/enums/app_page.dart';
import 'package:app/providers/is_signed_in_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  Future<void> _onTapSignUp() async {
    // TODO: サインアップ処理
    context.go(AppPage.confirmCode.path);
  }

  void _onTapBackToSignIn() {
    context.go(AppPage.signIn.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _onTapSignUp,
              child: const Text('サインアップ'),
            ),
            TextButton(
              onPressed: _onTapBackToSignIn,
              child: const Text('サインイン画面に戻る'),
            ),
          ],
        ),
      ),
    );
  }
}
