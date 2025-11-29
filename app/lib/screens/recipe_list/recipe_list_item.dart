import 'package:app/models/recipe.dart';
import 'package:flutter/material.dart';

class RecipeListItem extends StatelessWidget {
  const RecipeListItem({required this.recipe, this.onTap, super.key});

  final Recipe recipe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(child: Text(recipe.id), color: Colors.grey),
    );
  }
}
