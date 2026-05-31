// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'CYBER MONK';

  @override
  String get welcomeBack => 'WELCOME BACK, ASCETIC';

  @override
  String get startImmersion => 'START YOUR IMMERSION';

  @override
  String get email => 'EMAIL';

  @override
  String get password => 'PASSWORD';

  @override
  String get invalidEmail => 'Некоректний Email';

  @override
  String get passwordMinLength => 'Пароль має бути від 6 символів';

  @override
  String get forgotPassword => 'FORGOT PASSWORD?';

  @override
  String get enter => 'ENTER';

  @override
  String get createAccount => 'CREATE ACCOUNT';

  @override
  String get newMonkRegister => 'NEW MONK? REGISTER HERE';

  @override
  String get alreadyHaveAccount => 'ALREADY HAVE AN ACCOUNT? LOGIN';

  @override
  String get or => 'OR';

  @override
  String get continueAsGuest => 'CONTINUE AS GUEST';

  @override
  String get ok => 'ОК';

  @override
  String get newAccessCode => 'NEW ACCESS CODE';

  @override
  String get newPasswordPrompt =>
      'Введіть новий безпечний пароль для вашого нейропрофілю.';

  @override
  String get newPassword => 'NEW PASSWORD';

  @override
  String get minSixChars => 'Мінімум 6 символів';

  @override
  String get savePassword => 'SAVE PASSWORD';

  @override
  String get success => 'УСПІХ';

  @override
  String get passwordUpdated =>
      'Ваш пароль успішно оновлено в хмарі. Тепер ви можете увійти.';

  @override
  String get syncError => 'ПОМИЛКА СИНХРОНІЗАЦІЇ';

  @override
  String get dataError => 'ПОМИЛКА ДАНИХ';

  @override
  String get forgotPasswordPrompt =>
      'Будь ласка, спочатку введіть коректний Email у поле вище, щоб ми надіслали лінк для відновлення доступу.';

  @override
  String get recovery => 'ВІДНОВЛЕННЯ';

  @override
  String get resetLinkSent =>
      'Кібер-лінк для скидання пароля надіслано на вашу пошту. Перевірте скриньку.';

  @override
  String get cyberProtection => 'КІБЕР-ЗАХИСТ';

  @override
  String get rateLimitError =>
      'Занадто багато запитів. Будь ласка, зачекайте хвилину перед наступною спробою відновлення доступу.';

  @override
  String get verification => 'ВЕРИФІКАЦІЯ';

  @override
  String get checkEmailActivation =>
      'Запит надіслано успішно. Будь ласка, перевірте вашу електронну пошту для активації акаунта.';

  @override
  String get accessError => 'ПОМИЛКА ДОСТУПУ';

  @override
  String get invalidCredentials =>
      'Невірний Email або пароль. Перевірте правильність введених даних.';

  @override
  String get networkError =>
      'Помилка мережі. Перевірте з\'єднання з інтернетом.';

  @override
  String get userAlreadyRegistered =>
      'Цей користувач уже зареєстрований у системі.';

  @override
  String get guestError => 'ПОМИЛКА ГУЕСТА';

  @override
  String anonymousSessionError(Object error) {
    return 'Не вдалося ініціалізувати анонімний сеанс: $error';
  }

  @override
  String get welcomeBackLabel => 'WELCOME BACK';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get newSession => 'New Session';

  @override
  String get newSessionDesc => 'Try the new \'Dream Weaver\' for better sleep';

  @override
  String get goalReached => 'Goal Reached';

  @override
  String get goalReachedDesc => 'You\'ve completed 3 days streak!';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryChill => 'Chill';

  @override
  String get categoryFocus => 'Focus';

  @override
  String get categorySleep => 'Sleep';

  @override
  String get categoryEnergize => 'Energize';

  @override
  String get liveGeneration => 'LIVE GENERATION';

  @override
  String get standardFlow => 'STANDARD FLOW';

  @override
  String get dailyGenerativeFlow => 'Daily Generative Flow';

  @override
  String get startSession => 'Start Session';

  @override
  String get breathingTechniques => 'Breathing Techniques';

  @override
  String get viewAll => 'VIEW ALL';

  @override
  String get meditated => 'MEDITATED';

  @override
  String get dayStreak => 'DAY STREAK';

  @override
  String get clarity => 'CLARITY';

  @override
  String get focusLevel => 'Focus Level';

  @override
  String get period7d => '7D';

  @override
  String get period1m => '1M';

  @override
  String get periodAll => 'ALL';

  @override
  String get systemPreferences => 'SYSTEM PREFERENCES';

  @override
  String get bioFeedbackSync => 'Bio-Feedback Sync';

  @override
  String get darkImmersion => 'Dark Immersion';

  @override
  String get zenNotifications => 'Zen Notifications';

  @override
  String get settingsAndPrivacy => 'Settings & Privacy';

  @override
  String get version => 'v1.0.0-build.42';

  @override
  String xpToNextLevel(Object nextXp, Object xp) {
    return '$xp XP / $nextXp XP to next lvl';
  }

  @override
  String connectionError(Object error) {
    return 'Помилка з\'єднання: $error';
  }

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get editProfile => 'Редагувати профіль';

  @override
  String get enterNewName => 'Введіть нове ім\'я';

  @override
  String get nameCannotBeEmpty => 'Ім\'я не може бути порожнім';

  @override
  String get maxThirtyChars => 'Максимум 30 символів';

  @override
  String get cancel => 'Скасувати';

  @override
  String get apply => 'Застосувати';

  @override
  String get accessRestriction => 'Обмеження доступу';

  @override
  String get featureNotAvailable =>
      'Зараз ця функція недоступна у вільному доступі.';

  @override
  String get close => 'Закрити';

  @override
  String logoutError(Object error) {
    return 'Помилка при виході: $error';
  }

  @override
  String get storageAccessError => 'Не вдалося отримати доступ до сховища';

  @override
  String get profileSavedSuccess => 'Профіль успішно збережено в хмару!';

  @override
  String get profileSaveError => 'Помилка збереження. Перевірте мережу.';

  @override
  String get syncing => 'Синхронізація...';

  @override
  String get saveChanges => 'Зберегти зміни';

  @override
  String get systemAndNotifications => 'Система та сповіщення';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get notificationsDesc => 'Дозволити push/local notifications';

  @override
  String get soundEffects => 'Звукові ефекти';

  @override
  String get soundEffectsDesc => 'Активація системних звуків у додатку';

  @override
  String get immersionParams => 'Параметри занурення';

  @override
  String get darkImmersionDesc => 'Абсолютно чорний колір фону матриці';

  @override
  String get bioSync => 'Bio Sync';

  @override
  String get bioSyncDesc => 'Біометрична синхронізація станів';

  @override
  String get devMode => 'Режим розробника';

  @override
  String get devModeDesc => 'Активація логів та діагностики (Гра)';

  @override
  String get subscription => 'Subscription';

  @override
  String get subscriptionDesc => 'Управління преміум планами';

  @override
  String get logout => 'Вийти з акаунта';

  @override
  String get systemCalibrated => '[SYSTEM]: Ядро вже відкалібровано.';

  @override
  String calibrationRemaining(Object count) {
    return '[SYSTEM]: До калібрування ядра залишилось: $count';
  }

  @override
  String get devModeEnabled => '[SYSTEM]: Режим розробника увімкнено';

  @override
  String get language => 'Мова';

  @override
  String get languageDesc => 'Оберіть мову інтерфейсу';

  @override
  String get cyberGuide => 'Cyber Guide';

  @override
  String get online => 'Online';

  @override
  String get clearHistory => 'Очистити історію';

  @override
  String get clearChatQuestion => 'Очистити чат?';

  @override
  String get clearChatWarning =>
      'Уся історія повідомлень з Cyber Guide буде видалена безповоротно.';

  @override
  String get clear => 'Очистити';

  @override
  String get initialGreeting =>
      'Привіт, Traveler. Я твій цифровий гід. Як ти почуваєшся сьогодні?';

  @override
  String get describeYourState => 'Опиши свій стан...';

  @override
  String get cyberGuideAnalyzing => 'Cyber Guide аналізує...';

  @override
  String systemsOverloaded(Object code) {
    return 'Системи перевантажені. (Помилка API: $code)';
  }

  @override
  String get connectionLost =>
      'Втрачено зв\'язок з нейромережею. Перевір інтернет.';

  @override
  String get loading => 'Завантаження...';

  @override
  String get error => 'Помилка';

  @override
  String get back => 'Назад';
}
