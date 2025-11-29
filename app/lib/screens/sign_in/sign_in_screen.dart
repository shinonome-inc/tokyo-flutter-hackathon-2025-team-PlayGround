import 'package:app/enums/app_page.dart';
import 'package:app/providers/is_signed_in_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  Future<void> _onTapSignIn() async {
    // サインイン処理
    await ref.read(isSignedInProvider.notifier).signIn();

    // サインイン成功後にレシピ一覧画面へ遷移
    context.go(AppPage.recipeList.path);
  }

  void _onTapSignUp() {
    context.go(AppPage.signUp.path);
  }

  void _onTapContinueWithoutSignIn() {
    context.go(AppPage.recipeList.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _onTapSignIn,
              child: const Text('ログイン'),
            ),
            TextButton(
              onPressed: _onTapSignUp,
              child: const Text('新規登録'),
            ),
            TextButton(
              onPressed: _onTapContinueWithoutSignIn,
              child: const Text('ログインせずに開始'),
            ),
          ],
        ),
      ),
    );
  }
}
