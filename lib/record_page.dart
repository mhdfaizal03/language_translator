import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:language_translator/decoration.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:translator/translator.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late stt.SpeechToText _speech;
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  bool _isListening = false;
  String _text = '';
  String _translatedText = '';
  String freezelanguage = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> startListening() async {
    try {
      bool available = await _speech.initialize(
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() => _text = result.recognizedWords);
            translateText(endLanguage, _text); // Pass endLanguage here
          },
        );
      } else {
        print('Speech recognition not available');
      }
    } catch (err) {
      print('Error initializing speech: $err');
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> translateText(String end, String input) async {
    try {
      String endLang = languageCodes[endLanguage]!;
      var translation = await translator.translate(
        input,
        to: endLang,
      );
      setState(() {
        _translatedText = translation.text;
      });
    } catch (e) {
      print('Translation error: $e');
      setState(() {
        _translatedText = 'Translation error';
      });
    }
    _speak(_translatedText, languageCodes[endLanguage]!);
  }

  void _speak(String text, String langCode) async {
    await flutterTts.setLanguage(langCode);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  final List<String> languages = [
    'auto',
    'English',
    'Hindi',
    'Marathi',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Korean',
    'Italian',
    'Malayalam',
    'Arabic',
    'Russian',
    'Portuguese',
    'Bengali',
    'Dutch',
    'Swedish',
    'Thai',
    'Turkish',
    'Vietnamese',
    'Greek',
    'Polish',
    'Romanian',
    'Hungarian',
  ];

  final Map<String, String> languageCodes = {
    'auto': 'auto',
    'English': 'en',
    'Hindi': 'hi',
    'Marathi': 'mr',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Chinese': 'zh',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Italian': 'it',
    'Malayalam': 'ml',
    'Arabic': 'ar',
    'Russian': 'ru',
    'Portuguese': 'pt',
    'Bengali': 'bn',
    'Dutch': 'nl',
    'Swedish': 'sv',
    'Thai': 'th',
    'Turkish': 'tr',
    'Vietnamese': 'vi',
    'Greek': 'el',
    'Polish': 'pl',
    'Romanian': 'ro',
    'Hungarian': 'hu',
  };

  String initialLanguage = 'auto';
  String endLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return StartBackgroundColor(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Voice Translator',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      _text.isEmpty ? 'Voice to text' : _text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.speaker_rounded,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: _text.isEmpty
                            ? null
                            : () {
                                Clipboard.setData(ClipboardData(text: _text))
                                    .then((value) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(20),
                                          content:
                                              Text('Text copied successfully'),
                                        )));
                              },
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      _translatedText.isEmpty
                          ? 'Your translated text will appear here'
                          : _translatedText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.speaker_rounded,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: _translatedText.isEmpty
                            ? null
                            : () {
                                Clipboard.setData(
                                        ClipboardData(text: _translatedText))
                                    .then((value) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(20),
                                          content:
                                              Text('Text copied successfully'),
                                        )));
                              },
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 30,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black26,
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                          borderRadius: BorderRadius.circular(20),
                          underline: const SizedBox(),
                          focusColor: Colors.black,
                          iconDisabledColor: Colors.grey,
                          iconEnabledColor: Colors.white,
                          value: initialLanguage,
                          onChanged: (String? value) {
                            try {
                              setState(() {
                                initialLanguage = value!;
                              });
                            } catch (e) {
                              print('Dropdown error: $e');
                            }
                          },
                          items: languages.map((String dropdownItem) {
                            return DropdownMenuItem<String>(
                              value: dropdownItem,
                              child: Text(dropdownItem),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          freezelanguage = initialLanguage;
                          initialLanguage = endLanguage;
                          endLanguage = freezelanguage;
                        });
                      },
                      icon: const Icon(
                        Icons.arrow_circle_right_outlined,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black26,
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                          borderRadius: BorderRadius.circular(20),
                          underline: const SizedBox(),
                          focusColor: Colors.white,
                          iconDisabledColor: Colors.grey,
                          iconEnabledColor: Colors.white,
                          value: endLanguage,
                          onChanged: (String? value) {
                            try {
                              setState(() {
                                endLanguage = value!;
                              });
                            } catch (e) {
                              print('Dropdown error: $e');
                            }
                          },
                          items: languages.map((String dropdownItem) {
                            return DropdownMenuItem<String>(
                              value: dropdownItem,
                              child: Text(dropdownItem),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _isListening ? stopListening : startListening,
                  icon: Icon(_isListening ? Icons.stop : Icons.mic),
                  iconSize: 48.0,
                  color: _isListening ? Colors.red : Colors.blue,
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
