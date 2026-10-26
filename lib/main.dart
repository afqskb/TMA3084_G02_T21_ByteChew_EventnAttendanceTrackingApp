
import 'package:event_tracking_app/screens/wrapper.dart';
import 'package:event_tracking_app/services/auth.dart';
import 'package:event_tracking_app/services/theme_service.dart';
import 'package:event_tracking_app/shared/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:event_tracking_app/models/app_user.dart';
import 'package:logger/logger.dart';

void main() async {
  final logger = Logger();

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    logger.d('Firebase initialized successfully!');
  } catch (e) {
    logger.d('Firebase initialization error: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService()..loadTheme(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
      value: AuthService().user.map(
        (firebaseUser) => firebaseUser == null
            ? null
            : AppUser(uid: firebaseUser.uid),
      ),
      initialData: null,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: themeService.themeMode,
            home: Wrapper(),
          );
        },
      ),
    );
  }
}
