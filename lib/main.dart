import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const TextToSpeechApp());
}

class TextToSpeechApp extends StatelessWidget {
  const TextToSpeechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text to Speech (Indian Male)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TextToSpeechScreen(),
    );
  }
}

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textController = TextEditingController(text: "एक सौ बीस रुपये पचास पैसे प्राप्त हुए");
  final TextEditingController rupayController = TextEditingController();
  final TextEditingController peesyController = TextEditingController();
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  String? currentVoice;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    // Get all available voices
    List<dynamic> voices = await flutterTts.getVoices;

    for (var element in voices.where((e) => e['locale'].toString().toLowerCase().contains('in'))) {
      print("Voice: ${element['name']}, Locale: ${element['locale']}");
    }

    // Find an Indian English male voice (if available)
    var indianMaleVoice = voices.firstWhere(
      (voice) =>
          voice['locale'].toLowerCase().contains('in') && // Indian locale
          voice['name'].toLowerCase().contains('male'), // Male voice
      orElse: () => null,
    );

    if (indianMaleVoice != null) {
      await flutterTts.setVoice(indianMaleVoice);
      setState(() => currentVoice = indianMaleVoice['name']);
    } else {
      // Fallback to standard Indian English
      // await flutterTts.setLanguage("en-IN"); // Indian English
      await flutterTts.setVoice({"name": "male", "locale": "en-IN"});
      setState(() => currentVoice = "en-IN (Default)");
    }

    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(rate);
  }

  Future<void> _speak() async {
    // if (textController.text.isNotEmpty) {
    //   await flutterTts.speak(textController.text);
    // }
    await flutterTts.speak(convertToHindiRupees(
      int.parse(rupayController.text),
      int.parse(peesyController.text),
    ));
  }

  Future<void> _stop() async {
    await flutterTts.stop();
  }

  @override
  void dispose() {
    flutterTts.stop();
    textController.dispose();
    super.dispose();
  }

  String convertToHindiNumber(int number) {
    if (number == 0) return 'शून्य';

    final units = ['', 'एक', 'दो', 'तीन', 'चार', 'पाँच', 'छह', 'सात', 'आठ', 'नौ', 'दस', 'ग्यारह', 'बारह', 'तेरह', 'चौदह', 'पंद्रह', 'सोलह', 'सत्रह', 'अठारह', 'उन्नीस'];

    final tens = ['', 'दस', 'बीस', 'तीस', 'चालीस', 'पचास', 'साठ', 'सत्तर', 'अस्सी', 'नब्बे'];

    final hundreds = ['', 'एक सौ', 'दो सौ', 'तीन सौ', 'चार सौ', 'पाँच सौ', 'छह सौ', 'सात सौ', 'आठ सौ', 'नौ सौ'];

    if (number < 20) {
      return units[number];
    }

    if (number < 100) {
      final ten = number ~/ 10;
      final unit = number % 10;
      return '${tens[ten]}${unit != 0 ? ' ${units[unit]}' : ''}';
    }

    if (number < 1000) {
      final hundred = number ~/ 100;
      final remainder = number % 100;
      return '${hundreds[hundred]}${remainder != 0 ? ' ${convertToHindiNumber(remainder)}' : ''}';
    }

    if (number < 100000) {
      final thousand = number ~/ 1000;
      final remainder = number % 1000;
      return '${convertToHindiNumber(thousand)} हज़ार${remainder != 0 ? ' ${convertToHindiNumber(remainder)}' : ''}';
    }

    if (number < 10000000) {
      final lakh = number ~/ 100000;
      final remainder = number % 100000;
      return '${convertToHindiNumber(lakh)} लाख${remainder != 0 ? ' ${convertToHindiNumber(remainder)}' : ''}';
    }

    final crore = number ~/ 10000000;
    final remainder = number % 10000000;
    return '${convertToHindiNumber(crore)} करोड़${remainder != 0 ? ' ${convertToHindiNumber(remainder)}' : ''}';
  }

  String convertToHindiRupees(int rupees, int paise) {
    String rupeeText = convertToHindiNumber(rupees);
    String paiseText = convertToHindiNumber(paise);
    log('Translated: $rupeeText रुपये $paiseText पैसे');
    return '$rupeeText रुपये $paiseText पैसे';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Male Text to Speech'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Voice: ${currentVoice ?? "Not set"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: rupayController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter number',
                      hintText: 'Type something...',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: peesyController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter number',
                      hintText: 'Type something...',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: textController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter text to speak',
                hintText: 'Type something...',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _speak,
                  child: const Text('Speak'),
                ),
                ElevatedButton(
                  onPressed: _stop,
                  child: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Text('Volume: ${volume.toStringAsFixed(1)}'),
                Slider(
                  value: volume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (value) async {
                    setState(() => volume = value);
                    await flutterTts.setVolume(value);
                  },
                ),
                Text('Pitch: ${pitch.toStringAsFixed(1)}'),
                Slider(
                  value: pitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (value) async {
                    setState(() => pitch = value);
                    await flutterTts.setPitch(value);
                  },
                ),
                Text('Speech Rate: ${rate.toStringAsFixed(1)}'),
                Slider(
                  value: rate,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (value) async {
                    setState(() => rate = value);
                    await flutterTts.setSpeechRate(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
