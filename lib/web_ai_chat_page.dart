// lib/web_ai_chat_page.dart
// WEB AI CHAT PAGE: Optimized for desktop/large screens

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:aetheria_graph_app/l10n/app_localizations.dart';
import 'package:aetheria_graph_app/profile_page.dart';

// Cross-platform API key accessor. On web it reads `window.groqApiKey`
// (injected in web/index.html); on other platforms it returns "".
// This avoids importing `dart:js_interop` directly, which is unavailable
// on Android/iOS and breaks the release build.
import 'package:aetheria_graph_app/utils/web_api_key.dart';

class ChatMessage {
  final String text;
  final bool isAi;
  ChatMessage({required this.text, required this.isAi});
}

class WebAiChatPage extends ConsumerStatefulWidget {
  const WebAiChatPage({super.key});

  @override
  ConsumerState<WebAiChatPage> createState() => _WebAiChatPageState();
}

class _WebAiChatPageState extends ConsumerState<WebAiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  String get openAiKey {
    if (!kIsWeb) {
      return ""; // Not available outside the web build
    }
    // Reads window.groqApiKey on web; returns "" elsewhere.
    return getGroqApiKey();
  }

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

  void _clearChatHistory() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
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
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> _fetchOpenAiResponse() async {
    if (openAiKey.isEmpty) {
      return "⚠️ AI-чат наразі недоступний у вебверсії. Спробуйте мобільний застосунок.";
    }

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
      } else if (response.statusCode == 401) {
        return "❌ Invalid API Key. Check the key in settings (🔑 icon).";
      } else {
        return "Системи перевантажені. (Помилка API: ${response.statusCode})";
      }
    } catch (e) {
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
    final isDarkImmersion = ref.watch(darkImmersionProvider);

    final Color backgroundColor = isDarkImmersion
        ? const Color(0xFF000000)
        : const Color(0xFF1A1A1E);

    return Scaffold(
      backgroundColor: backgroundColor,
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
          const SizedBox(width: 16),
        ],
        title: Column(
          children: [
            Text(
              l10n.cyberGuide,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
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
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
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
                  // Extra bottom padding so the floating bottom navbar
                  // (~90px tall) does NOT overlap the text input field.
                  padding: const EdgeInsets.only(
                    left: 32,
                    right: 32,
                    top: 24,
                    bottom: 100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.describeYourState,
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  border: InputBorder.none,
                                ),
                                minLines: 1,
                                maxLines: 3,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                icon: Icon(
                                  Icons.send,
                                  color: primaryColor,
                                  size: 20,
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
        ),
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
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: isAi
              ? const Color(0xFF151515)
              : primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isAi ? 0 : 24),
            bottomRight: Radius.circular(isAi ? 24 : 0),
          ),
          border: Border.all(
            color: isAi
                ? Colors.white.withOpacity(0.05)
                : primaryColor.withOpacity(0.5),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
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
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          l10n.cyberGuideAnalyzing,
          style: TextStyle(
            color: primaryColor,
            fontStyle: FontStyle.italic,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
