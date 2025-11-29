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
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTapGenerateAIRecipe() {
    // TODO: レシピAI生成処理
    context.go(AppPage.recipeDetail.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '限界ですか ？\nせめて何か口にしましょう',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_outlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.photo_outlined),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: '作りたいものや食材を教えてね',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _onTapGenerateAIRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 32,
                  ),
                ),
                child: const Text(
                  '生成する',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
