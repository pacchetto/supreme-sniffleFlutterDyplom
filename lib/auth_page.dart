import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository.dart';
import 'main_screen.dart';
import 'package:aetheria_graph_app/l10n/app_localizations.dart';

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
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Слухач глибоких посилань (Deep Links) від Supabase
  void _setupAuthListener() {
    _authSubscription = _authRepo.authStateChanges.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // Якщо подія — відновлення пароля, показуємо вікно зміни пароля
        _showNewPasswordDialog();
      }
    });
  }

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
    final l10n = AppLocalizations.of(context)!;
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
            child: Text(
              l10n.ok,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === ВІКНО ВВЕДЕННЯ НОВОГО ПАРОЛЯ ===
  void _showNewPasswordDialog() {
    final l10n = AppLocalizations.of(context)!;
    final newPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    final pinkColor = Theme.of(context).colorScheme.primary;
    final purpleColor = Theme.of(context).colorScheme.secondary;

    showDialog(
      context: context,
      barrierDismissible: false, // Користувач мусить змінити пароль
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: purpleColor.withOpacity(0.5), width: 1.5),
            ),
            title: Row(
              children: [
                Icon(Icons.vpn_key_rounded, color: purpleColor, size: 22),
                const SizedBox(width: 12),
                Text(
                  l10n.newAccessCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Form(
              key: dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.newPasswordPrompt,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: purpleColor,
                    decoration: _buildInputDecoration(
                      l10n.newPassword,
                      Icons.lock_reset_rounded,
                      purpleColor,
                    ),
                    validator: (v) =>
                        v == null || v.length < 6 ? l10n.minSixChars : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!dialogFormKey.currentState!.validate()) return;

                        setDialogState(() => isLoading = true);
                        try {
                          await _authRepo.updatePassword(
                            newPassword: newPasswordController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.pop(context); // Закриваємо цей діалог
                          }

                          _showCyberDialog(
                            title: l10n.success,
                            message: l10n.passwordUpdated,
                            icon: Icons.check_circle_outline_rounded,
                            accentColor: purpleColor,
                          );
                        } catch (e) {
                          _showCyberDialog(
                            title: l10n.syncError,
                            message: e.toString(),
                            icon: Icons.error_outline,
                            accentColor: pinkColor,
                          );
                        } finally {
                          setDialogState(() => isLoading = false);
                        }
                      },
                style: TextButton.styleFrom(foregroundColor: purpleColor),
                child: isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.purple,
                        ),
                      )
                    : Text(
                        l10n.savePassword,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Логіка натискання на кнопку "Забули пароль"
  void _handleForgotPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showCyberDialog(
        title: l10n.dataError,
        message: l10n.forgotPasswordPrompt,
        icon: Icons.warning_amber_rounded,
        accentColor: Theme.of(context).colorScheme.primary,
      );
      return;
    }

    setState(() => isLoading = true);
    final Color pinkColor = Theme.of(context).colorScheme.primary;
    final Color purpleColor = Theme.of(context).colorScheme.secondary;

    try {
      await _authRepo.resetPassword(email: email);
      _showCyberDialog(
        title: l10n.recovery,
        message: l10n.resetLinkSent,
        icon: Icons.mark_email_read_outlined,
        accentColor: purpleColor,
      );
    } catch (e) {
      String friendlyMessage = e.toString();

      if (friendlyMessage.contains("rate_limit_exceeded") ||
          friendlyMessage.contains("429")) {
        friendlyMessage = l10n.rateLimitError;
      }

      _showCyberDialog(
        title: l10n.cyberProtection,
        message: friendlyMessage,
        icon: Icons.gpp_bad_outlined,
        accentColor: pinkColor,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => isLoading = true);
    final Color pinkColor = Theme.of(context).colorScheme.primary;
    final Color purpleColor = Theme.of(context).colorScheme.secondary;

    try {
      if (isLoginMode) {
        await _authRepo.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _navigateToHome();
      } else {
        await _authRepo.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        _showCyberDialog(
          title: l10n.verification,
          message: l10n.checkEmailActivation,
          icon: Icons.alternate_email_rounded,
          accentColor: purpleColor,
        );
      }
    } catch (e) {
      String friendlyMessage = e.toString();
      if (friendlyMessage.contains("invalid_credentials") ||
          friendlyMessage.contains("Invalid login credentials")) {
        friendlyMessage = l10n.invalidCredentials;
      } else if (friendlyMessage.contains("network")) {
        friendlyMessage = l10n.networkError;
      } else if (friendlyMessage.contains("User already registered")) {
        friendlyMessage = l10n.userAlreadyRegistered;
      }

      _showCyberDialog(
        title: l10n.accessError,
        message: friendlyMessage,
        icon: Icons.gpp_bad_outlined,
        accentColor: pinkColor,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _continueAsGuest() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => isLoading = true);
    try {
      await _authRepo.signInAnonymously();
      _navigateToHome();
    } catch (e) {
      // ignore: use_build_context_synchronously
      final Color pinkColor = Theme.of(context).colorScheme.primary;
      _showCyberDialog(
        title: l10n.guestError,
        message: l10n.anonymousSessionError(e.toString()),
        icon: Icons.gpp_bad_outlined,
        accentColor: pinkColor,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.appTitle,
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
                    isLoginMode ? l10n.welcomeBack : l10n.startImmersion,
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
                      l10n.email,
                      Icons.alternate_email_rounded,
                      pinkColor,
                    ),
                    validator: (v) => v == null || !v.contains('@')
                        ? l10n.invalidEmail
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
                      l10n.password,
                      Icons.lock_outline_rounded,
                      pinkColor,
                    ),
                    validator: (v) => v == null || v.length < 6
                        ? l10n.passwordMinLength
                        : null,
                  ),

                  // === КНОПКА СКИДАННЯ ПАРОЛЯ ===
                  if (isLoginMode) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : _handleForgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white30,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.forgotPassword,
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                            isLoginMode ? l10n.enter : l10n.createAccount,
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
                          ? l10n.newMonkRegister
                          : l10n.alreadyHaveAccount,
                      style: const TextStyle(fontSize: 13, letterSpacing: 1),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            l10n.or,
                            style: const TextStyle(
                              color: Colors.white24,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.white12)),
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
                    child: Text(
                      l10n.continueAsGuest,
                      style: const TextStyle(
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
