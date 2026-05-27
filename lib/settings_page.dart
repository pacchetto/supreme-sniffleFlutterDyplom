import 'package:aetheria_graph_app/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  int _versionTapCount = 0; // Лічильник кліків для великодки

  // Функція виходу з акаунта
  Future<void> _handleLogOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();

      // Після виходу повертаємо користувача на екран логіну/авторизації
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error logging out: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Зчитуємо наші улюблені налаштування для синхронізації дизайну
    final isDarkImmersion = ref.watch(darkImmersionProvider);
    final isBioSync = ref.watch(bioSyncProvider);
    final isDevMode = ref.watch(devModeProvider); // Слухаємо режим розробника

    final Color backgroundColor = isDarkImmersion
        ? const Color(0xFF000000)
        : const Color(0xFF1A1A1E);

    final Color accentColor = isBioSync
        ? const Color(0xFFFF007F)
        : const Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Біла стрілочка назад
        titleSpacing: 24,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AETHERIAGRAPH WELLNESS",
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              // БЛОК PREFERENCES
              _buildSectionTitle("PREFERENCES"),
              _buildSettingsGroup([
                _buildSwitchTile(
                  "Sounds",
                  Icons.volume_up_rounded,
                  true,
                  (val) {},
                ),
                _buildSwitchTile(
                  "Haptics",
                  Icons.vibration_rounded,
                  false,
                  (val) {},
                ),
                _buildSwitchTile(
                  "Zen Mode",
                  Icons.airline_seat_recline_extra_rounded,
                  true,
                  (val) {},
                ),
              ]),

              const SizedBox(height: 24),

              // БЛОК ACCOUNT
              _buildSectionTitle("ACCOUNT"),
              _buildSettingsGroup([
                _buildNavigationTile(
                  "Profile",
                  "Alex Chen",
                  Icons.person_outline_rounded,
                  () {},
                ),
                _buildNavigationTile(
                  "Subscription",
                  "PRO",
                  Icons.credit_card_rounded,
                  () {},
                  isPro: true,
                ),
              ]),

              const SizedBox(height: 24),

              // БЛОК SYSTEM
              _buildSectionTitle("SYSTEM"),
              _buildSettingsGroup([
                _buildStaticTile(
                  "Dark Mode",
                  "ALWAYS ON",
                  Icons.dark_mode_outlined,
                ),
                _buildNavigationTile(
                  "Notifications",
                  "",
                  Icons.notifications_none_rounded,
                  () {},
                ),
              ]),

              const SizedBox(height: 40),

              // КНОПКА LOG OUT
              GestureDetector(
                onTap: () => _handleLogOut(context),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFE53935).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFE53935),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Log Out",
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ВЕРСІЯ ДОДАТКУ (АКТИВАТОР МІНІ-ГРИ В ПРОФІЛІ)
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (isDevMode) {
                      return; // Якщо вже активовано, нічого не робимо
                    }

                    setState(() {
                      _versionTapCount++;
                      if (_versionTapCount >= 7) {
                        // Змінюємо глобальний стан через Riverpod провайдер з profile_page.dart
                        ref.read(devModeProvider.notifier).enable();

                        // Показуємо гарне сповіщення користувачу
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "⚡ DEV MODE ACTIVE // CYBER RUNNER UNLOCKED IN PROFILE ⚡",
                            ),
                            backgroundColor: Color(0xFFFF007F),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0,
                    ),
                    child: Text(
                      isDevMode
                          ? "⚡ DEV MODE: ACTIVE // SYNC ZONE ENABLED ⚡"
                          : "Lumina v1.0.4",
                      style: TextStyle(
                        color: isDevMode
                            ? const Color(0xFFFF007F)
                            : Colors.white24,
                        fontSize: 12,
                        fontWeight: isDevMode
                            ? FontWeight.bold
                            : FontWeight.normal,
                        letterSpacing: isDevMode ? 0.5 : 0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- ХЕЛПЕРИ ДЛЯ ВІДЖЕТІВ ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white54, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFFF007F),
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isPro = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white54, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPro ? 8 : 0,
                vertical: 4,
              ),
              decoration: isPro
                  ? BoxDecoration(
                      color: const Color(0xFFFF007F).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Text(
                subtitle,
                style: TextStyle(
                  color: isPro ? const Color(0xFFFF007F) : Colors.white38,
                  fontSize: 14,
                  fontWeight: isPro ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white24,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildStaticTile(String title, String trailingText, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white54, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: Text(
        trailingText,
        style: const TextStyle(
          color: Colors.white24,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
