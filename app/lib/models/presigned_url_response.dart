import 'package:freezed_annotation/freezed_annotation.dart';

part 'presigned_url_response.freezed.dart';
part 'presigned_url_response.g.dart';

@freezed
abstract class PresignedUrlResponse with _$PresignedUrlResponse {
  const factory PresignedUrlResponse({
    required String uploadUrl,
    required String imageS3Key,
  }) = _PresignedUrlResponse;

  factory PresignedUrlResponse.fromJson(Map<String, Object?> json) =>
      _$PresignedUrlResponseFromJson(json);
}
