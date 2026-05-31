import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In uk, this message translates to:
  /// **'CYBER MONK'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In uk, this message translates to:
  /// **'WELCOME BACK, ASCETIC'**
  String get welcomeBack;

  /// No description provided for @startImmersion.
  ///
  /// In uk, this message translates to:
  /// **'START YOUR IMMERSION'**
  String get startImmersion;

  /// No description provided for @email.
  ///
  /// In uk, this message translates to:
  /// **'EMAIL'**
  String get email;

  /// No description provided for @password.
  ///
  /// In uk, this message translates to:
  /// **'PASSWORD'**
  String get password;

  /// No description provided for @invalidEmail.
  ///
  /// In uk, this message translates to:
  /// **'Некоректний Email'**
  String get invalidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In uk, this message translates to:
  /// **'Пароль має бути від 6 символів'**
  String get passwordMinLength;

  /// No description provided for @forgotPassword.
  ///
  /// In uk, this message translates to:
  /// **'FORGOT PASSWORD?'**
  String get forgotPassword;

  /// No description provided for @enter.
  ///
  /// In uk, this message translates to:
  /// **'ENTER'**
  String get enter;

  /// No description provided for @createAccount.
  ///
  /// In uk, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccount;

  /// No description provided for @newMonkRegister.
  ///
  /// In uk, this message translates to:
  /// **'NEW MONK? REGISTER HERE'**
  String get newMonkRegister;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In uk, this message translates to:
  /// **'ALREADY HAVE AN ACCOUNT? LOGIN'**
  String get alreadyHaveAccount;

  /// No description provided for @or.
  ///
  /// In uk, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueAsGuest.
  ///
  /// In uk, this message translates to:
  /// **'CONTINUE AS GUEST'**
  String get continueAsGuest;

  /// No description provided for @ok.
  ///
  /// In uk, this message translates to:
  /// **'ОК'**
  String get ok;

  /// No description provided for @newAccessCode.
  ///
  /// In uk, this message translates to:
  /// **'NEW ACCESS CODE'**
  String get newAccessCode;

  /// No description provided for @newPasswordPrompt.
  ///
  /// In uk, this message translates to:
  /// **'Введіть новий безпечний пароль для вашого нейропрофілю.'**
  String get newPasswordPrompt;

  /// No description provided for @newPassword.
  ///
  /// In uk, this message translates to:
  /// **'NEW PASSWORD'**
  String get newPassword;

  /// No description provided for @minSixChars.
  ///
  /// In uk, this message translates to:
  /// **'Мінімум 6 символів'**
  String get minSixChars;

  /// No description provided for @savePassword.
  ///
  /// In uk, this message translates to:
  /// **'SAVE PASSWORD'**
  String get savePassword;

  /// No description provided for @success.
  ///
  /// In uk, this message translates to:
  /// **'УСПІХ'**
  String get success;

  /// No description provided for @passwordUpdated.
  ///
  /// In uk, this message translates to:
  /// **'Ваш пароль успішно оновлено в хмарі. Тепер ви можете увійти.'**
  String get passwordUpdated;

  /// No description provided for @syncError.
  ///
  /// In uk, this message translates to:
  /// **'ПОМИЛКА СИНХРОНІЗАЦІЇ'**
  String get syncError;

  /// No description provided for @dataError.
  ///
  /// In uk, this message translates to:
  /// **'ПОМИЛКА ДАНИХ'**
  String get dataError;

  /// No description provided for @forgotPasswordPrompt.
  ///
  /// In uk, this message translates to:
  /// **'Будь ласка, спочатку введіть коректний Email у поле вище, щоб ми надіслали лінк для відновлення доступу.'**
  String get forgotPasswordPrompt;

  /// No description provided for @recovery.
  ///
  /// In uk, this message translates to:
  /// **'ВІДНОВЛЕННЯ'**
  String get recovery;

  /// No description provided for @resetLinkSent.
  ///
  /// In uk, this message translates to:
  /// **'Кібер-лінк для скидання пароля надіслано на вашу пошту. Перевірте скриньку.'**
  String get resetLinkSent;

  /// No description provided for @cyberProtection.
  ///
  /// In uk, this message translates to:
  /// **'КІБЕР-ЗАХИСТ'**
  String get cyberProtection;

  /// No description provided for @rateLimitError.
  ///
  /// In uk, this message translates to:
  /// **'Занадто багато запитів. Будь ласка, зачекайте хвилину перед наступною спробою відновлення доступу.'**
  String get rateLimitError;

  /// No description provided for @verification.
  ///
  /// In uk, this message translates to:
  /// **'ВЕРИФІКАЦІЯ'**
  String get verification;

  /// No description provided for @checkEmailActivation.
  ///
  /// In uk, this message translates to:
  /// **'Запит надіслано успішно. Будь ласка, перевірте вашу електронну пошту для активації акаунта.'**
  String get checkEmailActivation;

  /// No description provided for @accessError.
  ///
  /// In uk, this message translates to:
  /// **'ПОМИЛКА ДОСТУПУ'**
  String get accessError;

  /// No description provided for @invalidCredentials.
  ///
  /// In uk, this message translates to:
  /// **'Невірний Email або пароль. Перевірте правильність введених даних.'**
  String get invalidCredentials;

  /// No description provided for @networkError.
  ///
  /// In uk, this message translates to:
  /// **'Помилка мережі. Перевірте з\'єднання з інтернетом.'**
  String get networkError;

  /// No description provided for @userAlreadyRegistered.
  ///
  /// In uk, this message translates to:
  /// **'Цей користувач уже зареєстрований у системі.'**
  String get userAlreadyRegistered;

  /// No description provided for @guestError.
  ///
  /// In uk, this message translates to:
  /// **'ПОМИЛКА ГУЕСТА'**
  String get guestError;

  /// No description provided for @anonymousSessionError.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося ініціалізувати анонімний сеанс: {error}'**
  String anonymousSessionError(Object error);

  /// No description provided for @welcomeBackLabel.
  ///
  /// In uk, this message translates to:
  /// **'WELCOME BACK'**
  String get welcomeBackLabel;

  /// No description provided for @goodEvening.
  ///
  /// In uk, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @notificationsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @newSession.
  ///
  /// In uk, this message translates to:
  /// **'New Session'**
  String get newSession;

  /// No description provided for @newSessionDesc.
  ///
  /// In uk, this message translates to:
  /// **'Try the new \'Dream Weaver\' for better sleep'**
  String get newSessionDesc;

  /// No description provided for @goalReached.
  ///
  /// In uk, this message translates to:
  /// **'Goal Reached'**
  String get goalReached;

  /// No description provided for @goalReachedDesc.
  ///
  /// In uk, this message translates to:
  /// **'You\'ve completed 3 days streak!'**
  String get goalReachedDesc;

  /// No description provided for @categoryAll.
  ///
  /// In uk, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryChill.
  ///
  /// In uk, this message translates to:
  /// **'Chill'**
  String get categoryChill;

  /// No description provided for @categoryFocus.
  ///
  /// In uk, this message translates to:
  /// **'Focus'**
  String get categoryFocus;

  /// No description provided for @categorySleep.
  ///
  /// In uk, this message translates to:
  /// **'Sleep'**
  String get categorySleep;

  /// No description provided for @categoryEnergize.
  ///
  /// In uk, this message translates to:
  /// **'Energize'**
  String get categoryEnergize;

  /// No description provided for @liveGeneration.
  ///
  /// In uk, this message translates to:
  /// **'LIVE GENERATION'**
  String get liveGeneration;

  /// No description provided for @standardFlow.
  ///
  /// In uk, this message translates to:
  /// **'STANDARD FLOW'**
  String get standardFlow;

  /// No description provided for @dailyGenerativeFlow.
  ///
  /// In uk, this message translates to:
  /// **'Daily Generative Flow'**
  String get dailyGenerativeFlow;

  /// No description provided for @startSession.
  ///
  /// In uk, this message translates to:
  /// **'Start Session'**
  String get startSession;

  /// No description provided for @breathingTechniques.
  ///
  /// In uk, this message translates to:
  /// **'Breathing Techniques'**
  String get breathingTechniques;

  /// No description provided for @viewAll.
  ///
  /// In uk, this message translates to:
  /// **'VIEW ALL'**
  String get viewAll;

  /// No description provided for @meditated.
  ///
  /// In uk, this message translates to:
  /// **'MEDITATED'**
  String get meditated;

  /// No description provided for @dayStreak.
  ///
  /// In uk, this message translates to:
  /// **'DAY STREAK'**
  String get dayStreak;

  /// No description provided for @clarity.
  ///
  /// In uk, this message translates to:
  /// **'CLARITY'**
  String get clarity;

  /// No description provided for @focusLevel.
  ///
  /// In uk, this message translates to:
  /// **'Focus Level'**
  String get focusLevel;

  /// No description provided for @period7d.
  ///
  /// In uk, this message translates to:
  /// **'7D'**
  String get period7d;

  /// No description provided for @period1m.
  ///
  /// In uk, this message translates to:
  /// **'1M'**
  String get period1m;

  /// No description provided for @periodAll.
  ///
  /// In uk, this message translates to:
  /// **'ALL'**
  String get periodAll;

  /// No description provided for @systemPreferences.
  ///
  /// In uk, this message translates to:
  /// **'SYSTEM PREFERENCES'**
  String get systemPreferences;

  /// No description provided for @bioFeedbackSync.
  ///
  /// In uk, this message translates to:
  /// **'Bio-Feedback Sync'**
  String get bioFeedbackSync;

  /// No description provided for @darkImmersion.
  ///
  /// In uk, this message translates to:
  /// **'Dark Immersion'**
  String get darkImmersion;

  /// No description provided for @zenNotifications.
  ///
  /// In uk, this message translates to:
  /// **'Zen Notifications'**
  String get zenNotifications;

  /// No description provided for @settingsAndPrivacy.
  ///
  /// In uk, this message translates to:
  /// **'Settings & Privacy'**
  String get settingsAndPrivacy;

  /// No description provided for @version.
  ///
  /// In uk, this message translates to:
  /// **'v1.0.0-build.42'**
  String get version;

  /// No description provided for @xpToNextLevel.
  ///
  /// In uk, this message translates to:
  /// **'{xp} XP / {nextXp} XP to next lvl'**
  String xpToNextLevel(Object nextXp, Object xp);

  /// No description provided for @connectionError.
  ///
  /// In uk, this message translates to:
  /// **'Помилка з\'єднання: {error}'**
  String connectionError(Object error);

  /// No description provided for @settingsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get settingsTitle;

  /// No description provided for @editProfile.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати профіль'**
  String get editProfile;

  /// No description provided for @enterNewName.
  ///
  /// In uk, this message translates to:
  /// **'Введіть нове ім\'я'**
  String get enterNewName;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Ім\'я не може бути порожнім'**
  String get nameCannotBeEmpty;

  /// No description provided for @maxThirtyChars.
  ///
  /// In uk, this message translates to:
  /// **'Максимум 30 символів'**
  String get maxThirtyChars;

  /// No description provided for @cancel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In uk, this message translates to:
  /// **'Застосувати'**
  String get apply;

  /// No description provided for @accessRestriction.
  ///
  /// In uk, this message translates to:
  /// **'Обмеження доступу'**
  String get accessRestriction;

  /// No description provided for @featureNotAvailable.
  ///
  /// In uk, this message translates to:
  /// **'Зараз ця функція недоступна у вільному доступі.'**
  String get featureNotAvailable;

  /// No description provided for @close.
  ///
  /// In uk, this message translates to:
  /// **'Закрити'**
  String get close;

  /// No description provided for @logoutError.
  ///
  /// In uk, this message translates to:
  /// **'Помилка при виході: {error}'**
  String logoutError(Object error);

  /// No description provided for @storageAccessError.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося отримати доступ до сховища'**
  String get storageAccessError;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In uk, this message translates to:
  /// **'Профіль успішно збережено в хмару!'**
  String get profileSavedSuccess;

  /// No description provided for @profileSaveError.
  ///
  /// In uk, this message translates to:
  /// **'Помилка збереження. Перевірте мережу.'**
  String get profileSaveError;

  /// No description provided for @syncing.
  ///
  /// In uk, this message translates to:
  /// **'Синхронізація...'**
  String get syncing;

  /// No description provided for @saveChanges.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти зміни'**
  String get saveChanges;

  /// No description provided for @systemAndNotifications.
  ///
  /// In uk, this message translates to:
  /// **'Система та сповіщення'**
  String get systemAndNotifications;

  /// No description provided for @notifications.
  ///
  /// In uk, this message translates to:
  /// **'Сповіщення'**
  String get notifications;

  /// No description provided for @notificationsDesc.
  ///
  /// In uk, this message translates to:
  /// **'Дозволити push/local notifications'**
  String get notificationsDesc;

  /// No description provided for @soundEffects.
  ///
  /// In uk, this message translates to:
  /// **'Звукові ефекти'**
  String get soundEffects;

  /// No description provided for @soundEffectsDesc.
  ///
  /// In uk, this message translates to:
  /// **'Активація системних звуків у додатку'**
  String get soundEffectsDesc;

  /// No description provided for @immersionParams.
  ///
  /// In uk, this message translates to:
  /// **'Параметри занурення'**
  String get immersionParams;

  /// No description provided for @darkImmersionDesc.
  ///
  /// In uk, this message translates to:
  /// **'Абсолютно чорний колір фону матриці'**
  String get darkImmersionDesc;

  /// No description provided for @bioSync.
  ///
  /// In uk, this message translates to:
  /// **'Bio Sync'**
  String get bioSync;

  /// No description provided for @bioSyncDesc.
  ///
  /// In uk, this message translates to:
  /// **'Біометрична синхронізація станів'**
  String get bioSyncDesc;

  /// No description provided for @devMode.
  ///
  /// In uk, this message translates to:
  /// **'Режим розробника'**
  String get devMode;

  /// No description provided for @devModeDesc.
  ///
  /// In uk, this message translates to:
  /// **'Активація логів та діагностики (Гра)'**
  String get devModeDesc;

  /// No description provided for @subscription.
  ///
  /// In uk, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @subscriptionDesc.
  ///
  /// In uk, this message translates to:
  /// **'Управління преміум планами'**
  String get subscriptionDesc;

  /// No description provided for @logout.
  ///
  /// In uk, this message translates to:
  /// **'Вийти з акаунта'**
  String get logout;

  /// No description provided for @systemCalibrated.
  ///
  /// In uk, this message translates to:
  /// **'[SYSTEM]: Ядро вже відкалібровано.'**
  String get systemCalibrated;

  /// No description provided for @calibrationRemaining.
  ///
  /// In uk, this message translates to:
  /// **'[SYSTEM]: До калібрування ядра залишилось: {count}'**
  String calibrationRemaining(Object count);

  /// No description provided for @devModeEnabled.
  ///
  /// In uk, this message translates to:
  /// **'[SYSTEM]: Режим розробника увімкнено'**
  String get devModeEnabled;

  /// No description provided for @language.
  ///
  /// In uk, this message translates to:
  /// **'Мова'**
  String get language;

  /// No description provided for @languageDesc.
  ///
  /// In uk, this message translates to:
  /// **'Оберіть мову інтерфейсу'**
  String get languageDesc;

  /// No description provided for @cyberGuide.
  ///
  /// In uk, this message translates to:
  /// **'Cyber Guide'**
  String get cyberGuide;

  /// No description provided for @online.
  ///
  /// In uk, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @clearHistory.
  ///
  /// In uk, this message translates to:
  /// **'Очистити історію'**
  String get clearHistory;

  /// No description provided for @clearChatQuestion.
  ///
  /// In uk, this message translates to:
  /// **'Очистити чат?'**
  String get clearChatQuestion;

  /// No description provided for @clearChatWarning.
  ///
  /// In uk, this message translates to:
  /// **'Уся історія повідомлень з Cyber Guide буде видалена безповоротно.'**
  String get clearChatWarning;

  /// No description provided for @clear.
  ///
  /// In uk, this message translates to:
  /// **'Очистити'**
  String get clear;

  /// No description provided for @initialGreeting.
  ///
  /// In uk, this message translates to:
  /// **'Привіт, Traveler. Я твій цифровий гід. Як ти почуваєшся сьогодні?'**
  String get initialGreeting;

  /// No description provided for @describeYourState.
  ///
  /// In uk, this message translates to:
  /// **'Опиши свій стан...'**
  String get describeYourState;

  /// No description provided for @cyberGuideAnalyzing.
  ///
  /// In uk, this message translates to:
  /// **'Cyber Guide аналізує...'**
  String get cyberGuideAnalyzing;

  /// No description provided for @systemsOverloaded.
  ///
  /// In uk, this message translates to:
  /// **'Системи перевантажені. (Помилка API: {code})'**
  String systemsOverloaded(Object code);

  /// No description provided for @connectionLost.
  ///
  /// In uk, this message translates to:
  /// **'Втрачено зв\'язок з нейромережею. Перевір інтернет.'**
  String get connectionLost;

  /// No description provided for @loading.
  ///
  /// In uk, this message translates to:
  /// **'Завантаження...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In uk, this message translates to:
  /// **'Помилка'**
  String get error;

  /// No description provided for @back.
  ///
  /// In uk, this message translates to:
  /// **'Назад'**
  String get back;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
