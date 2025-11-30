import 'package:app/enums/app_page.dart';
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
    final recipeDetail = ref.watch(recipeDetailProvider);
    final isLiked = useState(recipeDetail.recipe!.isLikedByMe);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              if (recipeDetail.recipe!.imageUrl!.isNotEmpty)...[
              SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Image.network(
              recipeDetail.recipe!.imageUrl!, 
              gaplessPlayback: true, 
              fit: BoxFit.cover,
              ),
          ),
          ],
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
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      isLiked.value = !isLiked.value!;
                    },
                    child: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFFFFFFFF).withAlpha(
                        (255 * 0.6).round(),
                        ),
                    ),
                    child: Icon(
                      isLiked.value! 
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
                        recipeDetail.recipe!.title ?? '', 
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
                          recipeDetail.recipe!.overview ?? '',
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
                            '${recipeDetail.recipe!.likeCount}',
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
                                recipeDetail.recipe!.createdAt != null 
                                ? '${recipeDetail.recipe!.createdAt!.year}/${recipeDetail.recipe!.createdAt!.month}/${recipeDetail.recipe!.createdAt!.day}'
                                : '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF6B6B6B),
                                ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                recipeDetail.recipe!.user!.id!,
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
                              ...recipeDetail.recipe!.ingredients!.map(
                                (ingredient) {
                                  final index = 
                                    recipeDetail.recipe!.ingredients!.indexOf(
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
                                    index 
                                      != recipeDetail.recipe!.ingredients!.length - 1
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
                            ...recipeDetail.recipe!.steps!.map((step) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
