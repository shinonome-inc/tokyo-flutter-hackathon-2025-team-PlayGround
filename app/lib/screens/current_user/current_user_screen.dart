import 'package:app/enums/app_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CurrentUserScreen extends ConsumerStatefulWidget {
  const CurrentUserScreen({super.key});

  @override
  ConsumerState<CurrentUserScreen> createState() => _CurrentUserScreenState();
}

class _CurrentUserScreenState extends ConsumerState<CurrentUserScreen> {
  void _onTapProfileEdit() {
    context.go(AppPage.userEdit.path);
  }

  void _onTapSettings() {
    context.go(AppPage.settings.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current User')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _onTapSettings, child: const Text('設定')),
            ElevatedButton(
              onPressed: _onTapProfileEdit,
              child: const Text('プロフィール編集'),
            ),
          ],
        ),
      ),
    );
  }
}
