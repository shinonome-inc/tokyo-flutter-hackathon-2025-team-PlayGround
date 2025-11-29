import 'package:app/enums/app_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserCreateScreen extends ConsumerStatefulWidget {
  const UserCreateScreen({super.key});

  @override
  ConsumerState<UserCreateScreen> createState() => _UserCreateScreenState();
}

class _UserCreateScreenState extends ConsumerState<UserCreateScreen> {
  void _onTapCreateUser() {
    // ユーザー情報作成後、ボトムナビゲーションバーの画面へ遷移
    context.go(AppPage.recipeList.path); // TODO: BottomNavigationScreenに変更予定
  }

  void _onTapSkip() {
    // スキップした場合もボトムナビゲーションバーの画面へ遷移
    context.go(AppPage.recipeList.path); // TODO: BottomNavigationScreenに変更予定
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー情報登録')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _onTapCreateUser,
              child: const Text('ユーザー情報を登録'),
            ),
            TextButton(
              onPressed: _onTapSkip,
              child: const Text('スキップ'),
            ),
          ],
        ),
      ),
    );
  }
}
