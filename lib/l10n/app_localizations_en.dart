// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get invalidEmail => 'Invalid Email';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

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
  String get ok => 'OK';

  @override
  String get newAccessCode => 'NEW ACCESS CODE';

  @override
  String get newPasswordPrompt =>
      'Enter a new secure password for your neuroprofile.';

  @override
  String get newPassword => 'NEW PASSWORD';

  @override
  String get minSixChars => 'Minimum 6 characters';

  @override
  String get savePassword => 'SAVE PASSWORD';

  @override
  String get success => 'SUCCESS';

  @override
  String get passwordUpdated =>
      'Your password has been successfully updated in the cloud. You can now log in.';

  @override
  String get syncError => 'SYNC ERROR';

  @override
  String get dataError => 'DATA ERROR';

  @override
  String get forgotPasswordPrompt =>
      'Please enter a valid Email in the field above so we can send you a recovery link.';

  @override
  String get recovery => 'RECOVERY';

  @override
  String get resetLinkSent =>
      'Cyber-link for password reset has been sent to your email. Check your inbox.';

  @override
  String get cyberProtection => 'CYBER PROTECTION';

  @override
  String get rateLimitError =>
      'Too many requests. Please wait a minute before trying to recover access again.';

  @override
  String get verification => 'VERIFICATION';

  @override
  String get checkEmailActivation =>
      'Request sent successfully. Please check your email to activate your account.';

  @override
  String get accessError => 'ACCESS ERROR';

  @override
  String get invalidCredentials =>
      'Invalid Email or password. Please check your credentials.';

  @override
  String get networkError =>
      'Network error. Please check your internet connection.';

  @override
  String get userAlreadyRegistered =>
      'This email is already registered. Please sign in or reset your password.';

  @override
  String get guestError => 'GUEST ERROR';

  @override
  String anonymousSessionError(Object error) {
    return 'Failed to initialize anonymous session: $error';
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
    return 'Connection error: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get enterNewName => 'Enter new name';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get maxThirtyChars => 'Maximum 30 characters';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get accessRestriction => 'Access Restriction';

  @override
  String get featureNotAvailable =>
      'This feature is currently not available for free access.';

  @override
  String get close => 'Close';

  @override
  String logoutError(Object error) {
    return 'Logout error: $error';
  }

  @override
  String get storageAccessError => 'Failed to access storage';

  @override
  String get profileSavedSuccess => 'Profile successfully saved to cloud!';

  @override
  String get profileSaveError => 'Save error. Check your network.';

  @override
  String get syncing => 'Syncing...';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get systemAndNotifications => 'System and Notifications';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDesc => 'Allow push/local notifications';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get soundEffectsDesc => 'Activate system sounds in the app';

  @override
  String get immersionParams => 'Immersion Parameters';

  @override
  String get darkImmersionDesc =>
      'Absolute black background color of the matrix';

  @override
  String get bioSync => 'Bio Sync';

  @override
  String get bioSyncDesc => 'Biometric state synchronization';

  @override
  String get devMode => 'Developer Mode';

  @override
  String get devModeDesc => 'Activate logs and diagnostics (Game)';

  @override
  String get subscription => 'Subscription';

  @override
  String get subscriptionDesc => 'Manage premium plans';

  @override
  String get logout => 'Logout';

  @override
  String get systemCalibrated => '[SYSTEM]: Core already calibrated.';

  @override
  String calibrationRemaining(Object count) {
    return '[SYSTEM]: Calibration remaining: $count';
  }

  @override
  String get devModeEnabled => '[SYSTEM]: Developer mode enabled';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Choose interface language';

  @override
  String get cyberGuide => 'Cyber Guide';

  @override
  String get online => 'Online';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get clearChatQuestion => 'Clear chat?';

  @override
  String get clearChatWarning =>
      'All message history with Cyber Guide will be permanently deleted.';

  @override
  String get clear => 'Clear';

  @override
  String get initialGreeting =>
      'Hello, Traveler. I\'m your digital guide. How are you feeling today?';

  @override
  String get describeYourState => 'Describe your state...';

  @override
  String get cyberGuideAnalyzing => 'Cyber Guide analyzing...';

  @override
  String systemsOverloaded(Object code) {
    return 'Systems overloaded. (API Error: $code)';
  }

  @override
  String get connectionLost =>
      'Lost connection to neural network. Check your internet.';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get back => 'Back';

  @override
  String get breathingPhaseReady => 'READY';

  @override
  String get breathingPhaseInhale => 'INHALE';

  @override
  String get breathingPhaseHold => 'HOLD';

  @override
  String get breathingPhaseExhale => 'EXHALE';

  @override
  String get breathingPhasePaused => 'PAUSED';

  @override
  String get breathingPhaseFinished => 'FINISHED';

  @override
  String get sessionModeRelaxation => 'RELAXATION';

  @override
  String get breathSpeed => 'BREATH SPEED';

  @override
  String get breathSpeedStill => 'STILL';

  @override
  String get breathSpeedDynamic => 'DYNAMIC';

  @override
  String get sessionCompleteMessage => 'SESSION COMPLETE! PROGRESS SAVED 🎉';

  @override
  String get allTechniquesTitle => 'All Techniques';

  @override
  String get technique478Title => '4-7-8 Relax';

  @override
  String get technique478Subtitle =>
      'Natural tranquilizer for the nervous system';

  @override
  String get techniqueEqualTitle => 'Equal Breathing';

  @override
  String get techniqueEqualSubtitle => 'Balances the mind and body';

  @override
  String get techniqueCoherentTitle => 'Coherent Breath';

  @override
  String get techniqueCoherentSubtitle => 'Deep calming state';

  @override
  String get techniqueAntiAnxietyTitle => 'Anti-Anxiety';

  @override
  String get techniqueAntiAnxietySubtitle => 'Quickly lower cortisol';

  @override
  String get techniqueBoxTitle => 'Box Breathing';

  @override
  String get techniqueBoxSubtitle => 'The Navy SEAL technique for focus';

  @override
  String get techniqueTriangleTitle => 'Triangle Breath';

  @override
  String get techniqueTriangleSubtitle => 'Sharpen your mental clarity';

  @override
  String get techniqueMemoryTitle => 'Memory Boost';

  @override
  String get techniqueMemorySubtitle => 'Improve cognitive retention';

  @override
  String get techniqueAlphaTitle => 'Alpha Flow';

  @override
  String get techniqueAlphaSubtitle => 'Enter the flow state';

  @override
  String get techniqueDeepSleepTitle => 'Deep Sleep';

  @override
  String get techniqueDeepSleepSubtitle => 'Slow down for the night';

  @override
  String get techniqueLunarTitle => 'Lunar Rhythm';

  @override
  String get techniqueLunarSubtitle => 'Cooling and calming';

  @override
  String get techniqueDeltaTitle => 'Delta Wave';

  @override
  String get techniqueDeltaSubtitle => 'Prepare for REM sleep';

  @override
  String get techniqueMuscleTitle => 'Muscle Release';

  @override
  String get techniqueMuscleSubtitle => 'Drop physical tension';

  @override
  String get techniqueFireTitle => 'Breath of Fire';

  @override
  String get techniqueFireSubtitle => 'Rapid energizing breaths';

  @override
  String get techniqueBellowsTitle => 'Bellows Breath';

  @override
  String get techniqueBellowsSubtitle => 'Invigorate your senses';

  @override
  String get techniqueTummoTitle => 'Tummo-lite';

  @override
  String get techniqueTummoSubtitle => 'Generate internal heat';

  @override
  String get techniqueWakeTitle => 'Wake Up Call';

  @override
  String get techniqueWakeSubtitle => 'Replace your morning coffee';

  @override
  String get modeRelaxation => 'RELAXATION';

  @override
  String get modeBalance => 'BALANCE';

  @override
  String get modeZen => 'ZEN';

  @override
  String get modeCalm => 'CALM';

  @override
  String get modeTactical => 'TACTICAL';

  @override
  String get modeSharpen => 'SHARPEN';

  @override
  String get modeMind => 'MIND';

  @override
  String get modeFlow => 'FLOW';

  @override
  String get modeNight => 'NIGHT';

  @override
  String get modeMoon => 'MOON';

  @override
  String get modeDelta => 'DELTA';

  @override
  String get modeRelease => 'RELEASE';

  @override
  String get modeFire => 'FIRE';

  @override
  String get modeBoost => 'BOOST';

  @override
  String get modeHeat => 'HEAT';

  @override
  String get modeWake => 'WAKE';

  @override
  String get bioFeedbackSyncProfile => 'Bio-Feedback Sync';

  @override
  String get darkImmersionProfile => 'Dark Immersion';

  @override
  String get zenNotificationsProfile => 'Zen Notifications';
}
