import 'package:app/widgets/recipe_form/recipe_form_card.dart';
import 'package:app/widgets/recipe_form/recipe_image_selector.dart';
import 'package:flutter/material.dart';

class RecipeCreateForm extends StatelessWidget {
  const RecipeCreateForm({
    required this.currentDate,
    required this.userId,
    required this.titleController,
    required this.descriptionController,
    required this.instructionsController,
    required this.ingredients,
    required this.onTapImageArea,
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
  final VoidCallback onTapImageArea;
  final VoidCallback onAddIngredient;
  final VoidCallback onTapDelete;
  final VoidCallback onTapPost;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeImageSelector(onTap: onTapImageArea),
            const SizedBox(height: 16),
            RecipeFormCard(
              currentDate: currentDate,
              userId: userId,
              titleController: titleController,
              descriptionController: descriptionController,
              instructionsController: instructionsController,
              ingredients: ingredients,
              onAddIngredient: onAddIngredient,
              onTapDelete: onTapDelete,
              onTapPost: onTapPost,
            ),
          ],
        ),
      ),
    );
  }
}
