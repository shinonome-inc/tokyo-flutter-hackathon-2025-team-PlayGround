import 'package:app/enums/app_page.dart';
import 'package:app/widgets/layout_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _bottomNavigationPages = <AppPage>[
  AppPage.recipeList,
  AppPage.recipeCreate,
  AppPage.recipeAiGeneration,
  AppPage.userList,
  AppPage.currentUser,
];

/// プロジェクトの画面遷移に関するルーティング設定。
///
/// ルーティングする画面の追加・削除・変更を行う場合は、列挙型`AppPage`を変更する。
final router = GoRouter(
  initialLocation: AppPage.signIn.path,
  routes: [
    // BottomNavigationBar用のルーティング
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          LayoutScaffold(navigationShell: navigationShell),
      branches: [
        for (final branch in _bottomNavigationPages)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: branch.path,
                pageBuilder: (context, state) =>
                    MaterialPage(key: state.pageKey, child: branch.child),
              ),
            ],
          ),
      ],
    ),
    // 全画面のルーティング
    for (final page in AppPage.values)
      GoRoute(
        path: page.path,
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: switch (page) {
              _ => page.child,
            },
          );
        },
      ),
  ],
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: Scaffold(body: Center(child: Text(state.error.toString()))),
  ),
);
