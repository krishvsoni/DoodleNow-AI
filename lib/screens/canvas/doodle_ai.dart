import 'dart:async';

import 'package:doodle_for_gdsc/service/gpt_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DoodleAI extends StatefulWidget {
  final Function(PictureInfo?) onGptCalled;
  final Function(bool) loadingCallback;

  const DoodleAI(
      {super.key, required this.onGptCalled, required this.loadingCallback});

  @override
  State<DoodleAI> createState() => _DoodleAIState();
}

class _DoodleAIState extends State<DoodleAI> {
  final SpeechToText _speechToText = SpeechToText();
  final GptService _gptService = GptService.instance;

  bool _speechEnabled = false;
  String _lastWords = '';

  Timer? timer;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(onStatus: (value) {
      // statusListener(value);
    });
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);

    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;

    print('_onSpeechResult $_lastWords');
    print('_onSpeechResult result  ${result.recognizedWords}');

    timer?.cancel();

    timer = Timer(const Duration(milliseconds: 1000), () async {
      // final object = _lastWords.split(' ').last;

      print(_lastWords);

      widget.loadingCallback(true);

      widget.loadingCallback(false);

      // widget.onGptCalled(pictureInfo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.withOpacity(0.4),
      width: 200,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text.rich(
            TextSpan(
              text: 'Draw ',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: 'your ',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                        text: 'Imagination ',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: 'with AI ',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ])
                  ],
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap:
                _speechToText.isNotListening ? _startListening : _stopListening,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _speechToText.isNotListening ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                  _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            ),
          ),
        ],
      ),
    );
  }
}
