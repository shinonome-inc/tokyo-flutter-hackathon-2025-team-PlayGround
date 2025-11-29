import 'package:app/screens/confirm_code/confirm_code_screen.dart';
import 'package:app/screens/current_user/current_user_screen.dart';
import 'package:app/screens/licenses/licenses_screen.dart';
import 'package:app/screens/recipe_ai_generation/recipe_ai_generation_screen.dart';
import 'package:app/screens/recipe_create/recipe_create_screen.dart';
import 'package:app/screens/recipe_detail/recipe_detail_screen.dart';
import 'package:app/screens/recipe_edit/recipe_edit_screen.dart';
import 'package:app/screens/recipe_list/recipe_list_screen.dart';
import 'package:app/screens/settings/settings_screen.dart';
import 'package:app/screens/sign_in/sign_in_screen.dart';
import 'package:app/screens/sign_up/sign_up_screen.dart';
import 'package:app/screens/splash/splash_screen.dart';
import 'package:app/screens/user_create/user_create_screen.dart';
import 'package:app/screens/user_detail/user_detail_screen.dart';
import 'package:app/screens/user_edit/user_edit_screen.dart';
import 'package:app/screens/user_list/user_list_screen.dart';
import 'package:flutter/material.dart';

/// アプリ内の画面の列挙型。
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
  userList,
  userDetail,
  userCreate,
  userEdit,
  currentUser,
  settings,
  licenses;

  String get path => '/${name.replaceAll('_', '-')}';

  /// 各画面に対応するウィジェットを取得する。
  Widget get child {
    switch (this) {
      case AppPage.splash:
        return const SplashScreen();
      case AppPage.signIn:
        return const SignInScreen();
      case AppPage.signUp:
        return const SignUpScreen();
      case AppPage.confirmCode:
        return const ConfirmCodeScreen();
      case AppPage.recipeList:
        return const RecipeListScreen();
      case AppPage.recipeDetail:
        return const RecipeDetailScreen();
      case AppPage.recipeCreate:
        return const RecipeCreateScreen();
      case AppPage.recipeEdit:
        return const RecipeEditScreen();
      case AppPage.recipeAiGeneration:
        return const RecipeAiGenerationScreen();
      case AppPage.userList:
        return const UserListScreen();
      case AppPage.userDetail:
        return const UserDetailScreen();
      case AppPage.userCreate:
        return const UserCreateScreen();
      case AppPage.userEdit:
        return const UserEditScreen();
      case AppPage.currentUser:
        return const CurrentUserScreen();
      case AppPage.settings:
        return const SettingsScreen();
      case AppPage.licenses:
        return const LicensesScreen();
    }
  }
}
