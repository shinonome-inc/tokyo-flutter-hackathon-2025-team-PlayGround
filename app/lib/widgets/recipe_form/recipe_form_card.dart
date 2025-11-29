import 'package:app/widgets/recipe_form/recipe_action_buttons.dart';
import 'package:app/widgets/recipe_form/recipe_date_user_info.dart';
import 'package:app/widgets/recipe_form/recipe_ingredients_section.dart';
import 'package:flutter/material.dart';

class RecipeFormCard extends StatelessWidget {
  const RecipeFormCard({
    required this.currentDate,
    required this.userId,
    required this.titleController,
    required this.descriptionController,
    required this.instructionsController,
    required this.ingredients,
    required this.onAddIngredient,
    required this.onTapDelete,
    required this.onTapPost,
    super.key,
  });

  final String currentDate;
  final String userId;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController instructionsController;
  final List<Map<String, TextEditingController>> ingredients;
  final VoidCallback onAddIngredient;
  final VoidCallback onTapDelete;
  final VoidCallback onTapPost;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'タイトル',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              hintText: 'レシピ概要。',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 8),
          RecipeDateUserInfo(currentDate: currentDate, userId: userId),
          const SizedBox(height: 16),
          RecipeIngredientsSection(
            ingredients: ingredients,
            onAddIngredient: onAddIngredient,
          ),
          const SizedBox(height: 24),
          const Text(
            '作り方',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: instructionsController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '作り方の文章を入力する。',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 24),
          RecipeActionButtons(onTapDelete: onTapDelete, onTapPost: onTapPost),
        ],
      ),
    );
  }
}
