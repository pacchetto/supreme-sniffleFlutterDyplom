import 'package:aetheria_graph_app/breathing_data.dart';
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
  final List<String> categories = [
    "All",
    "Chill",
    "Focus",
    "Sleep",
    "Energize",
  ];
  int activeCategoryIndex = 0;

  // 1. МЕТОД ДЛЯ ПОВІДОМЛЕНЬ
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "Notifications",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Список "фейкових" повідомлень для дизайну
            _buildNotifyItem(
              "New Session",
              "Try the new 'Dream Weaver' for better sleep",
              Icons.auto_awesome,
            ),
            _buildNotifyItem(
              "Goal Reached",
              "You've completed 3 days streak!",
              Icons.military_tech,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifyItem(String title, String sub, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: neonPink.withOpacity(0.1),
        child: Icon(icon, color: neonPink, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        sub,
        style: TextStyle(color: Colors.white.withOpacity(0.6)),
      ),
    );
  }

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
    // 2. ЛОГІКА ФІЛЬТРАЦІЇ
    String selectedCat = categories[activeCategoryIndex];

    // Створюємо список для відображення
    List<Map<String, dynamic>> filteredTechniques;

    if (selectedCat == "All") {
      // ЯКЩО "ALL" — БЕРЕМО ВЕСЬ СПИСОК БЕЗ ЖОДНИХ УМОВ
      filteredTechniques = List.from(breathingTechniques);
    } else {
      // ІНАКШЕ — ФІЛЬТРУЄМО
      filteredTechniques = breathingTechniques
          .where((t) => t['category'] == selectedCat)
          .toList();
    }

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
              _buildHeader(), // Тут тепер працює кнопка
              const SizedBox(height: 24),
              _buildCategories(),
              const SizedBox(height: 28),
              _buildFeaturedCard(),
              const SizedBox(height: 32),
              _buildRecentSessionsHeader(
                filteredTechniques,
              ), // Передаємо відфільтровані дані
              const SizedBox(height: 16),
              _buildTechniquesList(
                filteredTechniques,
              ), // Передаємо відфільтровані дані
              const SizedBox(height: 120),
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
        GestureDetector(
          onTap: _showNotifications, // ВИКЛИК МЕНЮ
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 24,
            ),
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

  Widget _buildRecentSessionsHeader(List<Map<String, dynamic>> currentData) {
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
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AllTechniquesPage(techniques: currentData),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
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

  Widget _buildTechniquesList(List<Map<String, dynamic>> data) {
    return Column(
      // Ми просто перетворюємо кожну мапу з отриманого списку 'data' у віджет
      children: data.map((technique) {
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
                  // Іконка
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (technique["color"] as Color? ?? Colors.grey)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      technique["icon"] ?? Icons.air,
                      color: technique["color"] ?? Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Тексти
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technique["title"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          technique["subtitle"] ?? "",
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
