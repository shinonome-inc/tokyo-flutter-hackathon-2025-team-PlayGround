import 'package:app/enums/app_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecipeAiGenerationScreen extends ConsumerStatefulWidget {
  const RecipeAiGenerationScreen({super.key});

  @override
  ConsumerState<RecipeAiGenerationScreen> createState() =>
      _RecipeAiGenerationScreenState();
}

class _RecipeAiGenerationScreenState
    extends ConsumerState<RecipeAiGenerationScreen> {
  void _onTapGenerateAIRecipe() {
    // TODO: レシピAI生成処理
    context.go(AppPage.recipeDetail.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe AI Generation')),
      body: Center(
        child: ElevatedButton(
          onPressed: _onTapGenerateAIRecipe,
          child: const Text('AIレシピを生成'),
        ),
      ),
    );
  }
}
