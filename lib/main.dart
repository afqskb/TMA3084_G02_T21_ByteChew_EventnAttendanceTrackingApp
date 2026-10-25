//import 'package:event_tracking_app/screens/authenticate/sign_in.dart';
import 'package:event_tracking_app/screens/wrapper.dart';
import 'package:event_tracking_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:event_tracking_app/models/app_user.dart';
import 'package:logger/logger.dart';

void main() async {

  final logger = Logger();

  WidgetsFlutterBinding.ensureInitialized();
  try {
    // If you used 'flutterfire configure', use this:
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    
    // Otherwise, try standard init:
    await Firebase.initializeApp();
    
    logger.d("Firebase initialized successfully!");
  } catch (e) {
    logger.d("Firebase initialization error: $e");
  }



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
