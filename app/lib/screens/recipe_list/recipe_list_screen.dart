import 'package:app/enums/app_page.dart';
import 'package:app/screens/recipe_list/recipe_list_item.dart';
import 'package:app/screens/recipe_list/recipe_list_notifier.dart';
import 'package:app/screens/recipe_list/recipe_list_state.dart';
import 'package:app/widgets/loading_view.dart';
import 'package:app/widgets/network_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  void _onTapRecipeItem() {
    context.go(AppPage.recipeDetail.path);
  }

  void onTapLike() {
    // TODO: いいね処理
  }

  Future<void> _onTapReload() async {
    await ref.read(recipeListProvider.notifier).fetchRecipes();
  }

  Future<void> _onRefresh() async {
    await ref.read(recipeListProvider.notifier).fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeListProvider);
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '小麦粉、卵、砂糖、3分',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.tune),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFEFEFEF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: switch (state) {
                  RecipeListState(:final isLoading) when isLoading =>
                    const LoadingView(),
                  RecipeListState(:final hasNetworkError)
                      when hasNetworkError =>
                    NetworkErrorView(onTapReload: _onTapReload),
                  _ => RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      itemCount: state.recipes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return RecipeListItem(
                          recipe: state.recipes[index],
                          onTapItem: _onTapRecipeItem,
                          onTapLike: onTapLike,
                        );
                      },
                    ),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
