import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infractions_mali/screens/home_screen.dart';
import 'package:infractions_mali/widgets/app_background.dart';
import 'package:infractions_mali/services/alert_service.dart';

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
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
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
        ),
      );
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    Firebase.initializeApp(),
    MobileAds.instance.initialize(),
  ]);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initializeFirebaseMessaging();

  // Initialize services
  final alertService = AlertService();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('en')],
      path: 'assets/lang',
      fallbackLocale: const Locale('fr'),
      child: InfractionsApp(alertService: alertService),
    ),
  );
}

class InfractionsApp extends StatelessWidget {
  final AlertService alertService;

  const InfractionsApp({
    super.key,
    required this.alertService,
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
        child: HomeScreen(alertService: alertService),
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
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.red,
      scaffoldBackgroundColor: Colors.black,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[900],
      ),
      useMaterial3: true,
    );
  }
}