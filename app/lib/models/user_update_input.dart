import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_update_input.freezed.dart';
part 'user_update_input.g.dart';

@freezed
abstract class UserUpdateInput with _$UserUpdateInput {
  const factory UserUpdateInput({
    String? name,
    String? imageUrl,
    String? description,
  }) = _UserUpdateInput;

  factory UserUpdateInput.fromJson(Map<String, Object?> json) =>
      _$UserUpdateInputFromJson(json);
}
