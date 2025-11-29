import 'package:flutter/material.dart';

/// メール登録フォームコンポーネント
class EmailSignUpForm extends StatelessWidget {

  const EmailSignUpForm({
    required this.emailController,
    required this.passwordController,
    required this.isLoading, super.key,
    this.onSignUpWithEmail,
    this.onSignUpWithGoogle,
    this.onSignUpWithLine,
  });
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback? onSignUpWithEmail;
  final VoidCallback? onSignUpWithGoogle;
  final VoidCallback? onSignUpWithLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'メールアドレス',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: 'パスワード',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading ? null : onSignUpWithEmail,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('メールアドレスで登録'),
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
          onPressed: isLoading ? null : onSignUpWithGoogle,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Googleで登録'),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: isLoading ? null : onSignUpWithLine,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00B900),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('LINEで登録'),
          ),
        ),
      ],
    );
  }
}
