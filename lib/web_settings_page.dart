// lib/web_settings_page.dart
// WEB SETTINGS PAGE: Language, Theme, Easter Egg Game

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aetheria_graph_app/l10n/app_localizations.dart';
import 'package:aetheria_graph_app/locale_provider.dart';
import 'package:aetheria_graph_app/profile_page.dart';
import 'cyber_runner_game.dart';

class WebSettingsPage extends ConsumerStatefulWidget {
  const WebSettingsPage({super.key});

  @override
  ConsumerState<WebSettingsPage> createState() => _WebSettingsPageState();
}

class _WebSettingsPageState extends ConsumerState<WebSettingsPage> {
  int _versionTapCount = 0;

  void _onVersionTap() {
    setState(() {
      _versionTapCount++;
    });

    if (_versionTapCount >= 7) {
      _versionTapCount = 0;
      _launchEasterEggGame();
    }
  }

  void _launchEasterEggGame() {
    final isDarkImmersion = ref.read(darkImmersionProvider);
    final Color gameBackground = isDarkImmersion
        ? const Color(0xFF000000)
        : const Color(0xFF0D0D0D);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: gameBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          body: CyberRunnerGame(
            onGameFinished: (score) {
              // Just close the game, no score saving in web version
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final isDarkImmersion = ref.watch(darkImmersionProvider);

    return Scaffold(
      backgroundColor: isDarkImmersion
          ? const Color(0xFF000000)
          : const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LANGUAGE SECTION
              _buildSectionTitle(l10n.language),
              const SizedBox(height: 12),
              _buildLanguageSelector(currentLocale),

              const SizedBox(height: 32),

              // THEME SECTION
              _buildSectionTitle(l10n.immersionParams),
              const SizedBox(height: 12),
              _buildThemeToggle(isDarkImmersion, l10n),

              const SizedBox(height: 48),

              // VERSION INFO (Easter Egg Trigger)
              Center(
                child: GestureDetector(
                  onTap: _onVersionTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Aetheria Graph',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Web Demo v1.0.0',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                        if (_versionTapCount > 0 && _versionTapCount < 7)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${7 - _versionTapCount} more taps...',
                              style: TextStyle(
                                color: const Color(0xFFFF007F).withOpacity(0.5),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // INFO TEXT
              Center(
                child: Text(
                  'Test version without database',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildLanguageSelector(Locale currentLocale) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildLanguageOption(
            'English',
            'EN',
            const Locale('en'),
            currentLocale,
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.05)),
          _buildLanguageOption(
            'Українська',
            'UK',
            const Locale('uk'),
            currentLocale,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    String name,
    String code,
    Locale locale,
    Locale currentLocale,
  ) {
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () {
          ref.read(localeProvider.notifier).setLocale(locale);
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF007F).withOpacity(0.1)
                : Colors.white.withOpacity(0.03),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF007F)
                  : Colors.white.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              code,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF007F) : Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFFFF007F), size: 24)
            : null,
      ),
    );
  }

  Widget _buildThemeToggle(bool isDarkImmersion, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDarkImmersion
                  ? const Color(0xFFFF007F).withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDarkImmersion ? Icons.dark_mode : Icons.light_mode,
              color: isDarkImmersion ? const Color(0xFFFF007F) : Colors.white60,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.darkImmersion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.darkImmersionDesc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: isDarkImmersion,
            onChanged: (value) {
              ref.read(darkImmersionProvider.notifier).toggle(value);
            },
          ),
        ],
      ),
    );
  }
}
