import 'package:app/models/comment.dart';
import 'package:app/models/cooking_step.dart';
import 'package:app/models/ingredient.dart';
import 'package:app/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    String? title,
    String? overview,
    String? imageUrl,
    bool? isAiGenerated,
    DateTime? createdAt,
    User? user,
    String? notes,
    List<Ingredient>? ingredients,
    List<CookingStep>? steps,
    List<Comment>? comments,
    bool? isLikedByMe,
    int? likeCount,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, Object?> json) => _$RecipeFromJson(json);
}
