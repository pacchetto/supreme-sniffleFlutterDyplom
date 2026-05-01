import 'package:flutter/material.dart';
import 'session_page.dart';
import 'all_techniques_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color neonPink = const Color(0xFFFF007F);
  final List<String> categories = ["Chill", "Focus", "Sleep", "Energize"];
  int activeCategoryIndex = 0;

  // Розширена база даних
  final List<Map<String, dynamic>> breathingTechniques = [
    {
      "title": "Box Breathing",
      "subtitle": "Clear mind & focus • 5 min",
      "mode": "DEEP FOCUS",
      "icon": Icons.crop_square_rounded,
      "color": const Color(0xFFFF007F), // Рожевий
    },
    {
      "title": "4-7-8 Relax",
      "subtitle": "Fall asleep faster • 8 min",
      "mode": "DEEP SLEEP",
      "icon": Icons.nightlight_round,
      "color": const Color(0xFFB066FF), // Фіолетовий
    },
    {
      "title": "Fire Breath",
      "subtitle": "Morning energy • 3 min",
      "mode": "ENERGY BOOST",
      "icon": Icons.local_fire_department_rounded,
      "color": const Color(0xFFFF4B4B), // Червоний
    },
    {
      "title": "Resonance",
      "subtitle": "Heart coherence • 10 min",
      "mode": "CALM STATE",
      "icon": Icons.favorite_border_rounded,
      "color": const Color(0xFF00D0FF), // Блакитний
    },
    {
      "title": "Nadi Shodhana",
      "subtitle": "Balance nervous system • 7 min",
      "mode": "BALANCE",
      "icon": Icons.air_rounded,
      "color": const Color(0xFF00FF88), // Зелений
    },
    {
      "title": "Wim Hof Method",
      "subtitle": "Immunity & Power • 15 min",
      "mode": "POWER",
      "icon": Icons.ac_unit_rounded,
      "color": const Color(0xFF00E5FF), // Ціан
    },
    {
      "title": "Sama Vritti",
      "subtitle": "Equal breathing • 6 min",
      "mode": "HARMONY",
      "icon": Icons.sync_rounded,
      "color": const Color(0xFFFFB300), // Бурштиновий
    },
  ];

  void _navigateToPlayer(Map<String, dynamic> technique) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionPage(techniqueData: technique),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildCategories(),
              const SizedBox(height: 28),
              _buildFeaturedCard(),
              const SizedBox(height: 32),
              _buildRecentSessionsHeader(),
              const SizedBox(height: 16),
              _buildTechniquesList(),
              const SizedBox(height: 120), // Відступ для нижнього меню
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WELCOME BACK",
              style: TextStyle(
                color: neonPink,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Good Evening",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: List.generate(
          categories.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => setState(() => activeCategoryIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: activeCategoryIndex == index
                      ? neonPink.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activeCategoryIndex == index
                        ? neonPink.withOpacity(0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: activeCategoryIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    fontWeight: activeCategoryIndex == index
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      height: 320,
      width: double.infinity,
      // 1. ФОН: Тільки картинка та тінь
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: AssetImage('assets/images/waves_bg.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: neonPink.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: neonPink,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: neonPink,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "LIVE GENERATION",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Daily Generative Flow",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _navigateToPlayer({
                "title": "Daily Generative Flow",
                "mode": "LIVE GENERATION",
                "color": neonPink,
              }),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: neonPink,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: neonPink.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Start Session",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "Breathing Techniques",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // ЗРОБИЛИ КНОПКУ КЛІКАБЕЛЬНОЮ
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // Передаємо весь список на новий екран
                builder: (context) =>
                    AllTechniquesPage(techniques: breathingTechniques),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
            ), // Щоб легше було натиснути
            child: Text(
              "VIEW ALL",
              style: TextStyle(
                color: neonPink,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTechniquesList() {
    return Column(
      children: breathingTechniques.take(3).map((technique) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () => _navigateToPlayer(technique),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      technique["icon"],
                      color: technique["color"],
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technique["title"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          technique["subtitle"],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
