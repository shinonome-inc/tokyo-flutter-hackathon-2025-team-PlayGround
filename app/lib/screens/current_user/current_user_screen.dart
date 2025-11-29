import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentUserScreen extends ConsumerStatefulWidget {
  const CurrentUserScreen({super.key});

  @override
  ConsumerState<CurrentUserScreen> createState() => _CurrentUserScreenState();
}

class _CurrentUserScreenState extends ConsumerState<CurrentUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Current User')));
  }
}
