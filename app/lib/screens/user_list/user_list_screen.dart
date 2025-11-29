import 'package:app/enums/app_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  void _onTapUser() {
    context.go(AppPage.userDetail.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _onTapUser, child: const Text('ユーザー詳細へ')),
          ],
        ),
      ),
    );
  }
}
