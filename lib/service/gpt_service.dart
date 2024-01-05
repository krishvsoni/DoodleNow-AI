import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GptService {
  late OpenAI _openAI;
  static GptService? _instance;

  GptService._internal() {
    _openAI = OpenAI.instance.build(
      token: dotenv.env["OPENAI_KEY"],
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    handleInitialMessage('You are a svg coding assistant');
  }

  static GptService getInstance() {
    _instance ??= GptService._internal();
    return _instance!;
  }

  Future<void> handleInitialMessage(String prompt) async {
    final request = ChatCompleteText(
      model: GptTurboChatModel(),
      messages: [Messages(role: Role.assistant, content: prompt)],
      maxToken: 200,
    );

    final response = await _openAI.onChatCompletion(request: request);
    print(response!.choices.map((e) => e.toJson()));
  }
 
 Future<ChatCTResponse?> userMessage(String prompt) async {
    final request = ChatCompleteText(
      model: GptTurboChatModel(),
      messages: [Messages(role: Role.assistant, content: prompt)],
      maxToken: 200,
    );

    final response = await _openAI.onChatCompletion(request: request);
    print(response!.choices.map((e) => e.toJson()));
    return response;
  }

 static GptService get instance {
  _instance ??= GptService._internal();
  return _instance!;
}

}
