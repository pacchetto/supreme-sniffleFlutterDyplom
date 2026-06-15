// ignore_for_file: deprecated_member_use, avoid_print, unused_element

import 'dart:convert';
import 'dart:ui';
import 'package:aetheria_graph_app/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aetheria_graph_app/l10n/app_localizations.dart';

// Модель повідомлення
class ChatMessage {
  final String text;
  final bool isAi;
  ChatMessage({required this.text, required this.isAi});
}

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Початкові повідомлення
  final List<ChatMessage> _messages = [];

  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      _messages.add(ChatMessage(text: l10n.initialGreeting, isAi: true));
    }
  }

  // Твій API ключ OpenAI
  String get openAiKey {
    try {
      if (kIsWeb) {
        // On web, get API key from window object (injected by build process)
        try {
          return _getWebApiKey();
        } catch (e) {
          debugPrint("Error getting API key from window: $e");
          return "";
        }
      } else {
        // On mobile, get from dotenv
        return dotenv.env['GROQ_API_KEY'] ?? "";
      }
    } catch (e) {
      // For web version without .env file
      return "";
    }
  }

  // Допоміжна функція для отримання API ключа на Web
  String _getWebApiKey() {
    if (!kIsWeb) return "";
    try {
      // На Web використовуємо dart:js для доступу до window об'єкта
      // На мобільних платформах це не буде виконано
      return "";
    } catch (e) {
      debugPrint("Error accessing window object: $e");
      return "";
    }
  }

  // 1. Функція відправки повідомлення
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isAi: false));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    String aiResponse = await _fetchOpenAiResponse();

    setState(() {
      _messages.add(ChatMessage(text: aiResponse, isAi: true));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  // 2. Метод для очищення чату (тепер колір кнопки динамічний)
  void _clearChatHistory() {
    final theme = Theme.of(context);
    final primaryColor =
        theme.colorScheme.primary; // Отримуємо Neon Pink глобально
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151515),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: Text(
            l10n.clearChatQuestion,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            l10n.clearChatWarning,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.white38),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _messages.clear();
                  _messages.add(
                    ChatMessage(text: l10n.initialGreeting, isAi: true),
                  );
                });
                Navigator.pop(context);
              },
              child: Text(
                l10n.clear,
                style: TextStyle(
                  color: primaryColor, // ПІДКЛЮЧЕНО ДО ТЕМИ
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Реальний запит до Groq API
  Future<String> _fetchOpenAiResponse() async {
    try {
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    // СИНХРОНІЗАЦІЯ ДИЗАЙНУ: Слухаємо той самий тумблер з налаштувань
    final isDarkImmersion = ref.watch(darkImmersionProvider);

    // Визначаємо колір фону точно так само, як на сторінці налаштувань
    final Color backgroundColor = isDarkImmersion
        ? const Color(0xFF000000)
        : const Color(0xFF1A1A1E);
    return Scaffold(
      backgroundColor: backgroundColor, // Використовуємо захищений колір фону
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(width: 48),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            tooltip: l10n.clearHistory,
            onPressed: _clearChatHistory,
          ),
          const SizedBox(width: 8),
        ],
        title: Column(
          children: [
            Text(
              l10n.cyberGuide,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.online,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
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
                  return _buildTypingIndicator(primaryColor);
                }
                final msg = _messages[index];
                return _buildMessage(
                  msg.text,
                  isAi: msg.isAi,
                  primaryColor: primaryColor,
                );
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
                              hintText: l10n.describeYourState,
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
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.send, color: primaryColor),
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

  Widget _buildMessage(
    String text, {
    required bool isAi,
    required Color primaryColor,
  }) {
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
              : primaryColor.withOpacity(0.15), // ПІДКЛЮЧЕНО ДО ТЕМИ
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAi ? 0 : 20),
            bottomRight: Radius.circular(isAi ? 20 : 0),
          ),
          border: Border.all(
            color: isAi
                ? Colors.white.withOpacity(0.05)
                : primaryColor.withOpacity(0.5), // ПІДКЛЮЧЕНО ДО ТЕМИ
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

  Widget _buildTypingIndicator(Color primaryColor) {
    final l10n = AppLocalizations.of(context)!;
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
        child: Text(
          l10n.cyberGuideAnalyzing,
          style: TextStyle(
            color: primaryColor, // ПІДКЛЮЧЕНО ДО ТЕМИ
            fontStyle: FontStyle.italic,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
