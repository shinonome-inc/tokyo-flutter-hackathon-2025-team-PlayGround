import 'dart:io';

import 'package:app/utils/image_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SampleCameraScreen extends HookWidget {
  const SampleCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageFile = useState<File?>(null);
    return Scaffold(
      appBar: AppBar(title: const Text('サンプルカメラ画面'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 16),
          if (imageFile.value != null) ...[
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 30,
                height: MediaQuery.of(context).size.width - 30,
                child: Image.file(
                  imageFile.value!,
                  gaplessPlayback: true,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ] else ...[
            const Center(child: Text('写真が選択されていません')),
          ],
          const SizedBox(height: 16),
          if (imageFile.value != null) ...[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  imageFile.value = null;
                },
                child: const Text('写真を削除'),
              ),
            ),
          ] else ...[
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final image = await ImageUtil().takePicture();
                  if (image != null) {
                    imageFile.value = image;
                  }
                },
                child: const Text('写真を撮影'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
