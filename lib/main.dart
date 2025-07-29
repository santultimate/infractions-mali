import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infractions_mali/screens/home_screen.dart';
import 'package:infractions_mali/widgets/app_background.dart';
import 'package:infractions_mali/services/alert_service.dart';
import 'package:infractions_mali/services/auth_service.dart';

// Global key for snackbar notifications
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background notification: ${message.messageId}');
}

Future<void> _initializeFirebaseMessaging() async {
  try {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received');

      if (message.notification != null) {
        final notification = message.notification!;
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
              notification.title != null
                  ? '${notification.title!}: ${notification.body ?? ''}'
                  : notification.body ?? 'New notification',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  } catch (e) {
    debugPrint('Firebase Messaging initialization error: $e');
  }
}

Future<void> _initializeMobileAds() async {
  // Only initialize Mobile Ads on mobile platforms
  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
      debugPrint('Mobile Ads initialized successfully');
    } catch (e) {
      debugPrint('Mobile Ads initialization error: $e');
    }
  } else {
    debugPrint('Mobile Ads skipped on web platform');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize core services
    await EasyLocalization.ensureInitialized();

    // Initialize Firebase only on mobile platforms or if web config is available
    if (!kIsWeb) {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      await _initializeFirebaseMessaging();
    } else {
      debugPrint('Firebase initialization skipped on web platform');
    }

    await _initializeMobileAds();

    // Initialize services
    final alertService = kIsWeb
        ? AlertService()
        : AlertService(firestore: FirebaseFirestore.instance);
    final authService = kIsWeb
        ? AuthService()
        : AuthService(
            auth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            facebookAuth: FacebookAuth.instance,
          );

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('fr'), Locale('en')],
        path: 'assets/lang',
        fallbackLocale: const Locale('fr'),
        child: InfractionsApp(
          alertService: alertService,
          authService: authService,
        ),
      ),
    );
  } catch (e) {
    debugPrint('App initialization error: $e');
    // Fallback app without Firebase
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('fr'), Locale('en')],
        path: 'assets/lang',
        fallbackLocale: const Locale('fr'),
        child: InfractionsApp(
          alertService: AlertService(),
          authService: AuthService(),
        ),
      ),
    );
  }
}

class InfractionsApp extends StatelessWidget {
  final AlertService alertService;
  final AuthService authService;

  const InfractionsApp({
    super.key,
    required this.alertService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'app_title'.tr(),
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: AppBackground(
        child: HomeScreen(
          alertService: alertService,
          authService: authService,
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.red,
      brightness: Brightness.light,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.red,
      scaffoldBackgroundColor: Colors.black,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[900],
        behavior: SnackBarBehavior.floating,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
