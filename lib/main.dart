// import 'dart:io'; // WARNING: Unused import - SUPPRIMÉ
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/home_screen.dart'; // Assurez-vous que ce chemin est correct
import 'widgets/app_background.dart'; // Assurez-vous que ce chemin est correct

// Clé globale pour le ScaffoldMessenger
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Handler des notifications en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // INFO: Don't invoke 'print' in production code. (Considérez de le supprimer ou d'utiliser un logger)
  debugPrint('Notification reçue en background : ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // INFO: Don't invoke 'print' in production code.
  debugPrint('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // INFO: Don't invoke 'print' in production code.
    debugPrint('Got a message whilst in the foreground!');
    // INFO: Don't invoke 'print' in production code.
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      // INFO: Don't invoke 'print' in production code.
      debugPrint('Message also contained a notification: ${message.notification}');
      final notification = message.notification!;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            notification.title != null
                ? '${notification.title!}: ${notification.body ?? ''}'
                : notification.body ?? 'Nouvelle notification',
          ),
          backgroundColor: Colors.blue,
        ),
      );
    }
  });

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('en')], // INFO: Use 'const'
      path: 'assets/lang',
      fallbackLocale: const Locale('fr'), // INFO: Use 'const'
      // child: const InfractionsApp(), // ERROR: Peut causer l'erreur si InfractionsApp ou ses enfants ne sont pas const
      child: InfractionsApp(),
    ),
  );
}

class InfractionsApp extends StatelessWidget {
  // INFO: Parameter 'key' could be a super parameter.
  // const InfractionsApp({Key? key}) : super(key: key);
  const InfractionsApp({super.key}); // CORRIGÉ avec super parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: tr('app_title'),
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        snackBarTheme: SnackBarThemeData(backgroundColor: Colors.grey[900]),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      // ERROR: The constructor being called isn't a const constructor (const_with_non_const at [infrations_mali] lib/main.dart:117)
      // home: AppBackground(child: const HomeScreen()), // Si HomeScreen() n'a pas de constructeur const ou si AppBackground ne le gère pas
      home: AppBackground(child: HomeScreen()), // Supposant que HomeScreen ou AppBackground ne sont pas const constructibles ici.
      // Vous devrez vérifier les définitions de HomeScreen et AppBackground.
      // Si HomeScreen et AppBackground SONT const-constructibles, vous pouvez ajouter const ici.
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
