import 'package:app/enums/app_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecipeCreateScreen extends ConsumerStatefulWidget {
  const RecipeCreateScreen({super.key});

  @override
  ConsumerState<RecipeCreateScreen> createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends ConsumerState<RecipeCreateScreen> {
  void _onTapAIRecipeGeneration() {
    context.go(AppPage.recipeAiGeneration.path);
  }

  void _onTapPostRecipe() {
    // TODO: レシピ投稿処理
    context.go(AppPage.recipeDetail.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Create')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _onTapAIRecipeGeneration,
              child: const Text('AIでレシピ生成'),
            ),
            ElevatedButton(
              onPressed: _onTapPostRecipe,
              child: const Text('レシピを投稿'),
            ),
          ],
        ),
      ),
    );
  }
}
