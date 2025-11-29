import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:app/enums/app_page.dart';
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

  void _onTapSignIn() {
    context.go(AppPage.signIn.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E8),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                Image.asset(
                  'assets/images/app_icon.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),

                const Spacer(),

                if (!_isConfirmationStep) ...[
                  // メールアドレス
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'メールアドレス',
                        hintStyle: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // パスワード
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'パスワード',
                        hintStyle: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 新規登録ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUpWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD2523C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                      ),
                      child: SizedBox(
                        height: 22,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                '新規登録',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _signUpWithGoogle,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(
                              color: Color(0xFF4285F4),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4285F4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _signUpWithLine,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(
                              color: Color(0xFF00B900),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            'LINE',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF00B900),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  TextButton(
                    onPressed: _onTapSignIn,
                    child: const Text(
                      'ログインはこちら',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B8E4A),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _confirmationCodeController,
                      decoration: const InputDecoration(
                        hintText: '確認コード',
                        hintStyle: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD2523C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                      ),
                      child: SizedBox(
                        height: 22,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                '確認',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  height: 20,
                  child: _message.isNotEmpty
                      ? Text(
                          _message,
                          style: TextStyle(
                            color: _message.startsWith('エラー')
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF388E3C),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
