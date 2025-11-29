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
  /// 初期状態を構築する。
  @override
  RecipeListState build() {
    return const RecipeListState();
  }

  void setIsLoading({required bool isLoading}) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setHasNetworkError({required bool hasNetworkError}) {
    state = state.copyWith(hasNetworkError: hasNetworkError);
  }

  void setRecipes({required List<Recipe> recipes}) {
    state = state.copyWith(recipes: recipes);
  }

  Future<void> fetchRecipes() async {
    if (state.isLoading) {
      return;
    }
    setIsLoading(isLoading: true);
    try {
      final recipes = await GenkaimeshiRepository.instance.fetchRecipes();
      setRecipes(recipes: recipes);
    } on Exception {
      setHasNetworkError(hasNetworkError: true);
    } finally {
      setIsLoading(isLoading: false);
    }
  }
}
