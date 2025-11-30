import 'package:flutter/material.dart';

/// レシピAI生成画面のヘッダーウィジェット
///
class RecipeAiGenerationHeader extends StatelessWidget {
  const RecipeAiGenerationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
      ],
    );
  }
}
