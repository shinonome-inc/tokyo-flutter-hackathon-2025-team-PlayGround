import 'package:app/models/cooking_step.dart';
import 'package:app/models/ingredient.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_create_input.freezed.dart';
part 'recipe_create_input.g.dart';

@freezed
abstract class RecipeCreateInput with _$RecipeCreateInput {
  const factory RecipeCreateInput({
    required String title,
    required String overview,
    String? imageUrl,
    String? notes,
    bool? isAiGenerated,
    List<Ingredient>? ingredients,
    List<CookingStep>? steps,
  }) = _RecipeCreateInput;

  factory RecipeCreateInput.fromJson(Map<String, Object?> json) =>
      _$RecipeCreateInputFromJson(json);
}
