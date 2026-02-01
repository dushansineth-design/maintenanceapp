import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/citizen.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'theme/app_theme.dart';

void main() async {
  // 1. Setup Flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Check saved data
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String savedName = prefs.getString('userName') ?? 'User';
  final String savedEmail = prefs.getString('userEmail') ?? '';

  // 3. Decide which screen to show first
  Widget firstScreen;
  
  if (isLoggedIn) {
    // Recreate the user from saved info
    Citizen savedUser = Citizen(
      name: savedName, 
      contact: '0771234567', // Hardcoded for now
      email: savedEmail
    );
    firstScreen = HomePage(currentUser: savedUser);
  } else {
    firstScreen = const LoginPage();
  }

  // 4. Run the app with the correct screen
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
      theme: AppTheme.lightTheme, // <--- New Theme Applied
      home: startScreen, 
    );
  }
}