import 'package:app/models/comment.dart';
import 'package:app/models/ingredient.dart';
import 'package:app/models/step.dart';
import 'package:app/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String title,
    required String overview,
    required String imageUrl,
    required bool isAiGenerated,
    required DateTime createdAt,
    required User user,
    required String notes,
    required List<Ingredient> ingredients,
    required List<Step> steps,
    required List<Comment> comments,
    required bool isLikedByMe,
    required int likeCount,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, Object?> json) => _$RecipeFromJson(json);
}
