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

  void _onTapSignUp() {
    context.go(AppPage.signUp.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E8), // フォールバック背景色
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            // 画像が見つからない場合は背景色を使用
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                Image.asset(
                  'assets/images/login_logo.png',
                  width: 104,
                  height: 104,
                  fit: BoxFit.contain,
                ),

                const Spacer(),

                Image.asset(
                  'assets/images/app_icon.png',
                  width: 136,
                  height: 136,
                  fit: BoxFit.contain,
                ),

                const Spacer(),

                if (!_isMfaStep) ...[
                  // メールアドレス入力
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

                  // パスワード入力
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

                  // ログインボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signInWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD2523C), // 赤色
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                      ),
                      child: SizedBox(
                        height: 22, // 固定高さでテキストサイズに合わせる
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
                                'ログイン',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Google/LINEログインボタン（横並び）
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _signInWithGoogle,
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
                          onPressed: _isLoading ? null : _signInWithLine,
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

                  // 新規登録リンク
                  TextButton(
                    onPressed: _onTapSignUp,
                    child: const Text(
                      'アカウントを新規作成',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B8E4A),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go(AppPage.recipeList.path);
                    },
                    child: const Text(
                      'ログインせずに利用',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B8E4A),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ] else ...[
                  // MFAコード入力
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
                      controller: _mfaCodeController,
                      decoration: const InputDecoration(
                        hintText: '認証コード',
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
                      onPressed: _isLoading ? null : _confirmMfa,
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
                        height: 22, // 固定高さでテキストサイズに合わせる
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

                // メッセージ表示領域（常に確保）
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
