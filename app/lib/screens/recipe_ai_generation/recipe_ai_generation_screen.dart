import 'package:app/screens/recipe_ai_generation/recipe_ai_generation_header.dart';
import 'package:app/screens/recipe_ai_generation/recipe_ai_generation_notifier.dart';
import 'package:app/screens/recipe_ai_generation/recipe_ai_generation_state.dart';
import 'package:app/widgets/loading_view.dart';
import 'package:app/widgets/network_error_view.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class RecipeAiGenerationScreen extends ConsumerStatefulWidget {
  const RecipeAiGenerationScreen({super.key});

  @override
  ConsumerState<RecipeAiGenerationScreen> createState() =>
      _RecipeAiGenerationScreenState();
}

class _RecipeAiGenerationScreenState
    extends ConsumerState<RecipeAiGenerationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _onTapGenerateAIRecipe() async {
    if (_textController.text.isEmpty) {
      return;
    }
    await ref
        .read(recipeAiGenerationProvider.notifier)
        .generateAIRecipe(prompt: _textController.text);
  }

  Future<void> _onTapReload() async {
    ref.invalidate(recipeAiGenerationProvider);
  }

  Future<void> _pickImageFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeAiGenerationProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: switch (state) {
            RecipeAiGenerationState(:final isLoading) when isLoading =>
              const LoadingView(),
            RecipeAiGenerationState(:final hasNetworkError)
                when hasNetworkError =>
              NetworkErrorView(onTapReload: _onTapReload),
            _ => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                if (state.generateRecipe == null)
                  const RecipeAiGenerationHeader()
                else ...[
                  Text(state.generateRecipe!.id),
                ],
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      if (_selectedImage != null)
                        Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              children: [
                                Image.file(
                                  File(_selectedImage!.path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _pickImageFromCamera,
                            icon: const Icon(Icons.camera_alt_outlined),
                          ),
                          IconButton(
                            onPressed: _pickImageFromGallery,
                            icon: const Icon(Icons.photo_outlined),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              onChanged: (value) => setState(() {}),
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
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _textController.text.isEmpty
                      ? null
                      : _onTapGenerateAIRecipe,
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
          },
        ),
      ),
    );
  }
}
