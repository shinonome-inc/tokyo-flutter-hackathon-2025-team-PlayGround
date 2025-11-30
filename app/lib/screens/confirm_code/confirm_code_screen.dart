import 'package:app/enums/app_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConfirmCodeScreen extends ConsumerStatefulWidget {
  const ConfirmCodeScreen({super.key});

  @override
  ConsumerState<ConfirmCodeScreen> createState() => _ConfirmCodeScreenState();
}

class _ConfirmCodeScreenState extends ConsumerState<ConfirmCodeScreen> {
  void _onTapConfirmCode() {
    // TODO: 確認コード認証処理
    context.go(AppPage.userCreate.path);
  }

  void _onTapResendCode() {
    // TODO: コード再送信処理
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('確認コードを再送信しました')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('確認コード入力')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _onTapConfirmCode,
              child: const Text('確認コードを送信'),
            ),
            TextButton(
              onPressed: _onTapResendCode,
              child: const Text('確認コードを再送信'),
            ),
          ],
        ),
      ),
    );
  }
}
