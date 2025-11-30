import 'package:app/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_list_state.freezed.dart';

@freezed
abstract class UserListState with _$UserListState {
  const factory UserListState({
    @Default(false) bool isLoading,
    @Default(false) bool hasNetworkError,
    @Default([]) List<User> users,
  }) = _UserListState;
}
