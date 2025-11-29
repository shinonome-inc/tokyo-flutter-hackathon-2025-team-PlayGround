import 'package:app/enums/app_page.dart';
import 'package:app/screens/recipe_list/recipe_list_notifier.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeListProvider);
    if (state.isLoading) {
      return const Scaffold(body: LoadingView());
    } else if (state.hasNetworkError) {
      return Scaffold(body: NetworkErrorView(onTapReload: _onTapReload));
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
