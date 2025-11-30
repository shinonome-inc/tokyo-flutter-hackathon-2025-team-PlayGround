import 'package:flutter/material.dart';

/// 確認コード入力フォームコンポーネント
class ConfirmationCodeForm extends StatelessWidget {
  const ConfirmationCodeForm({
    required this.confirmationCodeController,
    required this.isLoading,
    super.key,
    this.onConfirmSignUp,
  });
  final TextEditingController confirmationCodeController;
  final bool isLoading;
  final VoidCallback? onConfirmSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: confirmationCodeController,
          decoration: const InputDecoration(
            labelText: '確認コード',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading ? null : onConfirmSignUp,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('確認'),
          ),
        ),
      ],
    );
  }
}
