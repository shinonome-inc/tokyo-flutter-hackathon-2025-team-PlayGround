import 'package:app/enums/app_page.dart';
import 'package:app/screens/recipe_list/recipe_list_item.dart';
import 'package:app/screens/recipe_list/recipe_list_notifier.dart';
import 'package:app/screens/recipe_list/recipe_list_state.dart';
import 'package:app/widgets/loading_view.dart';
import 'package:app/widgets/network_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  void _onTapRecipeItem() {
    context.go(AppPage.recipeDetail.path);
  }

  void _onTapUser() {
    context.go(AppPage.userDetail.path);
  }

  Future<void> _onTapReload() async {
    await ref.read(recipeListProvider.notifier).fetchRecipes();
  }

  Future<void> _onRefresh() async {
    await ref.read(recipeListProvider.notifier).fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe List')),
      body: Center(
        child: switch (state) {
          RecipeListState(:final isLoading) when isLoading =>
            const LoadingView(),
          RecipeListState(:final hasNetworkError) when hasNetworkError =>
            NetworkErrorView(onTapReload: _onTapReload),
          _ => RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              children: [
                ...state.recipes.map(
                  (recipe) =>
                      RecipeListItem(recipe: recipe, onTap: _onTapRecipeItem),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}
