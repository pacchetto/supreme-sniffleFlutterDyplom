import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Провайдер для Dark Immersion (Amoled чорний або темно-сірий)
final darkImmersionProvider =
    StateNotifierProvider<DarkImmersionNotifier, bool>((ref) {
      return DarkImmersionNotifier();
    });

class DarkImmersionNotifier extends StateNotifier<bool> {
  DarkImmersionNotifier() : super(true) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('dark_immersion') ?? true;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_immersion', value);
  }
}

// Провайдер для Bio-Feedback Sync (Рожевий неон або білий/тьмяний)
final bioSyncProvider = StateNotifierProvider<BioSyncNotifier, bool>((ref) {
  return BioSyncNotifier();
});

class BioSyncNotifier extends StateNotifier<bool> {
  BioSyncNotifier() : super(true) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('bio_sync') ?? true;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bio_sync', value);
  }
}
