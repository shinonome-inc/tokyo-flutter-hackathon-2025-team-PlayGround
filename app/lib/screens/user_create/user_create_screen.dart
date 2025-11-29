import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserCreateScreen extends ConsumerStatefulWidget {
  const UserCreateScreen({super.key});

  @override
  ConsumerState<UserCreateScreen> createState() => _UserCreateScreenState();
}

class _UserCreateScreenState extends ConsumerState<UserCreateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('User Create')));
  }
}
