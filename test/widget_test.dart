// Цей тест перевіряє, чи успішно запускається наш додаток AetheriaGraph.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Додаємо, бо ми використовуємо Riverpod

import 'package:aetheria_graph_app/main.dart'; // Переконайся, що назва пакету збігається з твоєю

void main() {
  testWidgets('AetheriaGraph app loads smoke test', (
    WidgetTester tester,
  ) async {
    // Будуємо наш додаток. Оскільки ми планували Riverpod,
    // огортаємо AetheriaApp у ProviderScope, як і в main.dart
    await tester.pumpWidget(const ProviderScope(child: AetheriaApp()));

    // Замість лічильника перевіряємо, чи завантажився наш Dashboard.
    // Шукаємо текст, який точно є на головному екрані:
    expect(find.text('Cyber Traveler'), findsOneWidget);
    expect(find.text('DAILY FLOW'), findsOneWidget);

    // Перевіряємо, що лічильника з плюсиком тут більше немає :)
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
