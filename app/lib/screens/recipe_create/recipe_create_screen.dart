import 'package:app/providers/auth_user_provider.dart';
import 'package:app/screens/recipe_create/recipe_create_notifier.dart';
import 'package:app/screens/recipe_create/recipe_create_state.dart';
import 'package:app/services/image_upload_service.dart';
import 'package:app/utils/date_format_util.dart';
import 'package:app/widgets/loading_view.dart';
import 'package:app/widgets/network_error_view.dart';
import 'package:app/widgets/not_login_view.dart';
import 'package:app/widgets/recipe_form/recipe_create_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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
  String? _imageUrl;

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
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _instructionsController.clear();
      
      // 既存の材料コントローラーを破棄
      for (final ingredient in _ingredients) {
        ingredient['name']?.dispose();
        ingredient['amount']?.dispose();
      }
      
      // 材料リストを初期状態（1個）にリセット
      _ingredients.clear();
      _ingredients.add({
        'name': TextEditingController(),
        'amount': TextEditingController(),
      });
      _imageUrl = null;
    });
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
      imageUrl: _imageUrl,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onTapImageArea() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      try {
        final imageBytes = await image.readAsBytes();
        final imageUrl = await ImageUploadService.instance.uploadImage(imageBytes);
        setState(() {
          _imageUrl = imageUrl;
        });
        _showSnackBar('画像をアップロードしました');
      } catch (e) {
        _showSnackBar('画像のアップロードに失敗しました');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormatUtil.formatNow();
    final authUserAsync = ref.watch(authUserProvider);
    
    // レシピ作成状態を監視
    ref.listen<RecipeCreateState>(recipeCreateProvider, (previous, next) {
      if (next.isSuccess && (previous?.isSuccess != true)) {
        _showSnackBar(next.successMessage.isNotEmpty ? next.successMessage : 'レシピを投稿しました');
      } else if (next.hasNetworkError && (previous?.hasNetworkError != true)) {
        _showSnackBar('投稿に失敗しました。再度お試しください。');
      }
    });
    
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
    return Scaffold(
      body: RecipeCreateForm(
        currentDate: currentDate,
        userId: userId,
        titleController: _titleController,
        descriptionController: _descriptionController,
        instructionsController: _instructionsController,
        ingredients: _ingredients,
        imageUrl: _imageUrl,
        onTapImageArea: _onTapImageArea,
        onAddIngredient: _addIngredient,
        onTapDelete: _onTapDelete,
        onTapPost: _onTapPost,
      ),
    );
  }
}
