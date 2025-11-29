import 'package:app/models/recipe.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_ai_generation_state.freezed.dart';

@freezed
abstract class RecipeAiGenerationState with _$RecipeAiGenerationState {
  const factory RecipeAiGenerationState({
    @Default(false) bool isLoading,
    @Default(false) bool hasNetworkError,
    Recipe? generateRecipe,
  }) = _RecipeAiGenerationState;
}
