// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'AETHERIA GRAPH';

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
      'Цей email вже використовується. Увійдіть в акаунт або скористайтесь відновленням пароля.';

  @override
  String get guestError => 'ПОМИЛКА ГУЕСТА';

  @override
  String anonymousSessionError(Object error) {
    return 'Не вдалося ініціалізувати анонімний сеанс: $error';
  }

  @override
  String get welcomeBackLabel => 'З ПОВЕРНЕННЯМ';

  @override
  String get goodEvening => 'Добрий вечір';

  @override
  String get notificationsTitle => 'Сповіщення';

  @override
  String get newSession => 'Нова сесія';

  @override
  String get newSessionDesc =>
      'Спробуй нову техніку \'Ткач снів\' для кращого сну';

  @override
  String get goalReached => 'Ціль досягнута';

  @override
  String get goalReachedDesc => 'Ти завершив 3-денну серію!';

  @override
  String get categoryAll => 'Усі';

  @override
  String get categoryChill => 'Релакс';

  @override
  String get categoryFocus => 'Фокус';

  @override
  String get categorySleep => 'Сон';

  @override
  String get categoryEnergize => 'Енергія';

  @override
  String get liveGeneration => 'ЖИВА ГЕНЕРАЦІЯ';

  @override
  String get standardFlow => 'СТАНДАРТНИЙ ПОТІК';

  @override
  String get dailyGenerativeFlow => 'Щоденний генеративний потік';

  @override
  String get startSession => 'Почати сесію';

  @override
  String get breathingTechniques => 'Техніки дихання';

  @override
  String get viewAll => 'ДИВИТИСЬ ВСІ';

  @override
  String get meditated => 'МЕДИТОВАНО';

  @override
  String get dayStreak => 'ДНІВ ПІДРЯД';

  @override
  String get clarity => 'ЯСНІСТЬ';

  @override
  String get focusLevel => 'Рівень фокусу';

  @override
  String get period7d => '7Д';

  @override
  String get period1m => '1М';

  @override
  String get periodAll => 'ВСІ';

  @override
  String get systemPreferences => 'СИСТЕМНІ НАЛАШТУВАННЯ';

  @override
  String get bioFeedbackSync => 'Біо-синхронізація';

  @override
  String get darkImmersion => 'Темне занурення';

  @override
  String get zenNotifications => 'Дзен-сповіщення';

  @override
  String get settingsAndPrivacy => 'Налаштування та конфіденційність';

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

  @override
  String get breathingPhaseReady => 'ГОТОВО';

  @override
  String get breathingPhaseInhale => 'ВДИХ';

  @override
  String get breathingPhaseHold => 'ЗАТРИМКА';

  @override
  String get breathingPhaseExhale => 'ВИДИХ';

  @override
  String get breathingPhasePaused => 'ПАУЗА';

  @override
  String get breathingPhaseFinished => 'ЗАВЕРШЕНО';

  @override
  String get sessionModeRelaxation => 'РЕЛАКСАЦІЯ';

  @override
  String get breathSpeed => 'ШВИДКІСТЬ ДИХАННЯ';

  @override
  String get breathSpeedStill => 'ПОВІЛЬНО';

  @override
  String get breathSpeedDynamic => 'ДИНАМІЧНО';

  @override
  String get sessionCompleteMessage => 'СЕСІЮ ЗАВЕРШЕНО! ПРОГРЕС ЗБЕРЕЖЕНО 🎉';

  @override
  String get allTechniquesTitle => 'Усі техніки';

  @override
  String get technique478Title => '4-7-8 Релакс';

  @override
  String get technique478Subtitle =>
      'Природний транквілізатор для нервової системи';

  @override
  String get techniqueEqualTitle => 'Рівне дихання';

  @override
  String get techniqueEqualSubtitle => 'Балансує розум і тіло';

  @override
  String get techniqueCoherentTitle => 'Когерентне дихання';

  @override
  String get techniqueCoherentSubtitle => 'Глибокий заспокійливий стан';

  @override
  String get techniqueAntiAnxietyTitle => 'Анти-тривога';

  @override
  String get techniqueAntiAnxietySubtitle => 'Швидко знижує кортизол';

  @override
  String get techniqueBoxTitle => 'Квадратне дихання';

  @override
  String get techniqueBoxSubtitle => 'Техніка Navy SEAL для концентрації';

  @override
  String get techniqueTriangleTitle => 'Трикутне дихання';

  @override
  String get techniqueTriangleSubtitle => 'Загострює ментальну ясність';

  @override
  String get techniqueMemoryTitle => 'Підсилення пам\'яті';

  @override
  String get techniqueMemorySubtitle => 'Покращує когнітивне утримання';

  @override
  String get techniqueAlphaTitle => 'Альфа-потік';

  @override
  String get techniqueAlphaSubtitle => 'Увійти в стан потоку';

  @override
  String get techniqueDeepSleepTitle => 'Глибокий сон';

  @override
  String get techniqueDeepSleepSubtitle => 'Уповільнення на ніч';

  @override
  String get techniqueLunarTitle => 'Місячний ритм';

  @override
  String get techniqueLunarSubtitle => 'Охолодження та заспокоєння';

  @override
  String get techniqueDeltaTitle => 'Дельта-хвиля';

  @override
  String get techniqueDeltaSubtitle => 'Підготовка до REM-сну';

  @override
  String get techniqueMuscleTitle => 'Розслаблення м\'язів';

  @override
  String get techniqueMuscleSubtitle => 'Зняття фізичної напруги';

  @override
  String get techniqueFireTitle => 'Дихання вогню';

  @override
  String get techniqueFireSubtitle => 'Швидкі енергетичні вдихи';

  @override
  String get techniqueBellowsTitle => 'Дихання міхів';

  @override
  String get techniqueBellowsSubtitle => 'Оживляє почуття';

  @override
  String get techniqueTummoTitle => 'Туммо-лайт';

  @override
  String get techniqueTummoSubtitle => 'Генерує внутрішнє тепло';

  @override
  String get techniqueWakeTitle => 'Ранковий дзвінок';

  @override
  String get techniqueWakeSubtitle => 'Замінює ранкову каву';

  @override
  String get modeRelaxation => 'РЕЛАКСАЦІЯ';

  @override
  String get modeBalance => 'БАЛАНС';

  @override
  String get modeZen => 'ДЗЕН';

  @override
  String get modeCalm => 'СПОКІЙ';

  @override
  String get modeTactical => 'ТАКТИЧНИЙ';

  @override
  String get modeSharpen => 'ЗАГОСТРЕННЯ';

  @override
  String get modeMind => 'РОЗУМ';

  @override
  String get modeFlow => 'ПОТІК';

  @override
  String get modeNight => 'НІЧ';

  @override
  String get modeMoon => 'МІСЯЦЬ';

  @override
  String get modeDelta => 'ДЕЛЬТА';

  @override
  String get modeRelease => 'ЗВІЛЬНЕННЯ';

  @override
  String get modeFire => 'ВОГОНЬ';

  @override
  String get modeBoost => 'ПІДСИЛЕННЯ';

  @override
  String get modeHeat => 'ТЕПЛО';

  @override
  String get modeWake => 'ПРОБУДЖЕННЯ';

  @override
  String get bioFeedbackSyncProfile => 'Bio-Feedback Sync';

  @override
  String get darkImmersionProfile => 'Dark Immersion';

  @override
  String get zenNotificationsProfile => 'Zen Notifications';
}
