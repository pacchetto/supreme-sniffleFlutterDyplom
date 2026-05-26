import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_repository.dart'; // Вкажи свій правильний шлях до репозиторію

// 1. Провайдер репозиторію
final supabaseRepositoryProvider = Provider<SupabaseRepository>((ref) {
  return SupabaseRepository();
});

// 2. Асинхронний провайдер для завантаження даних (Профіль + Графік)
final userDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(supabaseRepositoryProvider);
  return await repository.loadUserData();
});
