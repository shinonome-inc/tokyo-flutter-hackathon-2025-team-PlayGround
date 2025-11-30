import 'package:app/models/user.dart';
import 'package:app/repositories/genkaimeshi_repository.dart';
import 'package:app/screens/user_list/user_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_list_notifier.g.dart';

/// stateを管理し、状態の変更を行うクラス。
///
/// 状態を保持し、状態を更新するためのメソッドを提供する。
@riverpod
class UserListNotifier extends _$UserListNotifier {
  @override
  UserListState build() {
    Future.microtask(fetchUsers);
    return const UserListState();
  }

  void _reset() {
    state = const UserListState();
  }

  void _setIsLoading({required bool isLoading}) {
    state = state.copyWith(isLoading: isLoading);
  }

  void _setHasNetworkError({required bool hasNetworkError}) {
    state = state.copyWith(hasNetworkError: hasNetworkError);
  }

  void _setUsers({required List<User> users}) {
    state = state.copyWith(users: users);
  }

  Future<void> fetchUsers() async {
    if (state.isLoading) {
      return;
    }
    _reset();
    _setIsLoading(isLoading: true);
    try {
      final users = await GenkaimeshiRepository.instance.fetchUsers();
      _setUsers(users: users);
    } on Exception {
      _setHasNetworkError(hasNetworkError: true);
    } finally {
      _setIsLoading(isLoading: false);
    }
  }
}
