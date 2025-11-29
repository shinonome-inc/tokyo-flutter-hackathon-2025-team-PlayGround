import 'package:flutter/material.dart';

enum AppPage {
  splash,
  signIn,
  signUp,
  confirmCode,
  recipeList,
  recipeDetail,
  recipeCreate,
  recipeEdit,
  recipeAiGeneration,
  recipeAiLoading,
  userList,
  userDetail,
  userCreate,
  userEdit,
  currentUser,
  settings,
  termsOfService,
  privacyPolicy,
  licenses;

  String get path => '/${name.replaceAll('_', '-')}';

  Widget get child {
    switch (this) {
      case AppPage.splash:
        return const Placeholder();
      case AppPage.signIn:
        return const Placeholder();
      case AppPage.signUp:
        return const Placeholder();
      case AppPage.confirmCode:
        return const Placeholder();
      case AppPage.recipeList:
        return const Placeholder();
      case AppPage.recipeDetail:
        return const Placeholder();
      case AppPage.recipeCreate:
        return const Placeholder();
      case AppPage.recipeEdit:
        return const Placeholder();
      case AppPage.recipeAiGeneration:
        return const Placeholder();
      case AppPage.recipeAiLoading:
        return const Placeholder();
      case AppPage.userList:
        return const Placeholder();
      case AppPage.userDetail:
        return const Placeholder();
      case AppPage.userCreate:
        return const Placeholder();
      case AppPage.userEdit:
        return const Placeholder();
      case AppPage.currentUser:
        return const Placeholder();
      case AppPage.settings:
        return const Placeholder();
      case AppPage.termsOfService:
        return const Placeholder();
      case AppPage.privacyPolicy:
        return const Placeholder();
      case AppPage.licenses:
        return const Placeholder();
    }
  }
}
