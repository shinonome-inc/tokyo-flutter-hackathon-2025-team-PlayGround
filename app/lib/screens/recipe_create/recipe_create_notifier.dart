import 'package:app/repositories/genkaimeshi_repository.dart';
import 'package:app/screens/recipe_create/recipe_create_state.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_create_notifier.g.dart';

/// レシピ作成の状態を管理し、状態の変更を行うクラス。
@riverpod
class RecipeCreateNotifier extends _$RecipeCreateNotifier {
  @override
  RecipeCreateState build() {
    return const RecipeCreateState();
  }

  void _reset() {
    if (!ref.mounted) {
      return;
    }
    state = const RecipeCreateState();
  }

  void _setIsLoading({required bool isLoading}) {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(isLoading: isLoading);
  }

  void _setHasNetworkError({required bool hasNetworkError}) {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(hasNetworkError: hasNetworkError);
  }

  void _setIsSuccess({required bool isSuccess}) {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(isSuccess: isSuccess);
  }

  void _setErrorMessage({required String errorMessage}) {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(errorMessage: errorMessage);
  }

  void _setSuccessMessage({required String successMessage}) {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(successMessage: successMessage);
  }

  Future<void> createRecipe({
    required String title,
    required String overview,
    required List<Map<String, TextEditingController>> ingredients,
    required String instructions,
    String? imageUrl,
    String? notes,
    bool isAiGenerated = false,
  }) async {
    if (state.isLoading) {
      return;
    }

    _reset();
    _setIsLoading(isLoading: true);

    try {
      // 材料データを変換
      final ingredientsList = ingredients
          .where(
            (ingredient) =>
                (ingredient['name']?.text.isNotEmpty ?? false) &&
                (ingredient['amount']?.text.isNotEmpty ?? false),
          )
          .map(
            (ingredient) => {
              'name': ingredient['name']!.text,
              'amount': ingredient['amount']!.text,
            },
          )
          .toList();

      // 手順データを変換（改行で分割）
      final stepsList = instructions
          .split('\n')
          .where((step) => step.trim().isNotEmpty)
          .map((step) => step.trim())
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => {
              'orderNumber': entry.key + 1,
              'description': entry.value,
            },
          )
          .toList();

      final result = await GenkaimeshiRepository.instance.createRecipe(
        title: title,
        overview: overview,
        imageUrl: imageUrl,
        notes: notes,
        isAiGenerated: isAiGenerated,
        ingredients: ingredientsList,
        steps: stepsList,
      );

      final message = result['message'] ?? 'レシピを投稿しました';
      _setSuccessMessage(successMessage: message);
      _setIsSuccess(isSuccess: true);
    } on Exception catch (e) {
      _setHasNetworkError(hasNetworkError: true);
      _setErrorMessage(errorMessage: e.toString());
    } finally {
      _setIsLoading(isLoading: false);
    }
  }
}
