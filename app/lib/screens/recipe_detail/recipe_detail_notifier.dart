import 'package:app/repositories/genkaimeshi_repository.dart';
import 'package:app/screens/recipe_detail/recipe_detail_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_detail_notifier.g.dart';

@Riverpod(keepAlive: true)
class RecipeDetailNotifier extends _$RecipeDetailNotifier {
  @override
  RecipeDetailState build() => const RecipeDetailState();

  Future<void> updateRecipe(String recipeId) async {
    try {
      final recipe = await GenkaimeshiRepository.instance.fetchRecipeByRecipeId(
        recipeId,
      );
      state = state.copyWith(recipe: recipe);
    } on Exception catch (e) {
      throw Exception('fetchRecipeByRecipeId関数が失敗しました: $e');
    }
  }
}
