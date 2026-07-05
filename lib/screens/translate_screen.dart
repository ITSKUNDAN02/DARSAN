import 'package:flutter/material.dart';
import '../models/language_model.dart';
import '../services/translation_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _isSpeaking = false;
  final TextEditingController _sourceController = TextEditingController();
  String _translation = '';
  LanguageModel fromLanguage = languages.first;
  LanguageModel toLanguage = languages[1];
  final TranslationService _translationService = TranslationService();
  String getTtsLanguage(String code) {
    switch (code) {
      case "en":
        return "en-US";

      case "ne":
        return "ne-NP";

      case "hi":
        return "hi-IN";

      case "ja":
        return "ja-JP";

      case "ko":
        return "ko-KR";

      case "zh":
        return "zh-CN";

      case "fr":
        return "fr-FR";

      case "de":
        return "de-DE";

      case "es":
        return "es-ES";

      case "it":
        return "it-IT";

      case "ru":
        return "ru-RU";

      case "ar":
        return "ar-SA";

      default:
        return "en-US";
    }
  }

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _translate() async {
    final input = _sourceController.text.trim();

    if (input.isEmpty) return;

    setState(() {
      _translation = "Translating...";
    });

    final translated = await _translationService.translate(
      text: input,
      from: fromLanguage.code,
      to: toLanguage.code,
    );

    setState(() {
      _translation = translated;
    });
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();

      if (available) {
        setState(() {
          _isListening = true;
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              _sourceController.text = result.recognizedWords;
            });

            if (result.finalResult) {
              _translate();
            }
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
      });

      _speech.stop();
    }
  }

  Future<void> _speak() async {
    if (_translation.trim().isEmpty) return;

    if (_isSpeaking) {
      await _tts.stop();

      setState(() {
        _isSpeaking = false;
      });
      return;
    }

    setState(() {
      _isSpeaking = true;
    });

    await _tts.awaitSpeakCompletion(true);

    await _tts.setLanguage(getTtsLanguage(toLanguage.code));
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    await _tts.speak(_translation);

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });

    _tts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
  }

  Future<void> _initTts() async {
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    await _tts.awaitSpeakCompletion(true);

    _tts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
        });
      }
    });

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });

    _tts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });

    _tts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("NEW TRANSLATE PAGE"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<LanguageModel>(
                    initialValue: fromLanguage,
                    decoration: const InputDecoration(
                      labelText: "From",
                      border: OutlineInputBorder(),
                    ),
                    items: languages.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Text(language.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          fromLanguage = value;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 30),
                  onPressed: () {
                    setState(() {
                      final temp = fromLanguage;
                      fromLanguage = toLanguage;
                      toLanguage = temp;
                    });
                  },
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: DropdownButtonFormField<LanguageModel>(
                    initialValue: toLanguage,
                    decoration: const InputDecoration(
                      labelText: "To",
                      border: OutlineInputBorder(),
                    ),
                    items: languages.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Text(language.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          toLanguage = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _sourceController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Text",
                border: const OutlineInputBorder(),

                suffixIcon: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.blue,
                  ),
                  onPressed: _listen,
                ),
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _translate,
              child: const Text('Translate'),
            ),
            const SizedBox(height: 24),
            if (_translation.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Result',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SelectableText(
                          _translation,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      Column(
                        children: [
                          IconButton(
                            tooltip: _isSpeaking ? "Stop" : "Speak",
                            onPressed: _speak,
                            icon: Icon(
                              _isSpeaking ? Icons.stop_circle : Icons.volume_up,
                              color: Colors.blue,
                            ),
                          ),

                          IconButton(
                            tooltip: "Copy",
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _translation),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Copied")),
                              );
                            },
                            icon: const Icon(Icons.copy, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
