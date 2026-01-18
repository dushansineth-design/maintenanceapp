import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart'; //  REQUIRED
import 'models/citizen.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';

void main() async {
  // 1. Setup Flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Check saved login data
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String savedName = prefs.getString('userName') ?? 'User';
  final String savedEmail = prefs.getString('userEmail') ?? '';

  // 4. Decide which screen to show first
  Widget firstScreen;

  if (isLoggedIn && savedEmail.isNotEmpty) {
    // Recreate the user from saved info
    Citizen savedUser = Citizen(
      name: savedName,
      contact: '0771234567', // You can later load this from Firestore
      email: savedEmail,
    );
    firstScreen = HomePage(currentUser: savedUser);
  } else {
    firstScreen = const LoginPage();
  }

  // 5. Run the app
  runApp(MyApp(startScreen: firstScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maintenance App',
      home: startScreen,
    );
  }
}
