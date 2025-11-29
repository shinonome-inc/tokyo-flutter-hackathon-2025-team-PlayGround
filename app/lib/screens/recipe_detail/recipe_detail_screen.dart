import 'package:app/models/cooking_step.dart';
import 'package:app/models/ingredient.dart';
import 'package:app/models/recipe.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  Recipe recipeDetail = Recipe(
    id: 'fefafe-feaefa-fsaefsaef',
    title: '焼きそば',
    overview: '概要概要概要',
    imageUrl: 'https://firebasestorage.googleapis.com/v0/b/test-152ff.firebasestorage.app/o/uploads%2F1763090655187.png?alt=media&token=be782b65-63ff-4981-a0d4-dfd18eea420b',
    isAiGenerated: true,
    createdAt: DateTime(2025, 9, 30),
    user: const User(id: 'user_id_23', name: 'ユーザー名'),
    notes: '備考備考備考',
    ingredients: [
      const Ingredient(name: '卵', amount: '1個'),
      const Ingredient(name: '砂糖', amount: '適量'),
      const Ingredient(name: '小麦粉', amount: '200g'),
    ],
    steps: [
      const CookingStep(orderNumber: 1, description: 'ボウルに卵と砂糖を入れてよく混ぜる。'),
      const CookingStep(
        orderNumber: 2, 
        description: '小麦粉をふるわずそのまま入れて、さっくり混ぜる。(混ぜすぎない)',
      ),
      const CookingStep(
        orderNumber: 3, 
        description: 'スプーンで生地を落として形を整え、170度のオーブンで12〜15分焼く。',
      ),
    ],
    likeCount: 120,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Image.network(
              recipeDetail.imageUrl!, 
              gaplessPlayback: true, 
              fit: BoxFit.cover,
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
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFFFFFFFF).withAlpha(
                        (255 * 0.6).round(),
                        ),
                    ),
                    padding: const EdgeInsets.only(left: 8),
                    child: const Center(
                      child: Icon(
                      Icons.arrow_back_ios, 
                      color: Color(0xFF1D1B20),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFFFFFFFF).withAlpha(
                        (255 * 0.6).round(),
                        ),
                    ),
                    child: const Icon(
                      Icons.favorite_outline, 
                      color: Color(0xFF1D1B20),
                      size: 24,
                      ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              const Spacer(),
              Padding(
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
                      const SizedBox(height: 16),
                      Text(
                        recipeDetail.title ?? '', 
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                      ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          recipeDetail.overview ?? '',
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
                            Icons.favorite_outline, size: 20, 
                            color: Color(0xFF1D1B20),
                          ),
                          const SizedBox(width: 1),
                          Text(
                            '${recipeDetail.likeCount}',
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
                                recipeDetail.createdAt != null 
                                ? '${recipeDetail.createdAt!.year}/${recipeDetail.createdAt!.month}/${recipeDetail.createdAt!.day}'
                                : '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF6B6B6B),
                                ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                recipeDetail.user!.id!,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                              ...recipeDetail.ingredients!.map(
                                (ingredient) {
                                  final index = 
                                    recipeDetail.ingredients!.indexOf(
                                      ingredient,
                                    );
                                  return Column(
                                    children: [
                                      Row(
                                    children: [
                                      Text(
                                        ingredient.name!, 
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFF000000),
                                        ),
                                        ),
                                      const Spacer(),
                                      Text(
                                        ingredient.amount!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFF000000),
                                        ),
                                        ),
                                    ],
                                  ),
                                  if (
                                    index != 
                                      recipeDetail.ingredients!.length - 1
                                    ) ...[
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            ...recipeDetail.steps!.map((step) {
                        return Row(
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
                              child:const Icon(
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
                              child:const Icon(
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
                              child:const Icon(
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
            ],
          )
        ],
      ),
      );
  }
}
