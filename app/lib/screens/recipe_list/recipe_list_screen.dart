import 'package:app/enums/app_page.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe List')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
