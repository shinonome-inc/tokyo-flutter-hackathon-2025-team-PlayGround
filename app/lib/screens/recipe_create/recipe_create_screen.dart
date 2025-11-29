import 'package:app/providers/auth_user_provider.dart';
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

  void _onTapPost() {
    // TODO: レシピ投稿処理
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
