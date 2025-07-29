class AppMetadata {
  // Application Information
  static const String appName = 'Infractions Mali';
  static const String appDescription =
      'Application de sécurité routière au Mali';
  static const String appVersion = '1.0.0';
  static const int appVersionCode = 1;

  // Developer Information
  static const String developerName = 'Yacouba Santara';
  static const String developerEmail = 'support@infractions-mali.com';
  static const String developerWebsite =
      'https://github.com/votre-username/infractions_mali';

  // Application URLs
  static const String privacyPolicyUrl = 'https://infractions-mali.com/privacy';
  static const String termsOfServiceUrl = 'https://infractions-mali.com/terms';
  static const String supportUrl = 'https://infractions-mali.com/support';
  static const String feedbackUrl = 'https://infractions-mali.com/feedback';

  // Social Media
  static const String facebookPage = 'https://facebook.com/infractionsmali';
  static const String twitterHandle = '@infractionsmali';
  static const String instagramHandle = '@infractionsmali';

  // Contact Information
  static const String contactPhone = '+223 XX XX XX XX';
  static const String contactWhatsapp = '+223 XX XX XX XX';
  static const String contactTelegram = '@infractionsmali';

  // Legal Information
  static const String copyright =
      '© 2024 Yacouba Santara. Tous droits réservés.';
  static const String license = 'MIT License';
  static const String licenseUrl = 'https://opensource.org/licenses/MIT';

  // Technical Information
  static const String minSdkVersion = '21';
  static const String targetSdkVersion = '34';
  static const String minIosVersion = '12.0';
  static const String targetIosVersion = '17.0';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enablePushNotifications = true;
  static const bool enableLocationServices = true;
  static const bool enableSocialLogin = true;
  static const bool enableDonations = true;
  static const bool enableAds = true;

  // Configuration
  static const int maxAlertsPerUser = 100;
  static const int maxCommentsPerAlert = 50;
  static const int maxPhotosPerAlert = 5;
  static const double maxAlertDistanceKm = 50.0;
  static const int alertExpirationDays = 7;
  static const int commentExpirationDays = 30;

  // API Configuration
  static const String apiBaseUrl = 'https://api.infractions-mali.com';
  static const String wazeApiUrl =
      'https://api.waze.com/row-rtserver/web/TGeoRSS';
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Firebase Configuration
  static const String firebaseProjectId = 'infractions-mali';
  static const String firebaseMessagingSenderId = '123456789';
  static const String firebaseAppId = '1:123456789:android:abcdef123456';

  // AdMob Configuration
  static const String admobAppId = 'ca-app-pub-7487587531173203~1234567890';
  static const String admobBannerAdUnitIdAndroid =
      'ca-app-pub-7487587531173203/4925907434';
  static const String admobInterstitialAdUnitIdAndroid =
      'ca-app-pub-7487587531173203/8083387965';
  static const String admobBannerAdUnitIdIos =
      'ca-app-pub-7487587531173203/7914855242';
  static const String admobInterstitialAdUnitIdIos =
      'ca-app-pub-7487587531173203/9260738260';

  // Orange Money Configuration
  static const String orangeMoneyMerchantId = 'YOUR_MERCHANT_ID';
  static const String orangeMoneyApiKey = 'YOUR_API_KEY';
  static const String orangeMoneyApiUrl = 'https://api.orange.com/money';

  // Localization
  static const List<String> supportedLanguages = ['fr', 'en'];
  static const String defaultLanguage = 'fr';
  static const String fallbackLanguage = 'fr';

  // Map Configuration
  static const double defaultMapZoom = 12.0;
  static const double minMapZoom = 8.0;
  static const double maxMapZoom = 18.0;
  static const double defaultMapLatitude = 12.65;
  static const double defaultMapLongitude = -8.0;
  static const double defaultSearchRadiusKm = 5.0;

  // Notification Configuration
  static const String notificationChannelId = 'infractions_mali_channel';
  static const String notificationChannelName = 'Infractions Mali';
  static const String notificationChannelDescription =
      'Notifications pour les alertes routières';
  static const int notificationImportance = 3; // High importance

  // Cache Configuration
  static const int maxCacheSizeMb = 50;
  static const int cacheExpirationDays = 7;
  static const int maxCachedAlerts = 1000;
  static const int maxCachedImages = 100;

  // Security Configuration
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  static const bool requireEmailVerification = true;
  static const bool requirePhoneVerification = false;
  static const int passwordMinLength = 8;
  static const bool requireStrongPassword = true;

  // Performance Configuration
  static const int maxConcurrentRequests = 5;
  static const int requestTimeoutMs = 30000;
  static const int imageCompressionQuality = 80;
  static const int maxImageSizeKb = 1024;
  static const bool enableImageCaching = true;
  static const bool enableDataCompression = true;

  // Debug Configuration
  static const bool enableDebugLogging = true;
  static const bool enablePerformanceLogging = true;
  static const bool enableNetworkLogging = true;
  static const bool enableErrorReporting = true;
  static const bool enableCrashReportingDebug = true;

  // Testing Configuration
  static const bool enableTestMode = false;
  static const String testApiUrl = 'https://test-api.infractions-mali.com';
  static const String testFirebaseProjectId = 'infractions-mali-test';
  static const bool enableMockData = false;
  static const bool enableTestAds = false;

  // Release Configuration
  static const bool enableProductionMode = true;
  static const bool enableStagingMode = false;
  static const bool enableBetaMode = false;
  static const bool enableAlphaMode = false;

  // Update Configuration
  static const bool enableAutoUpdate = true;
  static const bool enableUpdateNotifications = true;
  static const String updateCheckUrl =
      'https://api.infractions-mali.com/updates';
  static const int updateCheckIntervalHours = 24;

  // Backup Configuration
  static const bool enableAutoBackup = true;
  static const int backupIntervalHours = 24;
  static const int maxBackupFiles = 10;
  static const bool enableCloudBackup = false;

  // Accessibility Configuration
  static const bool enableAccessibilitySupport = true;
  static const bool enableScreenReaderSupport = true;
  static const bool enableHighContrastMode = true;
  static const bool enableLargeTextMode = true;
  static const bool enableVoiceCommands = false;

  // Privacy Configuration
  static const bool enableDataCollection = true;
  static const bool enableAnalyticsCollection = true;
  static const bool enableCrashReportingCollection = true;
  static const bool enableLocationTracking = true;
  static const bool enableUsageStatistics = true;
  static const int dataRetentionDays = 365;

  // Compliance Configuration
  static const bool gdprCompliant = true;
  static const bool ccpaCompliant = false;
  static const bool coppaCompliant = false;
  static const String privacyPolicyVersion = '1.0';
  static const String termsOfServiceVersion = '1.0';

  // Support Configuration
  static const bool enableInAppSupport = true;
  static const bool enableEmailSupport = true;
  static const bool enablePhoneSupport = false;
  static const bool enableChatSupport = false;
  static const String supportEmail = 'support@infractions-mali.com';
  static const String supportPhone = '+223 XX XX XX XX';
  static const String supportHours = 'Lun-Ven: 9h-18h';

  // Documentation
  static const String userGuideUrl = 'https://infractions-mali.com/guide';
  static const String faqUrl = 'https://infractions-mali.com/faq';
  static const String tutorialUrl = 'https://infractions-mali.com/tutorial';
  static const String videoTutorialUrl = 'https://youtube.com/infractionsmali';

  // Community
  static const String communityForumUrl = 'https://forum.infractions-mali.com';
  static const String communityDiscordUrl =
      'https://discord.gg/infractionsmali';
  static const String communityTelegramUrl = 'https://t.me/infractionsmali';
  static const String communityWhatsappUrl = 'https://wa.me/223XXXXXXXXX';

  // Road Safety Information
  static const String roadSafetyTipsUrl =
      'https://infractions-mali.com/safety-tips';
  static const String trafficRulesUrl =
      'https://infractions-mali.com/traffic-rules';
  static const String emergencyNumbersUrl =
      'https://infractions-mali.com/emergency';
  static const String roadConditionsUrl =
      'https://infractions-mali.com/road-conditions';

  // Government Resources
  static const String policeWebsite = 'https://www.police.gov.ml';
  static const String transportWebsite = 'https://www.transport.gov.ml';
  static const String emergencyNumber = '17';
  static const String roadAssistanceNumber = '8033';

  // App Store Information
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.infractionsmali.app';
  static const String appStoreUrl =
      'https://apps.apple.com/app/infractions-mali/id123456789';
  static const String appGalleryUrl =
      'https://appgallery.huawei.com/app/C123456789';

  // Version History
  static const Map<String, String> versionHistory = {
    '1.0.0': 'Version initiale avec authentification et cartographie',
    '1.0.1': 'Corrections de bugs et améliorations de performance',
    '1.0.2': 'Ajout des notifications push et amélioration de l\'interface',
    '1.0.3': 'Intégration Orange Money et amélioration de la sécurité',
  };

  // Changelog
  static const String currentChangelog = '''
Version 1.0.0 - Version Initiale

Nouvelles fonctionnalités :
• Authentification Google et Facebook
• Cartographie interactive avec OpenStreetMap
• Système d'alertes routières en temps réel
• Commentaires et votes sur les alertes
• Notifications push
• Support multilingue (Français/Anglais)
• Intégration Orange Money pour les dons
• Publicités AdMob
• Mode sombre/clair
• Statistiques d'utilisation

Améliorations :
• Interface utilisateur moderne Material Design 3
• Performance optimisée
• Sécurité renforcée
• Accessibilité améliorée

Corrections :
• Bugs de navigation
• Problèmes de géolocalisation
• Erreurs d'affichage
''';
}
