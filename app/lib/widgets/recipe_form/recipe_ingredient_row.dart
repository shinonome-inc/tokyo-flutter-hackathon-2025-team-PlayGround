import 'package:flutter/material.dart';

class RecipeIngredientRow extends StatelessWidget {
  const RecipeIngredientRow({required this.ingredient, super.key});

  final Map<String, TextEditingController> ingredient;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: ingredient['name'],
            decoration: const InputDecoration(
              hintText: '材料',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: ingredient['amount'],
            decoration: const InputDecoration(
              hintText: '量、個数',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
