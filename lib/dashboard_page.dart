import 'package:aetheria_graph_app/breathing_data_localized.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'session_page.dart';
import 'all_techniques_page.dart';
// ignore: unused_import
import 'profile_page.dart';
import 'package:aetheria_graph_app/l10n/app_localizations.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int activeCategoryIndex = 0;

  // 1. МЕТОД ДЛЯ ПОВІДОМЛЕНЬ
  void _showNotifications(Color activePink) {
    final l10n = AppLocalizations.of(context)!;
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                l10n.notificationsTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildNotifyItem(
              l10n.newSession,
              l10n.newSessionDesc,
              Icons.auto_awesome,
              activePink,
            ),
            _buildNotifyItem(
              l10n.goalReached,
              l10n.goalReachedDesc,
              Icons.military_tech,
              activePink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifyItem(
    String title,
    String sub,
    IconData icon,
    Color activePink,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: activePink.withOpacity(0.1),
        child: Icon(icon, color: activePink, size: 20),
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

  void _navigateToPlayer(Map<String, dynamic> technique, Color activePink) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionPage(techniqueData: technique),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Отримуємо стани з провайдерів
    final isDarkImmersion = ref.watch(darkImmersionProvider);
    final isBioSync = ref.watch(bioSyncProvider);

    // ДИНАМІЧНІ КОЛЬОРИ
    // 1. Фон екрана залежить від Dark Immersion
    final Color backgroundColor = isDarkImmersion
        ? const Color(0xFF000000)
        : const Color(0xFF121212);

    // 2. Головний акцент залежить від BioSync
    final Color currentPink = isBioSync
        ? const Color(0xFFFF007F) // Яскравий кіберпанк неон
        : const Color(
            0xFF00E5FF,
          ); // Спокійний бірюзовий неон (якщо BioSync вимкнено)

    // Динамічні категорії з локалізацією
    final categories = [
      l10n.categoryAll,
      l10n.categoryChill,
      l10n.categoryFocus,
      l10n.categorySleep,
      l10n.categoryEnergize,
    ];

    // Отримуємо локалізовані техніки
    final breathingTechniques = getLocalizedBreathingTechniques(context);

    // ЛОГІКА ФІЛЬТРАЦІЇ
    final categoryKeys = ["All", "Chill", "Focus", "Sleep", "Energize"];
    String selectedCat = categoryKeys[activeCategoryIndex];
    List<Map<String, dynamic>> filteredTechniques;

    if (selectedCat == "All") {
      filteredTechniques = List.from(breathingTechniques);
    } else {
      filteredTechniques = breathingTechniques
          .where((t) => t['category'] == selectedCat)
          .toList();
    }

    return Scaffold(
      backgroundColor: backgroundColor, // Застосовуємо динамічний фон тут
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(currentPink),
                const SizedBox(height: 24),
                _buildCategories(currentPink),
                const SizedBox(height: 28),
                _buildFeaturedCard(currentPink, isBioSync),
                const SizedBox(height: 32),
                _buildRecentSessionsHeader(filteredTechniques, currentPink),
                const SizedBox(height: 16),
                _buildTechniquesList(filteredTechniques, currentPink),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color currentPink) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.welcomeBackLabel,
              style: TextStyle(
                color: currentPink, // Динамічний колір
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.goodEvening,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showNotifications(currentPink),
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

  Widget _buildCategories(Color currentPink) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      l10n.categoryAll,
      l10n.categoryChill,
      l10n.categoryFocus,
      l10n.categorySleep,
      l10n.categoryEnergize,
    ];

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
                      ? currentPink.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activeCategoryIndex == index
                        ? currentPink.withOpacity(0.5)
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

  Widget _buildFeaturedCard(Color currentPink, bool isBioSync) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: AssetImage('assets/images/waves_bg.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: currentPink.withOpacity(0.15),
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
                      color: currentPink,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: currentPink,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBioSync ? l10n.liveGeneration : l10n.standardFlow,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.dailyGenerativeFlow,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _navigateToPlayer({
                "title": l10n.dailyGenerativeFlow,
                "mode": isBioSync ? l10n.liveGeneration : l10n.standardFlow,
                "color": currentPink,
              }, currentPink),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: currentPink,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: currentPink.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.startSession,
                      style: const TextStyle(
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

  Widget _buildRecentSessionsHeader(
    List<Map<String, dynamic>> currentData,
    Color currentPink,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.breathingTechniques,
          style: const TextStyle(
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
              l10n.viewAll,
              style: TextStyle(
                color: currentPink,
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

  Widget _buildTechniquesList(
    List<Map<String, dynamic>> data,
    Color currentPink,
  ) {
    return Column(
      children: data.map((technique) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () => _navigateToPlayer(technique, currentPink),
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
