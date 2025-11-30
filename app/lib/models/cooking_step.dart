import 'package:freezed_annotation/freezed_annotation.dart';

part 'cooking_step.freezed.dart';
part 'cooking_step.g.dart';

@freezed
abstract class CookingStep with _$CookingStep {
  const factory CookingStep({int? orderNumber, String? description}) =
      _CookingStep;

  factory CookingStep.fromJson(Map<String, Object?> json) =>
      _$CookingStepFromJson(json);
}
