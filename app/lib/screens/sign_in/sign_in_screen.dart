import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:app/enums/app_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ログイン画面
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mfaCodeController = TextEditingController();
  bool _isLoading = false;
  bool _isMfaStep = false;
  String _message = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mfaCodeController.dispose();
    super.dispose();
  }

  /// メールアドレスでログインを行う
  Future<void> _signInWithEmail() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await Amplify.Auth.signIn(
        username: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.isSignedIn) {
        setState(() {
          _message = 'ログイン成功';
        });
        context.go(AppPage.recipeList.path);
      } else if (result.nextStep.signInStep ==
          AuthSignInStep.confirmSignInWithTotpMfaCode) {
        setState(() {
          _isMfaStep = true;
          _message = '認証コードを入力してください';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _message = 'エラー: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// MFAコードを検証する
  Future<void> _confirmMfa() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await Amplify.Auth.confirmSignIn(
        confirmationValue: _mfaCodeController.text.trim(),
      );

      if (result.isSignedIn) {
        setState(() {
          _message = 'ログイン成功';
        });
        context.go(AppPage.recipeList.path);
      }
    } on AuthException catch (e) {
      setState(() {
        _message = 'エラー: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Googleアカウントでログインを行う
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
      );

      if (result.isSignedIn) {
        setState(() {
          _message = 'Googleでログイン成功';
        });
        context.go(AppPage.recipeList.path);
      }
    } on AuthException catch (e) {
      setState(() {
        _message = 'エラー: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// LINEアカウントでログインを行う
  Future<void> _signInWithLine() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await Amplify.Auth.signInWithWebUI(
        provider: const AuthProvider.custom('LINE'),
      );

      if (result.isSignedIn) {
        setState(() {
          _message = 'LINEでログイン成功';
        });
        context.go(AppPage.recipeList.path);
      }
    } on AuthException catch (e) {
      setState(() {
        _message = 'エラー: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isMfaStep) ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'パスワード',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signInWithEmail,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('メールアドレスでログイン'),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'または',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isLoading ? null : _signInWithGoogle,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Googleでログイン'),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isLoading ? null : _signInWithLine,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00B900),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('LINEでログイン'),
                ),
              ),
            ] else ...[
              TextField(
                controller: _mfaCodeController,
                decoration: const InputDecoration(
                  labelText: '認証コード',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _confirmMfa,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('確認'),
                ),
              ),
            ],
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                _message,
                style: TextStyle(
                  color: _message.startsWith('エラー') ? Colors.red : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
