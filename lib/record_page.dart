import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:translator/translator.dart';
import 'package:language_translator/constants.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:language_translator/widgets/animated_list_item.dart';

import 'package:language_translator/services/storage_service.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage>
    with AutomaticKeepAliveClientMixin {
  late stt.SpeechToText _speech;
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  bool _isListening = false;
  String initialLanguage = 'English';
  String endLanguage = 'Japanese'; // Matching reference image default

  // Simple list to store conversation history for the chat UI
  List<Map<String, dynamic>> conversation = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    requestPermissions();
    _loadData();
  }

  void _loadData() {
    final prefs = StorageService().getLanguages();
    final hist = StorageService().getVoiceHistory();
    setState(() {
      initialLanguage = prefs['source']!;
      endLanguage = prefs['target']!;
      conversation = hist;
    });
  }

  Future<void> requestPermissions() async {
    // Just request, we'll check status before acting
    await [Permission.microphone, Permission.speech].request();
  }

  Future<void> startListening() async {
    // Check permissions first
    var micStatus = await Permission.microphone.status;
    var speechStatus = await Permission.speech.status;

    if (!micStatus.isGranted) micStatus = await Permission.microphone.request();
    if (!speechStatus.isGranted)
      speechStatus = await Permission.speech.request();

    if (micStatus.isDenied || speechStatus.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission required")),
        );
      }
      return;
    }

    try {
      bool available = await _speech.initialize(
        onError: (error) => debugPrint('Error: $error'),
      );
      if (!mounted) return;

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            // In a real app, we would process partial results here
            // For now, we wait for the final result or user stop
            if (result.finalResult) {
              _handleSpeechResult(result.recognizedWords);
            }
          },
        );
      }
    } catch (err) {
      debugPrint('Error initializing speech: $err');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Speech initialization failed")),
        );
      }
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _handleSpeechResult(String text) {
    if (text.isEmpty) return;

    // Add user text
    setState(() {
      conversation.add({'text': text, 'isUser': true, 'lang': initialLanguage});
    });
    StorageService().saveVoiceHistory(conversation);

    // Determine target code
    String targetCode = kLanguageCodes[endLanguage] ?? 'en';

    // Translate
    translator.translate(text, to: targetCode).then((translation) {
      if (mounted) {
        setState(() {
          conversation.add({
            'text': translation.text,
            'isUser': false,
            'lang': endLanguage,
            // 'transliteration': '...' // If available
          });
        });
        StorageService().saveVoiceHistory(conversation);
        // Auto speak translation
        _speak(translation.text, targetCode);
      }
    });
  }

  void _speak(String text, String langCode) async {
    await flutterTts.setLanguage(langCode);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  void _swapLanguages() {
    setState(() {
      String temp = initialLanguage;
      initialLanguage = endLanguage;
      endLanguage = temp;
    });
    StorageService().saveLanguages(initialLanguage, endLanguage);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for KeepAlive
    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by nav wrapper
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Voice Translation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildLanguageHeader(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: conversation.length,
              itemBuilder: (context, index) {
                final item = conversation[index];
                return AnimatedListItem(
                  index: index,
                  child: _buildChatBubble(item),
                );
              },
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  void _showLanguagePicker(bool isSource) {
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
                borderRadius: BorderRadius.circular(2),
              ),
            ).animate().fadeIn(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Select Language",
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
                      setState(() {
                        if (isSource) {
                          initialLanguage = lang;
                        } else {
                          endLanguage = lang;
                        }
                      });
                      StorageService()
                          .saveLanguages(initialLanguage, endLanguage);
                      Navigator.pop(context);
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

  Widget _buildLanguageHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLangPill(initialLanguage, Icons.flag,
              () => _showLanguagePicker(true)), // Source
          const SizedBox(width: 15),
          InkWell(
            onTap: _swapLanguages,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(LucideIcons.arrowRightLeft,
                  color: Colors.white54, size: 20),
            ),
          ),
          const SizedBox(width: 15),
          _buildLangPill(endLanguage, Icons.flag,
              () => _showLanguagePicker(false)), // Target
        ],
      ),
    );
  }

  Widget _buildLangPill(
      String language, IconData flagIcon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(flagIcon,
                color: Colors.redAccent, size: 16), // Example flag color
            const SizedBox(width: 8),
            Text(
              language,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> item) {
    bool isUser = item['isUser'];
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: InkWell(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: item['text']));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Copied to Clipboard")),
            );
          },
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isUser ? AppColors.cardBackground : AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['text'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                if (!isUser) ...[
                  const SizedBox(height: 10),
                  // Simulated transliteration
                  const Text(
                    "Simulated transliteration text...",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () =>
                          _speak(item['text'], kLanguageCodes[item['lang']]!),
                      icon: const Icon(LucideIcons.volume2,
                          color: Colors.white54, size: 20),
                    ),
                  )
                ],
                const SizedBox(height: 5),
                Text(
                  isUser ? "English • Just now" : "Japanese • Translated",
                  style: TextStyle(
                      color: isUser ? Colors.white38 : Colors.white60,
                      fontSize: 10),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text(
            _isListening ? "Listening..." : "Tap microphone to Talk",
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Audio Wave Visualization (Static lines for now)
          if (_isListening)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  8,
                  (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 4,
                        height: 15 + (index % 3) * 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
            ),
          if (_isListening) const SizedBox(height: 20),

          GestureDetector(
            onTap: _isListening ? stopListening : startListening,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5)
                  ]),
              child: Icon(
                _isListening ? LucideIcons.stopCircle : LucideIcons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_isListening)
            const Text("Tap to stop",
                style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
