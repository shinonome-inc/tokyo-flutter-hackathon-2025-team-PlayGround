import 'package:app/models/presigned_url_response.dart';
import 'package:app/models/recipe.dart';
import 'package:app/repositories/genkaimeshi_repository.dart';
import 'package:app/screens/recipe_ai_generation/recipe_ai_generation_state.dart';
import 'package:app/screens/recipe_list/recipe_list_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_ai_generation_notifier.g.dart';

/// stateを管理し、状態の変更を行うクラス。
///
/// 状態を保持し、状態を更新するためのメソッドを提供する。
@riverpod
class RecipeAiGenerationNotifier extends _$RecipeAiGenerationNotifier {
  @override
  RecipeAiGenerationState build() {
    return const RecipeAiGenerationState();
  }

  void _reset() {
    state = const RecipeAiGenerationState();
  }

  void _setIsLoading({required bool isLoading}) {
    state = state.copyWith(isLoading: isLoading);
  }

  void _setHasNetworkError({required bool hasNetworkError}) {
    state = state.copyWith(hasNetworkError: hasNetworkError);
  }

  void _setGeneratedRecipe({required Recipe? generatedRecipe}) {
    state = state.copyWith(generateRecipe: generatedRecipe);
  }

  Future<void> generateAIRecipe({required String prompt, XFile? image}) async {
    if (state.isLoading) {
      return;
    }

    _reset();
    _setIsLoading(isLoading: true);
    PresignedUrlResponse? presignedUrlResponse;
    if (image != null) {
      try {
        presignedUrlResponse = await GenkaimeshiRepository.instance
            .generatePresignedUrl(prompt: prompt);
        final imageBytes = await image.readAsBytes();
        final mimeType = image.mimeType ?? 'image/jpeg';
        await GenkaimeshiRepository.instance.uploadImageToS3(
          uploadUrl: presignedUrlResponse.uploadUrl,
          imageBytes: imageBytes,
          contentType: mimeType,
        );
      } on Exception {
        presignedUrlResponse = null;
      }
    }
    try {
      final recipe = await GenkaimeshiRepository.instance.generateAIRecipe(
        prompt: prompt,
        imageS3Key: presignedUrlResponse?.imageS3Key,
      );
      _setGeneratedRecipe(generatedRecipe: recipe);
    } on Exception {
      _setHasNetworkError(hasNetworkError: true);
    } finally {
      _setIsLoading(isLoading: false);
    }
  }
}
