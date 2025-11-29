import 'package:app/models/comment.dart';
import 'package:app/models/ingredient.dart';
import 'package:app/models/step.dart';
import 'package:app/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_detail.freezed.dart';
part 'recipe_detail.g.dart';

@freezed
abstract class RecipeDetail with _$RecipeDetail {
  const factory RecipeDetail({
    String? id,
    String? title,
    String? overview,
    String? imageUrl,
    bool? isAiGenerated,
    DateTime? createdAt,
    User? user,
    String? notes,
    List<Ingredient>? ingredients,
    List<Step>? steps,
    List<Comment>? comments,
    bool? isLikedByMe,
    int? likeCount,
  }) = _RecipeDetail;

  factory RecipeDetail.fromJson(Map<String, Object?> json) =>
      _$RecipeDetailFromJson(json);
}
