import 'package:flutter/material.dart';

/// ユーザー未認証時の表示用のウィジェット
///
class NotLoginView extends StatelessWidget {
  const NotLoginView({super.key, this.onTapReload});

  final VoidCallback? onTapReload;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('この機能を利用するには、ログインが必要です。'),
        const SizedBox(height: 120),
        ElevatedButton(onPressed: onTapReload, child: const Text('ログインする')),
      ],
    );
  }
}
