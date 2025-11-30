import 'package:flutter/material.dart';

class RecipeDateUserInfo extends StatelessWidget {
  const RecipeDateUserInfo({
    required this.currentDate,
    required this.userId,
    super.key,
  });

  final String currentDate;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          currentDate,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        Text(
          userId,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
