import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeAiLoadingScreen extends ConsumerStatefulWidget {
  const RecipeAiLoadingScreen({super.key});

  @override
  ConsumerState<RecipeAiLoadingScreen> createState() =>
      _RecipeAiLoadingScreenState();
}

class _RecipeAiLoadingScreenState extends ConsumerState<RecipeAiLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Recipe AI Loading')));
  }
}
