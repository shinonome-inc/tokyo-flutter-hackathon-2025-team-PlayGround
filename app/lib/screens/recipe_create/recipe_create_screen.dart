import 'package:app/providers/auth_user_provider.dart';
import 'package:app/screens/recipe_create/recipe_create_notifier.dart';
import 'package:app/utils/date_format_util.dart';
import 'package:app/widgets/loading_view.dart';
import 'package:app/widgets/network_error_view.dart';
import 'package:app/widgets/not_login_view.dart';
import 'package:app/widgets/recipe_form/recipe_create_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecipeCreateScreen extends ConsumerStatefulWidget {
  const RecipeCreateScreen({super.key});

  @override
  ConsumerState<RecipeCreateScreen> createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends ConsumerState<RecipeCreateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final List<Map<String, TextEditingController>> _ingredients = [];

  @override
  void initState() {
    super.initState();
    _addIngredient();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    for (final ingredient in _ingredients) {
      ingredient['name']?.dispose();
      ingredient['amount']?.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({
        'name': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _onTapDelete() {
    // TODO: 削除処理
  }

  Future<void> _onTapPost() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('タイトルを入力してください');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showSnackBar('概要を入力してください');
      return;
    }
    if (_instructionsController.text.trim().isEmpty) {
      _showSnackBar('作り方を入力してください');
      return;
    }

    final hasValidIngredient = _ingredients.any((ingredient) =>
        (ingredient['name']?.text.trim().isNotEmpty ?? false) &&
        (ingredient['amount']?.text.trim().isNotEmpty ?? false));

    if (!hasValidIngredient) {
      _showSnackBar('材料を1つ以上入力してください');
      return;
    }

    await ref.read(recipeCreateProvider.notifier).createRecipe(
      title: _titleController.text.trim(),
      overview: _descriptionController.text.trim(),
      instructions: _instructionsController.text.trim(),
      ingredients: _ingredients,
    );

    final state = ref.read(recipeCreateProvider);
    if (state.isSuccess) {
      _showSnackBar('レシピを投稿しました');
      context.pop();
    } else if (state.hasNetworkError) {
      _showSnackBar('投稿に失敗しました。再度お試しください。');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onTapImageArea() {
    // TODO: 画像選択処理
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormatUtil.formatNow();
    final authUserAsync = ref.watch(authUserProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: authUserAsync.when(
        data: (authUser) {
          if (authUser == null) {
            return const NotLoginView();
          }
          final userId = authUser.userId;
          return _buildRecipeCreateForm(currentDate, userId);
        },
        loading: () => const LoadingView(),
        error: (_, __) => NetworkErrorView(
          onTapReload: () {
            context.pop();
          },
        ),
      ),
    );
  }

  Widget _buildRecipeCreateForm(String currentDate, String userId) {
    return RecipeCreateForm(
      currentDate: currentDate,
      userId: userId,
      titleController: _titleController,
      descriptionController: _descriptionController,
      instructionsController: _instructionsController,
      ingredients: _ingredients,
      onTapImageArea: _onTapImageArea,
      onAddIngredient: _addIngredient,
      onTapDelete: _onTapDelete,
      onTapPost: _onTapPost,
    );
  }
}
