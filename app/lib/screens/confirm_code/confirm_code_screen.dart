import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfirmCodeScreen extends ConsumerStatefulWidget {
  const ConfirmCodeScreen({super.key});

  @override
  ConsumerState<ConfirmCodeScreen> createState() => _ConfirmCodeScreenState();
}

class _ConfirmCodeScreenState extends ConsumerState<ConfirmCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Confirm Code')));
  }
}
