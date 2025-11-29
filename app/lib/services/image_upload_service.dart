import 'dart:math';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

/// 画像アップロード機能を提供するサービスクラス
class ImageUploadService {
  ImageUploadService._();

  static final ImageUploadService instance = ImageUploadService._();

  /// S3に画像をアップロードして公開URLを返す
  Future<String> uploadImage(List<int> imageBytes) async {
    try {
      final fileName = _generateUniqueFileName();
      safePrint('Starting image upload: $fileName');
      
      final result = await Amplify.Storage.uploadData(
        data: S3DataPayload.bytes(imageBytes),
        path: StoragePath.fromString('recipe-images/$fileName'),
      ).result;
      
      safePrint('Upload completed: ${result.uploadedItem.path}');

      final urlResult = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(result.uploadedItem.path),
      ).result;
      
      safePrint('URL generated: ${urlResult.url}');
      return urlResult.url.toString();
    } on StorageException catch (e) {
      safePrint('StorageException: ${e.message}');
      throw Exception('S3アップロードエラー: ${e.message}');
    } catch (e) {
      safePrint('General error: $e');
      throw Exception('画像アップロードに失敗しました: $e');
    }
  }

  String _generateUniqueFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return '${timestamp}_$random.jpg';
  }
}