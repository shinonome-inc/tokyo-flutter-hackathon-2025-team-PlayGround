import 'package:flutter/material.dart';

/// ネットワークエラー表示用のウィジェット
///
class NetworkErrorView extends StatelessWidget {
  const NetworkErrorView({super.key, this.onTapReload});

  final VoidCallback? onTapReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('ネットワークエラーが発生しました。'),
          const SizedBox(height: 120),
          ElevatedButton(onPressed: onTapReload, child: const Text('トップに戻る')),
        ],
      ),
    );
  }
}
