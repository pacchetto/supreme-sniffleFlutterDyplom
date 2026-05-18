import 'package:flutter/material.dart';

final List<Map<String, dynamic>> breathingTechniques = [
  // --- КАТЕГОРІЯ: CHILL (Розслаблення) ---
  {
    "title": "4-7-8 Relax",
    "subtitle": "Natural tranquilizer for the nervous system",
    "category": "Chill",
    "icon": Icons.self_improvement,
    "color": const Color(0xFF8E44AD),
    "mode": "RELAXATION",
    "pattern": {"inhale": 4, "hold": 7, "exhale": 8, "holdAfter": 0},
    "durationSeconds":
        120, // 2 хв (Максимум 4-8 циклів, щоб не паморочилося в голові)
  },
  {
    "title": "Equal Breathing",
    "subtitle": "Balances the mind and body",
    "category": "Chill",
    "icon": Icons.waves,
    "color": const Color(0xFF3498DB),
    "mode": "BALANCE",
    "pattern": {"inhale": 4, "hold": 0, "exhale": 4, "holdAfter": 0},
    "durationSeconds":
        300, // 5 хв (Оптимальний час для гармонізації ритму серця)
  },
  {
    "title": "Coherent Breath",
    "subtitle": "Deep calming state",
    "category": "Chill",
    "icon": Icons.spa,
    "color": const Color(0xFF1ABC9C),
    "mode": "ZEN",
    "pattern": {"inhale": 6, "hold": 0, "exhale": 6, "holdAfter": 0},
    "durationSeconds":
        360, // 6 хв (Входить у резонанс 5 заземлюючих циклів на хвилину)
  },
  {
    "title": "Anti-Anxiety",
    "subtitle": "Quickly lower cortisol",
    "category": "Chill",
    "icon": Icons.favorite,
    "color": const Color(0xFFE74C3C),
    "mode": "CALM",
    "pattern": {"inhale": 4, "hold": 4, "exhale": 6, "holdAfter": 2},
    "durationSeconds":
        180, // 3 хв (Експрес-метод для блокування панічної атаки)
  },

  // --- КАТЕГОРІЯ: FOCUS (Концентрація) ---
  {
    "title": "Box Breathing",
    "subtitle": "The Navy SEAL technique for focus",
    "category": "Focus",
    "icon": Icons.crop_square,
    "color": const Color(0xFFF1C40F),
    "mode": "TACTICAL",
    "pattern": {"inhale": 4, "hold": 4, "exhale": 4, "holdAfter": 4},
    "durationSeconds":
        240, // 4 хв (Класичний тактичний таймінг спецпризначенців)
  },
  {
    "title": "Triangle Breath",
    "subtitle": "Sharpen your mental clarity",
    "category": "Focus",
    "icon": Icons.change_history,
    "color": const Color(0xFFE67E22),
    "mode": "SHARPEN",
    "pattern": {"inhale": 4, "hold": 4, "exhale": 4, "holdAfter": 0},
    "durationSeconds":
        180, // 3 хв (Коротке перезавантаження перед важким завданням)
  },
  {
    "title": "Memory Boost",
    "subtitle": "Improve cognitive retention",
    "category": "Focus",
    "icon": Icons.psychology,
    "color": const Color(0xFFD35400),
    "mode": "MIND",
    "pattern": {"inhale": 5, "hold": 2, "exhale": 5, "holdAfter": 0},
    "durationSeconds": 300, // 5 хв (Покращує насичення мозку киснем без втоми)
  },
  {
    "title": "Alpha Flow",
    "subtitle": "Enter the flow state",
    "category": "Focus",
    "icon": Icons.blur_on,
    "color": const Color(0xFF27AE60),
    "mode": "FLOW",
    "pattern": {"inhale": 4, "hold": 2, "exhale": 4, "holdAfter": 2},
    "durationSeconds": 300, // 5 хв (Баланс між стимуляцією та спокоєм)
  },

  // --- КАТЕГОРІЯ: SLEEP (Сон) ---
  {
    "title": "Deep Sleep",
    "subtitle": "Slow down for the night",
    "category": "Sleep",
    "icon": Icons.nights_stay,
    "color": const Color(0xFF2C3E50),
    "mode": "NIGHT",
    "pattern": {"inhale": 4, "hold": 2, "exhale": 8, "holdAfter": 0},
    "durationSeconds":
        420, // 7 хв (Подовжений видих м'яко вмикає блукаючий нерв)
  },
  {
    "title": "Lunar Rhythm",
    "subtitle": "Cooling and calming",
    "category": "Sleep",
    "icon": Icons.brightness_3,
    "color": const Color(0xFF5D6D7E),
    "mode": "MOON",
    "pattern": {"inhale": 3, "hold": 3, "exhale": 6, "holdAfter": 0},
    "durationSeconds": 300, // 5 хв (Охолодження нервової системи перед сном)
  },
  {
    "title": "Delta Wave",
    "subtitle": "Prepare for REM sleep",
    "category": "Sleep",
    "icon": Icons.bedtime,
    "color": const Color(0xFF34495E),
    "mode": "DELTA",
    "pattern": {"inhale": 5, "hold": 5, "exhale": 5, "holdAfter": 5},
    "durationSeconds": 480, // 8 хв (Глибока практика для швидкого засинання)
  },
  {
    "title": "Muscle Release",
    "subtitle": "Drop physical tension",
    "category": "Sleep",
    "icon": Icons.airline_seat_flat,
    "color": const Color(0xFF1C2833),
    "mode": "RELEASE",
    "pattern": {"inhale": 4, "hold": 1, "exhale": 7, "holdAfter": 0},
    "durationSeconds": 360, // 6 хв (Знімає нічні судоми та затиски в тілі)
  },

  // --- КАТЕГОРІЯ: ENERGIZE (Енергія) ---
  {
    "title": "Breath of Fire",
    "subtitle": "Rapid energizing breaths",
    "category": "Energize",
    "icon": Icons.whatshot,
    "color": const Color(0xFFE67E22),
    "mode": "FIRE",
    "pattern": {"inhale": 1, "hold": 0, "exhale": 1, "holdAfter": 0},
    "durationSeconds":
        60, // 1 хв (Гіпервентиляційна техніка, більше 1-2 хв новачкам не можна)
  },
  {
    "title": "Bellows Breath",
    "subtitle": "Invigorate your senses",
    "category": "Energize",
    "icon": Icons.flash_on,
    "color": const Color(0xFFFFCC00),
    "mode": "BOOST",
    "pattern": {"inhale": 2, "hold": 1, "exhale": 2, "holdAfter": 0},
    "durationSeconds": 90, // 1.5 хв (Потужний приплив кисню та енергії)
  },
  {
    "title": "Tummo-lite",
    "subtitle": "Generate internal heat",
    "category": "Energize",
    "icon": Icons.storm,
    "color": const Color(0xFFC0392B),
    "mode": "HEAT",
    "pattern": {"inhale": 2, "hold": 2, "exhale": 1, "holdAfter": 0},
    "durationSeconds":
        120, // 2 хв (Спрощений метод Віма Гофа для зігрівання та бадьорості)
  },
  {
    "title": "Wake Up Call",
    "subtitle": "Replace your morning coffee",
    "category": "Energize",
    "icon": Icons.light_mode,
    "color": const Color(0xFFF39C12),
    "mode": "WAKE",
    "pattern": {"inhale": 1, "hold": 1, "exhale": 1, "holdAfter": 1},
    "durationSeconds":
        90, // 1.5 хв (Швидкий викид адреналіну для легкого підйому)
  },
];

final List<String> categories = ["All", "Chill", "Focus", "Sleep", "Energize"];
