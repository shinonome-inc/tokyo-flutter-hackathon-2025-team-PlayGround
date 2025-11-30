import 'package:app/screens/user_list/user_list_item.dart';
import 'package:app/screens/user_list/user_list_notifier.dart';
import 'package:app/screens/user_list/user_list_state.dart';
import 'package:app/widgets/loading_view.dart';
import 'package:app/widgets/network_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  Future<void> _onTapReload() async {
    await ref.read(userListProvider.notifier).fetchUsers();
  }

  Future<void> _onRefresh() async {
    await ref.read(userListProvider.notifier).fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // タイトル
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'ユーザー一覧',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // ユーザーリスト
              Expanded(
                child: switch (state) {
                  UserListState(:final isLoading) when isLoading =>
                    const LoadingView(),
                  UserListState(:final hasNetworkError) when hasNetworkError =>
                    NetworkErrorView(onTapReload: _onTapReload),
                  _ => RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: state.users.isEmpty
                        ? const Center(
                            child: Text(
                              'ユーザーが見つかりません',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.users.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final user = state.users[index];
                              return UserListItem(user: user);
                            },
                          ),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
