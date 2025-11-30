import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// 新規登録画面
class SampleSignUpScreen extends StatefulWidget {
  const SampleSignUpScreen({super.key});

  @override
  State<SampleSignUpScreen> createState() => _SampleSignUpScreenState();
}

class _SampleSignUpScreenState extends State<SampleSignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationCodeController = TextEditingController();
  bool _isLoading = false;
  bool _isConfirmationStep = false;
  String _message = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationCodeController.dispose();
    super.dispose();
  }

  /// メールアドレスで新規登録を行う
  Future<void> _signUpWithEmail() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await Amplify.Auth.signUp(
        username: _emailController.text.trim(),
        password: _passwordController.text,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: _emailController.text.trim(),
          },
        ),
      );

      if (result.isSignUpComplete) {
        setState(() {
          _message = '登録完了しました';
        });
      } else {
        setState(() {
          _isConfirmationStep = true;
          _message = '確認コードをメールで送信しました';
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

  /// 確認コードを検証する
  Future<void> _confirmSignUp() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: _emailController.text.trim(),
        confirmationCode: _confirmationCodeController.text.trim(),
      );

      if (result.isSignUpComplete) {
        setState(() {
          _message = '登録完了しました';
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

  /// Googleアカウントで新規登録を行う
  Future<void> _signUpWithGoogle() async {
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
          _message = 'Googleで登録完了しました';
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

  /// LINEアカウントで新規登録を行う
  Future<void> _signUpWithLine() async {
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
          _message = 'LINEで登録完了しました';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isConfirmationStep) ...[
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
                onPressed: _isLoading ? null : _signUpWithEmail,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('メールアドレスで登録'),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text('または', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isLoading ? null : _signUpWithGoogle,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Googleで登録'),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isLoading ? null : _signUpWithLine,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00B900),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('LINEで登録'),
                ),
              ),
            ] else ...[
              TextField(
                controller: _confirmationCodeController,
                decoration: const InputDecoration(
                  labelText: '確認コード',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _confirmSignUp,
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
