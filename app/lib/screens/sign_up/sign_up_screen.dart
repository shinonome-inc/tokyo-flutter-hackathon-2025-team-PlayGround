import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:app/enums/app_page.dart';
import 'package:app/screens/sign_up/confirmation_code_form.dart';
import 'package:app/screens/sign_up/email_sign_up_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 新規登録画面
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
        context.go(AppPage.recipeList.path);
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('新規登録')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isConfirmationStep)
                EmailSignUpForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isLoading: _isLoading,
                  onSignUpWithEmail: _signUpWithEmail,
                  onSignUpWithGoogle: _signUpWithGoogle,
                  onSignUpWithLine: _signUpWithLine,
                )
              else
                ConfirmationCodeForm(
                  confirmationCodeController: _confirmationCodeController,
                  isLoading: _isLoading,
                  onConfirmSignUp: _confirmSignUp,
                ),
              if (_message.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  _message,
                  style: TextStyle(
                    color: _message.startsWith('エラー')
                        ? Colors.red
                        : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
