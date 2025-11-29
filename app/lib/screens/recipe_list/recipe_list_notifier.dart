import 'package:app/models/recipe.dart';
import 'package:app/repositories/genkaimeshi_repository.dart';
import 'package:app/screens/recipe_list/recipe_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_list_notifier.g.dart';

/// stateを管理し、状態の変更を行うクラス。
///
/// 状態を保持し、状態を更新するためのメソッドを提供する。
@riverpod
class RecipeListNotifier extends _$RecipeListNotifier {
  @override
  RecipeListState build() {
    Future.microtask(fetchRecipes);
    return const RecipeListState();
  }

  void _reset() {
    state = const RecipeListState();
  }

  void _setIsLoading({required bool isLoading}) {
    state = state.copyWith(isLoading: isLoading);
  }

  void _setHasNetworkError({required bool hasNetworkError}) {
    state = state.copyWith(hasNetworkError: hasNetworkError);
  }

  void _setRecipes({required List<Recipe> recipes}) {
    state = state.copyWith(recipes: recipes);
  }

  Future<void> fetchRecipes() async {
    if (state.isLoading) {
      return;
    }
    _reset();
    _setIsLoading(isLoading: true);
    try {
      final recipes = await GenkaimeshiRepository.instance.fetchRecipes();
      _setRecipes(recipes: recipes);
    } on Exception {
      _setHasNetworkError(hasNetworkError: true);
    } finally {
      _setIsLoading(isLoading: false);
    }
  }
}
