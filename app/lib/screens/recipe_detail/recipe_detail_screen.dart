import 'package:app/enums/app_page.dart';
import 'package:app/models/cooking_step.dart';
import 'package:app/models/ingredient.dart';
import 'package:app/models/recipe.dart';
import 'package:app/models/user.dart';
import 'package:app/screens/recipe_detail/recipe_detail_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RecipeDetailScreen extends StatefulHookConsumerWidget {
  const RecipeDetailScreen({super.key});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final recipe = ref.watch(
      recipeDetailProvider.select((value) => value.recipe),
    ) ?? Recipe(
      id: 'sample_id',
      title: 'チキンカレー',
      overview: '本格的なスパイスを使った美味しいチキンカレーです。',
      imageUrl: 'https://via.placeholder.com/300/FFB6C1/000000?text=ChickenCurry',
      isAiGenerated: false,
      isLikedByMe: false,
      likeCount: 42,
      createdAt: DateTime.now(),
      user: const User(
        name: 'クック太郎',
        id: 'user1',
      ),
      ingredients: const [
        Ingredient(id: '1', name: '鶏肉', amount: '300g'),
        Ingredient(id: '2', name: '玉ねぎ', amount: '1個'),
        Ingredient(id: '3', name: 'トマト缶', amount: '1缶'),
        Ingredient(id: '4', name: 'カレー粉', amount: '大さじ2'),
        Ingredient(id: '5', name: 'ココナッツミルク', amount: '200ml'),
      ],
      steps: const [
        CookingStep(orderNumber: 1, description: '鶏肉を一口大に切る'),
        CookingStep(orderNumber: 2, description: '玉ねぎを薄切りにする'),
        CookingStep(orderNumber: 3, description: 'フライパンで鶏肉を炒める'),
        CookingStep(orderNumber: 4, description: '玉ねぎを加えて炒める'),
        CookingStep(orderNumber: 5, description: 'カレー粉を加えて香りを出す'),
        CookingStep(orderNumber: 6, description: 'トマト缶とココナッツミルクを加えて煮込む'),
      ],
    );
    final isLiked = useState(recipe.isLikedByMe ?? false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: recipe.imageUrl!.isNotEmpty
                    ? Image.network(
                        recipe.imageUrl!,
                        gaplessPlayback: true,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            color: const Color(0xFFF5F5F5),
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Color(0xFF9E9E9E),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
              ),
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    'assets/images/recipe_detail_backgound.jpg',
                    gaplessPlayback: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Row(
                children: [
                  const SizedBox(width: 24),
                  InkWell(
                    onTap: () {
                      context.go(AppPage.recipeList.path);
                    },
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(
                          0xFFFFFFFF,
                        ).withAlpha((255 * 0.6).round()),
                      ),
                      padding: const EdgeInsets.only(left: 8),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF1D1B20),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      isLiked.value = !isLiked.value;
                    },
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(
                          0xFFFFFFFF,
                        ).withAlpha((255 * 0.6).round()),
                      ),
                      child: Icon(
                        isLiked.value
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: const Color(0xFF1D1B20),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.64),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      color: Color(0xFFFFFFFF),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  recipe.title ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    recipe.overview ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.favorite_outline,
                                      size: 20,
                                      color: Color(0xFF1D1B20),
                                    ),
                                    const SizedBox(width: 1),
                                    Text(
                                      '${recipe.likeCount}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                    const Spacer(),
                                    Column(
                                      children: [
                                        Text(
                                          recipe.createdAt != null
                                              ? '${recipe.createdAt!.year}/${recipe.createdAt!.month}/${recipe.createdAt!.day}'
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                            color: Color(0xFF6B6B6B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          recipe.user!.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                            color: Color(0xFF6B6B6B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xFFEFEFEF),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    child: Column(
                                      children: [
                                        ...recipe.ingredients!.map((
                                          ingredient,
                                        ) {
                                          final index = recipe.ingredients!
                                              .indexOf(ingredient);
                                          return Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    ingredient.name!,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Color(0xFF000000),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    ingredient.amount!,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Color(0xFF000000),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (index !=
                                                  recipe.ingredients!.length -
                                                      1) ...[
                                                const SizedBox(height: 8),
                                              ],
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  '作り方',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      ...recipe.steps!.map((step) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${step.orderNumber}.',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300,
                                                color: Color(0xFF000000),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                step.description!,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF000000),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 38),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Container(
                              height: 46,
                              width: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: const Color(0xFF797979),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Color(0xFFFFFFFF),
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              height: 46,
                              width: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: const Color(0xFFFF6464),
                              ),
                              child: const Icon(
                                Icons.comment,
                                color: Color(0xFFFFFFFF),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              height: 46,
                              width: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: const Color(0xFFFF9A6B),
                              ),
                              child: const Icon(
                                Icons.share,
                                color: Color(0xFFFFFFFF),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
