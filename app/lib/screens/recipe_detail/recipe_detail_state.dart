import 'package:app/models/recipe.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_detail_state.freezed.dart';

@freezed
abstract class RecipeDetailState with _$RecipeDetailState {
  const factory RecipeDetailState({@Default(null) Recipe? recipe}) =
      _RecipeDetailState;
}
