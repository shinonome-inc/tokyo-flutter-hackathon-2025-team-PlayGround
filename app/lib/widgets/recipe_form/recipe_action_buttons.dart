import 'package:flutter/material.dart';

class RecipeActionButtons extends StatelessWidget {
  const RecipeActionButtons({
    required this.onTapDelete,
    required this.onTapPost,
    super.key,
  });

  final VoidCallback onTapDelete;
  final VoidCallback onTapPost;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: onTapDelete,
            icon: const Icon(Icons.delete_outline),
            color: Colors.white,
            iconSize: 28,
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE57373),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: onTapPost,
            icon: const Icon(Icons.file_upload_outlined),
            color: Colors.white,
            iconSize: 28,
          ),
        ),
      ],
    );
  }
}
