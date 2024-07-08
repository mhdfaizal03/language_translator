import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_translator/decoration.dart';
import 'package:language_translator/image_picker.dart';
import 'package:language_translator/recognition_response.dart';
import 'package:language_translator/text_recognizer.dart';

class ScanToText extends StatefulWidget {
  const ScanToText({super.key});

  @override
  State<ScanToText> createState() => _ScanToTextState();
}

class _ScanToTextState extends State<ScanToText> {
  late ImagePicker _picker;
  late ITextRecognizer _recognizer;
  RecognitionResponse? _response;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    _recognizer = MLKitTextRecognizer();
  }

  @override
  void dispose() {
    super.dispose();
    if (_recognizer is MLKitTextRecognizer) {
      (_recognizer as MLKitTextRecognizer).dispose();
    }
  }

  void processImage(String imgPath) async {
    final recognizedText = await _recognizer.processImage(imgPath);
    setState(() {
      _response =
          RecognitionResponse(imgPath: imgPath, recognizedText: recognizedText);
    });
  }

  Future<String?> obtainImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    return file?.path;
  }

  @override
  Widget build(BuildContext context) {
    return StartBackgroundColor(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white30,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => imagePickAlert(
                onCameraPressed: () async {
                  // Pick image from Camera
                  final imgPath = await obtainImage(ImageSource.camera);
                  if (imgPath == null) return;
                  processImage(imgPath);
                  Get.back();
                },
                onGalleryPressed: () async {
                  // Pick image from Gallery
                  final imgPath = await obtainImage(ImageSource.gallery);
                  if (imgPath == null) return;
                  processImage(imgPath);
                  Get.back();
                },
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Text Recognition',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: _response == null
            ? const Center(
                child: Text('Pick image to continue'),
              )
            : ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    child: Image.file(File(_response!.imgPath)),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Recognized Text",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                        text: _response!.recognizedText),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to Clipboard'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(_response!.recognizedText),
                        ],
                      )),
                ],
              ),
      ),
    );
  }
}
