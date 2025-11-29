import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeAiGenerationScreen extends ConsumerStatefulWidget {
  const RecipeAiGenerationScreen({super.key});

  @override
  ConsumerState<RecipeAiGenerationScreen> createState() =>
      _RecipeAiGenerationScreenState();
}

class _RecipeAiGenerationScreenState
    extends ConsumerState<RecipeAiGenerationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Recipe AI Generation')));
  }
}
