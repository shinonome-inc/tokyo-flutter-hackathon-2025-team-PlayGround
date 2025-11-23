import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageUtil {
  Future<File?> takePicture() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
