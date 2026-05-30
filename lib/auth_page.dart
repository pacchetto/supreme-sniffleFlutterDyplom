import 'package:flutter/material.dart';
import 'auth_repository.dart';
import 'main_screen.dart'; // Додали імпорт головного екрана для гарантованого переходу

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthRepository _authRepo = AuthRepository();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoginMode = true;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Функція гарантованого переходу на головну сторінку
  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  // === КАСТОМНЕ НЕОНОВЕ ДІАЛОГОВЕ ВІКНО ===
  void _showCyberDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color accentColor,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accentColor.withOpacity(0.4), width: 1.5),
        ),
        title: Row(
          children: [
            Icon(icon, color: accentColor, size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: accentColor),
            child: const Text(
              "ОК",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final Color pinkColor = Theme.of(context).colorScheme.primary;
    final Color purpleColor = Theme.of(context).colorScheme.secondary;

    try {
      if (isLoginMode) {
        await _authRepo.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Гарантовано перенаправляємо на головну сторінку після успішного входу
        _navigateToHome();
      } else {
        await _authRepo.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Вікно успішної реєстрації у фіолетовому неоні
        _showCyberDialog(
          title: "ВЕРИФІКАЦІЯ",
          message:
              "Запит надіслано успішно. Будь ласка, перевірте вашу електронну пошту для активації акаунта перед тим, як увійти.",
          icon: Icons.alternate_email_rounded,
          accentColor: purpleColor,
        );
      }
    } catch (e) {
      String friendlyMessage = e.toString();
      if (friendlyMessage.contains("invalid_credentials") ||
          friendlyMessage.contains("Invalid login credentials")) {
        friendlyMessage =
            "Невірний Email або пароль. Перевірте правильність введених даних.";
      } else if (friendlyMessage.contains("network")) {
        friendlyMessage = "Помилка мережі. Перевірте з'єднання з інтернетом.";
      } else if (friendlyMessage.contains("User already registered")) {
        friendlyMessage = "Цей користувач уже зареєстрований у системі.";
      }

      _showCyberDialog(
        title: "ПОМИЛКА ДОСТУПУ",
        message: friendlyMessage,
        icon: Icons.gpp_bad_outlined,
        accentColor: pinkColor,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _continueAsGuest() async {
    setState(() => isLoading = true);
    try {
      await _authRepo.signInAnonymously();
      // Гарантовано перенаправляємо на головну сторінку для гостей
      _navigateToHome();
    } catch (e) {
      // ignore: use_build_context_synchronously
      final Color pinkColor = Theme.of(context).colorScheme.primary;
      _showCyberDialog(
        title: "ПОМИЛКА ГУЕСТА",
        message: "Не вдалося ініціалізувати анонімний сеанс: ${e.toString()}",
        icon: Icons.gpp_bad_outlined,
        accentColor: pinkColor,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color pinkColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "CYBER MONK",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: pinkColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 6.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLoginMode
                        ? "WELCOME BACK, ASCETIC"
                        : "START YOUR IMMERSION",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ПОЛЕ EMAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: pinkColor,
                    decoration: _buildInputDecoration(
                      "EMAIL",
                      Icons.alternate_email_rounded,
                      pinkColor,
                    ),
                    validator: (v) => v == null || !v.contains('@')
                        ? "Некоректний Email"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // ПОЛЕ ПАРОЛЯ
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: pinkColor,
                    decoration: _buildInputDecoration(
                      "PASSWORD",
                      Icons.lock_outline_rounded,
                      pinkColor,
                    ),
                    validator: (v) => v == null || v.length < 6
                        ? "Пароль має бути від 6 символів"
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // ГОЛОВНА КНОПКА (ENTER)
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkColor,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black87,
                            ),
                          )
                        : Text(
                            isLoginMode ? "ENTER" : "CREATE ACCOUNT",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // ПЕРЕМИКАЧ РЕЖИМІВ
                  TextButton(
                    onPressed: () => setState(() => isLoginMode = !isLoginMode),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                    ),
                    child: Text(
                      isLoginMode
                          ? "NEW MONK? REGISTER HERE"
                          : "ALREADY HAVE AN ACCOUNT? LOGIN",
                      style: const TextStyle(fontSize: 13, letterSpacing: 1),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white12)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white12)),
                      ],
                    ),
                  ),

                  // КНОПКА ВХОДУ ЯК ГІСТЬ
                  OutlinedButton(
                    onPressed: isLoading ? null : _continueAsGuest,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "CONTINUE AS GUEST",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    Color accentColor,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.3),
        fontSize: 12,
        letterSpacing: 1.5,
      ),
      prefixIcon: Icon(icon, color: Colors.white30, size: 20),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: accentColor),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
