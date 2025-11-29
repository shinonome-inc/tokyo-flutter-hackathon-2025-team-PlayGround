import 'package:app/widgets/recipe_ingredient_row.dart';
import 'package:flutter/material.dart';

class RecipeIngredientsSection extends StatelessWidget {
  const RecipeIngredientsSection({
    required this.ingredients,
    required this.onAddIngredient,
    super.key,
  });

  final List<Map<String, TextEditingController>> ingredients;
  final VoidCallback onAddIngredient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ...ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RecipeIngredientRow(ingredient: ingredient),
            );
          }),
          IconButton(
            onPressed: onAddIngredient,
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 32,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
