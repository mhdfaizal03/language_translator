import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:language_translator/decoration.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  final List<String> languages = [
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
  String endLanguage = 'To';
  String output = '';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initTts();
    requestPermissions();
  }

  Future<void> initTts() async {
    flutterTts.setStartHandler(() {
      print("Playing");
    });

    flutterTts.setCompletionHandler(() {
      print("Complete");
    });

    flutterTts.setErrorHandler((msg) {
      print("Error: $msg");
    });

    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> requestPermissions() async {
    try {
      await Permission.microphone.request();
      await Permission.speech.request();
    } catch (e) {
      print("Error requesting permissions: $e");
      // Handle error as needed, e.g., show a dialog to the user
    }
  }

  void translate(String end, String input) async {
    try {
      var translation =
          await translator.translate(input, from: 'auto', to: end);
      setState(() {
        output = translation.text;
      });
    } catch (e) {
      setState(() {
        output = 'Error: Translation failed!';
      });
    }
  }

  void _speak(String text, String langCode) async {
    await flutterTts.setLanguage(langCode);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return StartBackgroundColor(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Language Translate',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // const Text(
                  //   'Translate your language into any\n language',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     color: Colors.white24,
                  //     fontWeight: FontWeight.bold,
                  //     fontStyle: FontStyle.italic,
                  //   ),
                  // ),

                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 22),
                          height: 30,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black26,
                          ),
                          child: Center(
                            child: DropdownButton(
                              borderRadius: BorderRadius.circular(20),
                              underline: const SizedBox(),
                              focusColor: Colors.black,
                              iconDisabledColor: Colors.grey,
                              iconEnabledColor: Colors.white,
                              hint: Text(
                                initialLanguage,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              dropdownColor: Colors.white38,
                              items: languages.map((String dropdownItem) {
                                return DropdownMenuItem<String>(
                                  value: dropdownItem,
                                  child: Text(dropdownItem),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  initialLanguage = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          child: ListTile(
                            title: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              maxLines: 7,
                              controller: controller,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter your language here',
                                hintStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                fillColor: Colors.black26,
                                filled: true,
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (controller.text.isNotEmpty) {
                                      _speak(controller.text,
                                          languageCodes[initialLanguage]!);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.speaker_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: controller.text.isEmpty
                                      ? () {}
                                      : () {
                                          Clipboard.setData(ClipboardData(
                                                  text: controller.text))
                                              .then((value) =>
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      margin:
                                                          EdgeInsets.all(20),
                                                      content: Text(
                                                          'Text copied successfully'),
                                                    ),
                                                  ));
                                        },
                                  icon: const Icon(
                                    Icons.copy,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 30,
                          width: 120,
                          margin: const EdgeInsets.only(right: 22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black26,
                          ),
                          child: Center(
                            child: DropdownButton(
                              borderRadius: BorderRadius.circular(20),
                              underline: const SizedBox(),
                              focusColor: Colors.white,
                              iconDisabledColor: Colors.grey,
                              iconEnabledColor: Colors.white,
                              hint: Text(
                                endLanguage,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              dropdownColor: Colors.white38,
                              items: languages.map((String dropdownItem) {
                                return DropdownMenuItem<String>(
                                  value: dropdownItem,
                                  child: Text(dropdownItem),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  endLanguage = value!;
                                });
                              },
                            ),
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
                                horizontal: 20, vertical: 20),
                            child: Text(
                              output.isNotEmpty
                                  ? output
                                  : 'Your language will be translated here',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (output.isNotEmpty) {
                                    _speak(output, languageCodes[endLanguage]!);
                                  }
                                },
                                icon: const Icon(
                                  Icons.speaker_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: output.isEmpty
                                    ? () {}
                                    : () {
                                        Clipboard.setData(
                                                ClipboardData(text: output))
                                            .then((value) =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    margin: EdgeInsets.all(20),
                                                    content: Text(
                                                        'Text copied successfully'),
                                                  ),
                                                ));
                                      },
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (endLanguage != 'To' && controller.text.isNotEmpty) {
                        String endLang = languageCodes[endLanguage]!;
                        translate(endLang, controller.text);
                      }
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.white12),
                    ),
                    child: const Text(
                      'Translate',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
