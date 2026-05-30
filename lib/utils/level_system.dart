import 'package:flutter/material.dart';

// ---------------------------------------------------------------------
// 1. КЛАСИ ДЛЯ СТРОГОЇ ТИПІЗАЦІЇ
// ---------------------------------------------------------------------

class CyberRank {
  final String title;
  final String titleUa;
  final Color color;
  final int minLevel;
  final int maxLevel;

  const CyberRank({
    required this.title,
    required this.titleUa,
    required this.color,
    required this.minLevel,
    required this.maxLevel,
  });
}

class UserLevelData {
  final int level;
  final int xp;
  final CyberRank rank;
  final int xpForNextLevel;
  final int progressPercent;
  final int currentLevelXp;
  final int nextLevelXp;

  const UserLevelData({
    required this.level,
    required this.xp,
    required this.rank,
    required this.xpForNextLevel,
    required this.progressPercent,
    required this.currentLevelXp,
    required this.nextLevelXp,
  });
}

// Максимальний рівень в системі: 30 (Cyber Monk)
// Рівні розраховуються автоматично: Рівень = (XP / 100) + 1
// Максимум можна збільшити, змінивши maxLevel у останньому рангу

const List<CyberRank> _ranks = [
  CyberRank(
    title: 'Cyber Novice',
    titleUa: 'Кібер-Новачок',
    color: Color(0xFF00BFD9),
    minLevel: 1,
    maxLevel: 4,
  ),
  CyberRank(
    title: 'Neon Adept',
    titleUa: 'Неоновий Адепт',
    color: Color(0xFF00D98E),
    minLevel: 5,
    maxLevel: 9,
  ),
  CyberRank(
    title: 'Focus Nomad',
    titleUa: 'Кочівник Фокусу',
    color: Color(0xFFFFB900),
    minLevel: 10,
    maxLevel: 17,
  ),
  CyberRank(
    title: 'Techno Wanderer',
    titleUa: 'Техно-Мандрівник',
    color: Color(0xFFFF7F3F),
    minLevel: 18,
    maxLevel: 23,
  ),
  CyberRank(
    title: 'Matrix Sentinel',
    titleUa: 'Вартовий Матриці',
    color: Color(0xFFFF3F5F),
    minLevel: 24,
    maxLevel: 29,
  ),
  CyberRank(
    title: 'Cyber Monk',
    titleUa: 'Кібер-Чернець',
    color: Color(0xFF9D4EDD),
    minLevel: 30,
    maxLevel: 999,
  ),
];

// ---------------------------------------------------------------------
// 3. ЛОГІКА РОЗРАХУНКІВ
// ---------------------------------------------------------------------

/// Розраховує рівень на основі загальної кількості XP (Кожні 100 XP = +1 рівень)
int getLevelFromXp(int xp) => (xp ~/ 100) + 1;

/// Шукає ранг за поточним рівнем
CyberRank getRankInfo(int level) {
  return _ranks.firstWhere(
    (rank) => level >= rank.minLevel && level <= rank.maxLevel,
    // Якщо рівень вийде за межі (наприклад > 999), повертаємо найвищий ранг
    orElse: () => _ranks.last,
  );
}

/// Головна функція: повертає об'єкт з усією інформацією
UserLevelData getUserLevelInfo({required int xp}) {
  final level = getLevelFromXp(xp);
  final rank = getRankInfo(level);

  final currentLevelXp = (level - 1) * 100;
  final nextLevelXp = level * 100;

  final progressInLevel = xp - currentLevelXp;
  final totalXpInLevel = nextLevelXp - currentLevelXp;

  final progressPercent = ((progressInLevel / totalXpInLevel) * 100).toInt();
  final xpForNext = nextLevelXp - xp;

  return UserLevelData(
    level: level,
    xp: xp,
    rank: rank,
    xpForNextLevel: xpForNext,
    progressPercent: progressPercent,
    currentLevelXp: currentLevelXp,
    nextLevelXp: nextLevelXp,
  );
}
