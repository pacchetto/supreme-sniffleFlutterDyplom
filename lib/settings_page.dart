// lib/settings_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Обов'язково для ImageFilter (розмиття скла)
import 'auth_repository.dart';
import 'auth_page.dart';

// ==========================================
// 1. ШАР ДАНИХ ТА БІЗНЕС-ЛОГІКИ (RIVERPOD)
// ==========================================

class SettingsState {
  final String userName;
  final String? avatarPath;
  final bool isNotificationsEnabled;
  final bool isSoundsEnabled;
  final bool isDarkImmersion;
  final bool isBioSync;
  final bool isDevMode;
  final bool hasUnsavedChanges;

  SettingsState({
    required this.userName,
    this.avatarPath,
    required this.isNotificationsEnabled,
    required this.isSoundsEnabled,
    required this.isDarkImmersion,
    required this.isBioSync,
    required this.isDevMode,
    this.hasUnsavedChanges = false,
  });

  SettingsState copyWith({
    String? userName,
    String? avatarPath,
    bool? isNotificationsEnabled,
    bool? isSoundsEnabled,
    bool? isDarkImmersion,
    bool? isBioSync,
    bool? isDevMode,
    bool? hasUnsavedChanges,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      avatarPath: avatarPath ?? this.avatarPath,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      isSoundsEnabled: isSoundsEnabled ?? this.isSoundsEnabled,
      isDarkImmersion: isDarkImmersion ?? this.isDarkImmersion,
      isBioSync: isBioSync ?? this.isBioSync,
      isDevMode: isDevMode ?? this.isDevMode,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
    : super(
        SettingsState(
          userName: "Traveler",
          isNotificationsEnabled: true,
          isSoundsEnabled: true,
          isDarkImmersion: false,
          isBioSync: false,
          isDevMode: false,
        ),
      ) {
    _loadSettingsFromStorage();
  }

  Future<void> _loadSettingsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      userName: prefs.getString('user_name') ?? "Traveler",
      avatarPath: prefs.getString('avatar_path'),
      isNotificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      isSoundsEnabled: prefs.getBool('sounds_enabled') ?? true,
      isDarkImmersion: prefs.getBool('dark_immersion') ?? false,
      isBioSync: prefs.getBool('bio_sync') ?? false,
      isDevMode: prefs.getBool('dev_mode') ?? false,
      hasUnsavedChanges: false,
    );
  }

  void setTempAvatar(String? path) {
    state = state.copyWith(avatarPath: path, hasUnsavedChanges: true);
  }

  bool setTempUserName(String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed.length > 30) return false;
    state = state.copyWith(userName: trimmed, hasUnsavedChanges: true);
    return true;
  }

  Future<void> saveProfileChanges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', state.userName);
    if (state.avatarPath != null) {
      await prefs.setString('avatar_path', state.avatarPath!);
    } else {
      await prefs.remove('avatar_path');
    }
    state = state.copyWith(hasUnsavedChanges: false);
  }

  Future<void> toggleNotifications(bool value) async {
    state = state.copyWith(isNotificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<void> toggleSounds(bool value) async {
    state = state.copyWith(isSoundsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sounds_enabled', value);
  }

  Future<void> toggleDarkImmersion(bool value) async {
    state = state.copyWith(isDarkImmersion: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_immersion', value);
  }

  Future<void> toggleBioSync(bool value) async {
    state = state.copyWith(isBioSync: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bio_sync', value);
  }

  Future<void> toggleDevMode(bool value) async {
    state = state.copyWith(isDevMode: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dev_mode', value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

// ==========================================
// 2. ШАР ПРЕДСТАВЛЕННЯ ТА ІНТЕРФЕЙСУ (UI)
// ==========================================

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _changeAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (image != null) {
        ref.read(settingsProvider.notifier).setTempAvatar(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Не вдалося отримати доступ до сховища")),
      );
    }
  }

  void _openEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String oldName,
  ) {
    final controller = TextEditingController(text: oldName);
    final formKey = GlobalKey<FormState>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text(
          "Редагувати профіль",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            maxLength: 30,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              counterStyle: const TextStyle(color: Colors.white38),
              hintText: "Введіть нове ім'я",
              hintStyle: const TextStyle(color: Colors.white24),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return "Ім'я не може бути порожнім";
              if (value.trim().length > 30) return "Максимум 30 символів";
              return null;
            },
          ),
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
              if (formKey.currentState!.validate()) {
                ref
                    .read(settingsProvider.notifier)
                    .setTempUserName(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              "Застосувати",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFFFF007F)),
            SizedBox(width: 10),
            Text(
              "Обмеження доступу",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          "Зараз ця функція недоступна у вільному доступі.",
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Закрити",
              style: TextStyle(
                color: Color(0xFFFF007F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final AuthRepository authRepo = AuthRepository();
      await authRepo.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('avatar_path');

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Помилка при виході: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    final Color currentBgColor = settings.isDarkImmersion
        ? const Color(0xFF000000)
        : const Color(0xFF1A1A1E);

    // Робимо системну шторку девайса абсолютно прозорою
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: currentBgColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: currentBgColor,
      body: SafeArea(
        top: false, // Дозволяє контенту заходити під системний статус-бар
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            // ПРИДУМАНИЙ СКЛЯНИЙ ЕЛЕМЕНТ (LIQUID GLASS APP BAR)
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 15,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 15,
                  ), // Ефект розмиття за склом
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0.04,
                      ), // Напівпрозоре скло
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(
                          0.12,
                        ), // Світловий відблиск по краю (грань скла)
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(
                            0.08,
                          ), // Легке неонове світіння зсередини ліквіду
                          blurRadius: 20,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Кнопка назад всередині скла
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () => Navigator.maybePop(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: primaryColor, // Твій Neon Pink колір
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Текст "Налаштування" всередині скла
                        Text(
                          "Налаштування",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w600,
                            fontSize: 19,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Блок зміни аватара
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    backgroundImage: settings.avatarPath != null
                        ? FileImage(File(settings.avatarPath!))
                        : null,
                    child: settings.avatarPath == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white24,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _changeAvatar(context, ref),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_camera,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Блок зміни імені
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  settings.userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.mode_edit_outlined,
                    size: 18,
                    color: Colors.white54,
                  ),
                  onPressed: () =>
                      _openEditNameDialog(context, ref, settings.userName),
                ),
              ],
            ),

            // Динамічна кнопка збереження профилю
            if (settings.hasUnsavedChanges) ...[
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    await ref
                        .read(settingsProvider.notifier)
                        .saveProfileChanges();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Профіль успішно збережено!"),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text(
                    "Зберегти зміни",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            const Divider(color: Colors.white10, height: 35),

            _buildCategoryHeader("Система та сповіщення"),
            _buildCustomToggle(
              title: "Сповіщення",
              subtitle: "Дозволити push/local notifications",
              value: settings.isNotificationsEnabled,
              onChanged: (val) =>
                  ref.read(settingsProvider.notifier).toggleNotifications(val),
            ),
            _buildCustomToggle(
              title: "Звукові ефекти",
              subtitle: "Активація системних звуків у додатку",
              value: settings.isSoundsEnabled,
              onChanged: (val) =>
                  ref.read(settingsProvider.notifier).toggleSounds(val),
            ),

            const SizedBox(height: 16),
            _buildCategoryHeader("Параметри занурення"),
            _buildCustomToggle(
              title: "Dark Immersion",
              subtitle: "Абсолютно чорний колір фону матриці",
              value: settings.isDarkImmersion,
              onChanged: (val) =>
                  ref.read(settingsProvider.notifier).toggleDarkImmersion(val),
            ),
            _buildCustomToggle(
              title: "Bio Sync",
              subtitle: "Біометрична синхронізація станів",
              value: settings.isBioSync,
              onChanged: (val) =>
                  ref.read(settingsProvider.notifier).toggleBioSync(val),
            ),
            _buildCustomToggle(
              title: "Режим розробника",
              subtitle: "Активація логів та діагностики",
              value: settings.isDevMode,
              onChanged: (val) =>
                  ref.read(settingsProvider.notifier).toggleDevMode(val),
            ),

            const Divider(color: Colors.white10, height: 45),

            // Subscription Card
            Card(
              color: Colors.white.withOpacity(0.03),
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 3,
                ),
                leading: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFF007F), Color(0xFF7000FF)],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                title: const Text(
                  "Subscription",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Управління преміум планами",
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.white24,
                ),
                onTap: () => _showSubscriptionAlert(context),
              ),
            ),

            const SizedBox(height: 24),

            // Кнопка виходу з акаунта
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
                ),
                backgroundColor: Colors.redAccent.withOpacity(0.02),
              ),
              onPressed: () => _handleLogout(context),
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              label: const Text(
                "Вийти з акаунта",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildCustomToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14),
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.white30, fontSize: 12),
          ),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Допоміжне розширення для безпечних відступів зверху сторінки під ліквід-скло
extension on EdgeInsets {
  static double topNode(double mediaQueryTop, double fallback) {
    return mediaQueryTop > 0 ? mediaQueryTop : fallback;
  }
}
