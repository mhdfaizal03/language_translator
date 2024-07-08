import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class ITextRecognizer {
  Future<String> processImage(String imgPath);
}

class MLKitTextRecognizer extends ITextRecognizer {
  late TextRecognizer recognizer;

  MLKitTextRecognizer() {
    recognizer = TextRecognizer();
  }

  void dispose() {
    recognizer.close();
  }

  @override
  Future<String> processImage(String imgPath) async {
    final image = InputImage.fromFile(File(imgPath));
    final recognized = await recognizer.processImage(image);
    return recognized.text;
  }
}
