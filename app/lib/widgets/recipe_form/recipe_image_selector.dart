import 'package:flutter/material.dart';

class RecipeImageSelector extends StatelessWidget {
  const RecipeImageSelector({
    required this.onTap,
    this.imageUrl,
    super.key,
  });

  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          color: const Color(0xFFCCCCCC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(
                Icons.image_outlined,
                size: 48,
                color: Colors.white,
              ),
      ),
    );
  }
}
