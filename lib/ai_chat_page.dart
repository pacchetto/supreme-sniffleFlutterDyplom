// ignore_for_file: deprecated_member_use, avoid_print, unused_element

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Модель повідомлення
class ChatMessage {
  final String text;
  final bool isAi;
  ChatMessage({required this.text, required this.isAi});
}

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Початкові повідомлення
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Привіт, Traveler. Я твій цифровий гід. Як ти почуваєшся сьогодні?",
      isAi: true,
    ),
  ];

  bool _isLoading = false;

  // Твій API ключ OpenAI (для тестування краще тримати порожнім і використовувати заглушку)
  final String openAiKey = dotenv.env['GROQ_API_KEY'] ?? "";

  // 1. Функція відправки повідомлення
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Додаємо повідомлення користувача в чат
    setState(() {
      _messages.add(ChatMessage(text: text, isAi: false));
      _isLoading = true; // Вмикаємо індикатор завантаження
    });

    _controller.clear();
    _scrollToBottom();

    // Отримуємо відповідь (Передаємо історію, метод тепер без параметрів!)
    String aiResponse = await _fetchOpenAiResponse();

    // Додаємо відповідь ШІ в чат
    setState(() {
      _messages.add(ChatMessage(text: aiResponse, isAi: true));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  // 2. Окремий незалежний метод для очищення чату (тепер він лежить правильно на рівні класу)
  void _clearChatHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151515),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: const Text(
            "Очистити чат?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Уся історія повідомлень з Cyber Guide буде видалена безповоротно.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Скасувати",
                style: TextStyle(color: Colors.white38),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _messages.clear();
                  _messages.add(
                    ChatMessage(
                      text:
                          "Привіт, Traveler. Я твій цифровий гід. Як ти почуваєшся сьогодні?",
                      isAi: true,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Очистити",
                style: TextStyle(
                  color: Color(0xFFFF007F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getMockResponse(String userText) {
    userText = userText.toLowerCase();
    if (userText.contains("тривог") ||
        userText.contains("стрес") ||
        userText.contains("погано")) {
      return "Розумію твій стан. ...";
    }
    return "Я тут, щоб підтримати тебе. ...";
  }

  // Реальний запит до Groq API
  Future<String> _fetchOpenAiResponse() async {
    try {
      // Конвертуємо історію твоїх повідомлень з екрана у формат для API
      List<Map<String, String>> apiMessages = [
        {
          "role": "system",
          "content": """
          Ти — емпатійний професійний психолог та ментор. Твої пріоритети в суворому порядку: 
          1. Активне слухання: валідуй емоції користувача, дай простір виговоритися без засудження та "токсичного позитиву".
          2. Організація життя: м'яко допомагай структурувати проблеми, розставляти пріоритети та складати реалістичні плани дій через навідні запитання.
          3. Суворе обмеження: пропонуй дихальні вправи чи медитації ЛИШЕ як найостанніший засіб або за прямим запитом користувача. 
          Стиль: тепло, лаконічно, по суті. Завжди завершуй відповідь одним коротким запитанням, щоб підтримувати діалог.
        """,
        },
      ];

      // Проходимося по кожному повідомленню в інтерфейсі і додаємо в історію запиту
      for (var msg in _messages) {
        apiMessages.add({
          "role": msg.isAi ? "assistant" : "user",
          "content": msg.text,
        });
      }

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiKey',
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": apiMessages,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        print("🚨 ПОМИЛКА GROQ: ${response.body}");
        return "Системи перевантажені. (Помилка API: ${response.statusCode})";
      }
    } catch (e) {
      print("🚨 КРИТИЧНА ПОМИЛКА: $e");
      return "Втрачено зв'язок з нейромережею. Перевір інтернет.";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            tooltip: "Очистити історію",
            onPressed:
                _clearChatHistory, // Тепер цей метод викликається без проблем
          ),
          const SizedBox(width: 8),
        ],
        title: Column(
          children: [
            const Text(
              "Cyber Guide",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF007F),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF007F).withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "Online",
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessage(msg.text, isAi: msg.isAi);
              },
            ),
          ),
          SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 90,
                left: 20,
                right: 20,
                top: 10,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Опиши свій стан...",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF007F).withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Color(0xFFFF007F),
                            ),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, {required bool isAi}) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isAi
              ? const Color(0xFF151515)
              : const Color(0xFFFF007F).withOpacity(0.15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAi ? 0 : 20),
            bottomRight: Radius.circular(isAi ? 20 : 0),
          ),
          border: Border.all(
            color: isAi
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFFFF007F).withOpacity(0.5),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: const Text(
          "Cyber Guide аналізує...",
          style: TextStyle(
            color: Color(0xFFFF007F),
            fontStyle: FontStyle.italic,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
