import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_create_state.freezed.dart';

/// レシピ作成画面の状態を表すクラス
@freezed
abstract class RecipeCreateState with _$RecipeCreateState {
  const factory RecipeCreateState({
    @Default(false) bool isLoading,
    @Default(false) bool hasNetworkError,
    @Default(false) bool isSuccess,
    @Default('') String errorMessage,
    @Default('') String successMessage,
  }) = _RecipeCreateState;
}
