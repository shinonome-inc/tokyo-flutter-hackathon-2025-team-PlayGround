import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// GoRouterを用いてBottomNavigationBarのitemを表示するためのWidget。
///
class LayoutScaffold extends StatelessWidget {
  const LayoutScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// 各タブのUIの情報をリスト化
  static const _tabs = [
    (icon: Icons.restaurant_menu, label: 'レシピ'),
    (icon: Icons.add_circle, label: '投稿'),
    (icon: Icons.keyboard_double_arrow_up, label: 'AI生成'),
    (icon: Icons.group, label: 'ユーザー'),
    (icon: Icons.person, label: 'マイページ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF487F38),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, _tabs[0].icon),
              _buildNavItem(1, _tabs[1].icon),
              _buildCenterButton(),
              _buildNavItem(3, _tabs[3].icon),
              _buildNavItem(4, _tabs[4].icon),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 32),
      onPressed: () => navigationShell.goBranch(index),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => navigationShell.goBranch(2),
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFE57373),
          shape: BoxShape.circle,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.keyboard_double_arrow_up, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text(
              '生成する',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
