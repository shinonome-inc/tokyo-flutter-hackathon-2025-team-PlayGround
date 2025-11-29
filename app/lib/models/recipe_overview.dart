import 'package:app/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_overview.freezed.dart';
part 'recipe_overview.g.dart';

@freezed
abstract class RecipeOverview with _$RecipeOverview {
  const factory RecipeOverview({
    String? id,
    String? title,
    String? overview,
    String? imageUrl,
    bool? isAiGenerated,
    DateTime? createdAt,
    User? user,
  }) = _RecipeOverview;

  factory RecipeOverview.fromJson(Map<String, Object?> json) =>
      _$RecipeOverviewFromJson(json);
}
