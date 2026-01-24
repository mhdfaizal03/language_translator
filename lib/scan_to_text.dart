import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:language_translator/constants.dart';
import 'package:language_translator/recognition_response.dart';
import 'package:language_translator/text_recognizer.dart';
import 'package:translator/translator.dart';
import 'package:share_plus/share_plus.dart';

class ScanToText extends StatefulWidget {
  const ScanToText({super.key});

  @override
  State<ScanToText> createState() => _ScanToTextState();
}

class _ScanToTextState extends State<ScanToText> {
  late ImagePicker _picker;
  late ITextRecognizer _recognizer;
  final GoogleTranslator _translator = GoogleTranslator();

  // Camera State
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  RecognitionResponse? _response;
  bool _isLoading = false;

  // Translation State
  String _targetLanguage = 'English';
  String _translatedText = '';
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    _recognizer = MLKitTextRecognizer();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Camera permission is required")),
          );
        }
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      } else {
        debugPrint("No cameras found");
      }
    } catch (e) {
      debugPrint("Camera initialization error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // Dispose camera first
    if (_recognizer is MLKitTextRecognizer) {
      (_recognizer as MLKitTextRecognizer).dispose();
    }
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    if (_cameraController!.value.isTakingPicture) return;

    try {
      final image = await _cameraController!.takePicture();
      processImage(image.path);
    } catch (e) {
      debugPrint("Capture error: $e");
    }
  }

  void processImage(String imgPath) async {
    setState(() => _isLoading = true);
    final recognizedText = await _recognizer.processImage(imgPath);
    if (!mounted) return;

    setState(() {
      _response =
          RecognitionResponse(imgPath: imgPath, recognizedText: recognizedText);
      _isLoading = false;
      _translatedText = ''; // Reset previous translation
    });

    if (mounted && _response != null) {
      _showResultSheet();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file != null) {
      processImage(file.path);
    }
  }

  Future<void> _translateText() async {
    if (_response == null || _response!.recognizedText.isEmpty) return;

    setState(() => _isTranslating = true);
    try {
      final translation = await _translator.translate(_response!.recognizedText,
          to: getLanguageData(_targetLanguage).code);

      if (!mounted) return;

      setState(() {
        _translatedText = translation.text;
        _isTranslating = false;
      });
      Navigator.pop(context);
      _showResultSheet();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTranslating = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Translation failed")));
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Copied to Clipboard")));
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Select Target Language",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: kLanguages.length,
                itemBuilder: (context, index) {
                  final lang = kLanguages[index];
                  return ListTile(
                    title: Text(lang,
                        style: const TextStyle(color: Colors.white70)),
                    onTap: () {
                      setState(() => _targetLanguage = lang);
                      Navigator.pop(context); // Close picker
                      _showResultSheet(); // Reopen sheet
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildResultSheetContent(),
    );
  }

  Widget _buildResultSheetContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            0.85, // Taller if translation exists
      ),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5)
          ]),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),

            // --- DETECTED TEXT SECTION ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(LucideIcons.sparkles,
                      color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 12),
                const Text("DETECTED TEXT",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 12)),
                const Spacer(),
                InkWell(
                  onTap: () =>
                      _copyToClipboard(_response?.recognizedText ?? ""),
                  child: const Icon(LucideIcons.copy,
                      color: Colors.white54, size: 20),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(LucideIcons.x,
                      color: Colors.white54, size: 20),
                )
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF151520),
                  borderRadius: BorderRadius.circular(16)),
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Text(_response?.recognizedText ?? "",
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 15, height: 1.5)),
              ),
            ),

            const SizedBox(height: 20),

            // --- TRANSLATE ACTION ---
            if (_translatedText.isEmpty && !_isTranslating)
              ElevatedButton.icon(
                onPressed: _translateText,
                icon: const Icon(LucideIcons.sparkles,
                    color: Colors.white, size: 20),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Translate to $_targetLanguage",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        Navigator.pop(
                            context); // Close sheet to avoid overlay issues
                        _showLanguagePicker(); // Show picker
                      },
                      child: const Icon(LucideIcons.chevronDown,
                          color: Colors.white70),
                    )
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
              ),

            if (_isTranslating)
              const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),

            // --- TRANSLATED TEXT SECTION ---
            if (_translatedText.isNotEmpty) ...[
              const Divider(color: Colors.white10, height: 40),
              Row(
                children: [
                  const Icon(LucideIcons.languages,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Text("TRANSLATED ($_targetLanguage)",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontSize: 12)),
                  const Spacer(),
                  InkWell(
                    onTap: () => _copyToClipboard(_translatedText),
                    child: const Icon(LucideIcons.copy,
                        color: Colors.white54, size: 20),
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    onTap: () {
                      if (_translatedText.isNotEmpty) {
                        Share.share(_translatedText);
                      }
                    },
                    child: const Icon(LucideIcons.share2,
                        color: Colors.white54, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFF151520),
                    borderRadius: BorderRadius.circular(16)),
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Text(_translatedText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showLanguagePicker();
                },
                child: const Text("Change Language",
                    style: TextStyle(color: AppColors.primary)),
              )
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // --- Live Camera Layer ---
            if (_isCameraInitialized && _cameraController != null)
              SizedBox.expand(child: CameraPreview(_cameraController!))
            else
              Container(color: Colors.black),

            // --- Overlay Layer ---
            Column(
              children: [
                const Spacer(),
                // Viewfinder (Transparent center with border)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  child: Stack(
                    children: [
                      _buildCorner(Alignment.topLeft),
                      _buildCorner(Alignment.topRight),
                      _buildCorner(Alignment.bottomLeft),
                      _buildCorner(Alignment.bottomRight),
                      Center(
                        child: Container(
                          height: 2,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary,
                                    blurRadius: 10,
                                    spreadRadius: 2)
                              ]),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: const Center(
                            child: Text("Align text within frame",
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12))),
                      )
                    ],
                  ),
                ),
                const Spacer(),

                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildPillButton(
                              "Take Photo",
                              LucideIcons.camera,
                              _takePicture)), // Use live capture
                      const SizedBox(width: 15),
                      Expanded(
                          child: _buildPillButton("Gallery", LucideIcons.image,
                              () => _pickImage(ImageSource.gallery))),
                    ],
                  ),
                )
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              )
          ],
        ));
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            border: Border(
          top: alignment.y == -1
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          bottom: alignment.y == 1
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          left: alignment.x == -1
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          right: alignment.x == 1
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
        )),
      ),
    );
  }

  Widget _buildPillButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: const Color(0xFF2C2C35)
                .withOpacity(0.8), // added opacity for camera visibility
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10)),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600))
          ],
        ),
      ),
    );
  }
}
