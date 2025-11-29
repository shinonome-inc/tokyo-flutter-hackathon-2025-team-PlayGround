import 'package:app/models/recipe.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_list_state.freezed.dart';

@freezed
abstract class RecipeListState with _$RecipeListState {
  const factory RecipeListState({
    @Default(false) bool isLoading,
    @Default(false) bool hasNetworkError,
    @Default([]) List<Recipe> recipes,
  }) = _RecipeListState;
}
