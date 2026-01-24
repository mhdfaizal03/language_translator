import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:language_translator/constants.dart';
import 'package:language_translator/decoration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:translator/translator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:language_translator/widgets/animated_list_item.dart';

import 'package:language_translator/services/storage_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  String initialLanguage = 'English'; // Default to English based on UI
  String endLanguage = 'Tamil'; // Default to Tamil based on UI
  String output = '';
  TextEditingController controller = TextEditingController();
  int charCount = 0;

  @override
  void initState() {
    super.initState();
    initTts();
    requestPermissions();
    _loadPreferences();
  }

  void _loadPreferences() {
    final prefs = StorageService().getLanguages();
    setState(() {
      initialLanguage = prefs['source']!;
      endLanguage = prefs['target']!;
    });
  }

  Future<void> initTts() async {
    flutterTts.setStartHandler(() => debugPrint("Playing"));
    flutterTts.setCompletionHandler(() => debugPrint("Complete"));
    flutterTts.setErrorHandler((msg) => debugPrint("Error: $msg"));

    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> requestPermissions() async {
    await [Permission.microphone, Permission.speech].request();
  }

  void translate(String end, String input) async {
    if (input.isEmpty) return;
    try {
      var translation = await translator.translate(
        input,
        from: getLanguageData(initialLanguage).code,
        to: end,
      );
      if (!mounted) return;

      setState(() {
        output = translation.text;
      });
      // Save functionality
      StorageService()
          .saveTranslation(initialLanguage, endLanguage, input, output);
      StorageService().saveLanguages(initialLanguage, endLanguage);
    } catch (e) {
      setState(() {
        output = 'Error: Translation failed!';
      });
    }
  }

  void _speak(String text, String langCode) async {
    if (langCode == 'auto') {
      await flutterTts.setLanguage('en-US');
    } else {
      await flutterTts.setLanguage(langCode);
    }
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  void _swapLanguages() {
    setState(() {
      String temp = initialLanguage;
      initialLanguage = endLanguage;
      endLanguage = temp;

      // Also swap text if there is output
      if (output.isNotEmpty) {
        controller.text = output;
        output = ''; // Clear output after swap to avoid confusion
        charCount = controller.text.length;
      }
    });
    StorageService().saveLanguages(initialLanguage, endLanguage);
  }

  void _shareText(String text) {
    if (text.isNotEmpty) {
      Share.share(text);
    }
  }

  void _showFullscreen(String text) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.scaffoldBackground,
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("Copied!")));
                  },
                  icon: const Icon(LucideIcons.copy),
                  label: const Text("Copy Text"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white))
            ],
          ),
        ),
      ),
    );
  }

  void _showHistory() {
    final history = StorageService().getTranslationHistory();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Translation History",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.white54),
                        onPressed: () => Navigator.pop(context))
                  ],
                )),
            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Text("No history yet",
                          style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return AnimatedListItem(
                          index: index,
                          child: ListTile(
                            title: Text(item['source_text'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                                "${item['source_lang']} -> ${item['target_lang']}",
                                style: const TextStyle(color: Colors.white54)),
                            trailing: const Icon(LucideIcons.chevronRight,
                                size: 14, color: Colors.white24),
                            onTap: () {
                              setState(() {
                                controller.text = item['source_text'];
                                output = item['target_text'];
                                charCount = controller.text.length;
                                initialLanguage = item['source_lang'];
                                endLanguage = item['target_lang'];
                              });
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StartBackgroundColor(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Top Bar with History
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSourceCard(),
                const SizedBox(height: 20),
                _buildTranslateButton(),
                const SizedBox(height: 20),
                if (output.isNotEmpty) _buildOutputCard(),
                const SizedBox(height: 40),
                const Text(
                  "Powered by TransVerse",
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: _buildLanguageDropdown(initialLanguage, (val) {
                setState(() => initialLanguage = val!);
                StorageService().saveLanguages(initialLanguage, endLanguage);
              }, isHighlighted: false),
            ),
            // const SizedBox(width: 8), // Perfected spacing
            InkWell(
              onTap: _swapLanguages,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.arrowRightLeft,
                    color: Colors.white70, size: 20), // Restored size
              ),
            ),
            const SizedBox(width: 8), // Symmetrical spacing
            Flexible(
              fit: FlexFit.loose,
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: _buildLanguageDropdown(endLanguage, (val) {
                    setState(() => endLanguage = val!);
                    StorageService()
                        .saveLanguages(initialLanguage, endLanguage);
                  }, isHighlighted: true),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.history, color: Colors.white70),
              onPressed: _showHistory,
              tooltip: "History",
            )
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .moveY(begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildLanguageDropdown(String value, Function(String?) onChanged,
      {required bool isHighlighted}) {
    // Ensure value exists or fallback
    if (!kLanguages.contains(value)) value = kLanguages.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppColors.cardBackground, // Dropdown menu background
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            icon: Icon(LucideIcons.chevronDown,
                color: isHighlighted ? Colors.white : Colors.white70, size: 18),
            style: TextStyle(
              color: isHighlighted ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
            onChanged: onChanged,
            items: kLanguages.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOut),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .moveY(begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildSourceCard() {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.25, // Responsive fixed height
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "SOURCE TEXT",
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
              Text(
                "$charCount/5000",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, height: 1.5),
              maxLines: null, // Allow expanding
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Enter text to translate...',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
              ),
              onChanged: (text) {
                setState(() {
                  charCount = text.length;
                  if (text.isEmpty) output = '';
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    _speak(controller.text,
                        getLanguageData(initialLanguage).locale);
                  }
                },
                icon: const Icon(LucideIcons.mic, color: Colors.white54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: controller.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Copied Source Text")),
                        );
                      }
                    },
                    icon: const Icon(LucideIcons.copy,
                        color: Colors.white54, size: 20),
                    tooltip: "Copy Text",
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () async {
                      ClipboardData? cdata =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (cdata != null && cdata.text != null) {
                        setState(() {
                          controller.text = cdata.text!;
                          charCount = controller.text.length;
                        });
                      }
                    },
                    icon: const Icon(LucideIcons.clipboard,
                        size: 18, color: AppColors.primary),
                    label: const Text("Paste",
                        style: TextStyle(color: AppColors.primary)),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .moveY(begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildTranslateButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (controller.text.isNotEmpty) {
              translate(getLanguageData(endLanguage).code, controller.text);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "Translate",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .moveY(begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildOutputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TRANSLATION",
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
              IconButton(
                onPressed: () {}, // Save functionality
                icon: const Icon(LucideIcons.bookmark,
                    color: Colors.white54, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            output,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          // Placeholder for Transliteration if available via API
          Text(
            _getTransliterationPlaceholder(output),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildActionButton(
                icon: LucideIcons.volume2,
                label: "Listen",
                isPrimary: true,
                onTap: () =>
                    _speak(output, getLanguageData(endLanguage).locale),
              ),
              const Spacer(),
              _buildIconAction(LucideIcons.copy, () {
                Clipboard.setData(ClipboardData(text: output));
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Copied!")));
              }),
              const SizedBox(width: 15),
              _buildIconAction(LucideIcons.share2, () => _shareText(output)),
              const SizedBox(width: 15),
              _buildIconAction(
                  LucideIcons.expand, () => _showFullscreen(output)),
            ],
          )
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .moveY(begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  // Helper to generate fake transliteration for UI demo purposes
  // since standard translator package might not return it
  String _getTransliterationPlaceholder(String text) {
    // In a real app, this would come from the API
    return "";
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required bool isPrimary,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isPrimary ? AppColors.primary : Colors.white54),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: isPrimary ? AppColors.primary : Colors.white54,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: 400.ms, duration: 400.ms)
          .moveY(begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildIconAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: Colors.white54, size: 22),
      ),
    );
  }
}
