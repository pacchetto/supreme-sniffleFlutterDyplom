import 'package:flutter/material.dart';
import 'auth_repository.dart';

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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      if (isLoginMode) {
        await _authRepo.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _authRepo.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Перевірте пошту для підтвердження (якщо увімкнено вертифікацію)",
              ),
            ),
          );
        }
      }
      // Після успішного входу Supabase сам оновить стрім стану, додаток перенаправить юзера
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Помилка: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _continueAsGuest() async {
    setState(() => isLoading = true);
    try {
      await _authRepo.signInAnonymously();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Не вдалося увійти як гість: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = const Color(
      0xFF4AF2A1,
    ); // Твій зелений Cyber колір

    return Scaffold(
      backgroundColor: const Color(0xFF09110F),
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
                  // ЛОГОТИП / ТИТУЛ
                  Text(
                    "CYBER MONK",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeColor,
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
                    decoration: _buildInputDecoration(
                      "EMAIL",
                      Icons.alternate_email_rounded,
                      themeColor,
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
                    decoration: _buildInputDecoration(
                      "PASSWORD",
                      Icons.lock_outline_rounded,
                      themeColor,
                    ),
                    validator: (v) => v == null || v.length < 6
                        ? "Пароль має бути від 6 символів"
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // ГОЛОВНА КНОПКА (ВХІД / РЕЄСТРАЦІЯ)
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
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
                    child: Text(
                      isLoginMode
                          ? "NEW MONK? REGISTER HERE"
                          : "ALREADY HAVE AN ACCOUNT? LOGIN",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
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
