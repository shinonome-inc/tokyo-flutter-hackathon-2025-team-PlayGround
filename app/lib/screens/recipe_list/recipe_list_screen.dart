import 'package:app/enums/app_page.dart';
import 'package:app/screens/recipe_list/recipe_list_notifier.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeListProvider);
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (state.hasNetworkError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ネットワークエラーが発生しました'),
              ElevatedButton(
                onPressed: () {
                  ref.read(recipeListProvider.notifier).fetchRecipes();
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe List')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final recipe in state.recipes)
              ListTile(title: Text(recipe.id)),
            ElevatedButton(
              onPressed: _onTapRecipeItem,
              child: const Text('レシピ詳細へ'),
            ),
            ElevatedButton(onPressed: _onTapUser, child: const Text('ユーザー詳細へ')),
          ],
        ),
      ),
    );
  }
}
