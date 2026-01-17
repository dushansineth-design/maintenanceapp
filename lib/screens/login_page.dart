import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import '../models/citizen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Define the Palette Colors locally for easy use
  final Color bgBlack = const Color(0xFF121212);
  final Color bgSurface = const Color(0xFF1E1E2C);
  final Color accentPurple = const Color(0xFF6C63FF);

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Hardcoded check
    if (email == "user@gmail.com" && password == "1234") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', 'Dushan'); 
      await prefs.setString('userEmail', email);

      Citizen currentUser = Citizen(
          name: 'User', 
          contact: '0771234567', 
          email: email
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(currentUser: currentUser)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Invalid: dushan@gmail.com / 1234"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack, // Dark Background
      appBar: AppBar(
        title: const Text("Welcome to Maintenance App", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.lock_outline, size: 80, color: Color(0xFF6C63FF)),
            ),
            const SizedBox(height: 40),
            
            // Email Field
            const Text("Email Address", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Enter your email"),
            ),
            
            const SizedBox(height: 20),
            
            // Password Field
            const Text("Password", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Enter your password"),
            ),
            
            const SizedBox(height: 40),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPurple, // Purple Button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Login", 
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Dark Input Style
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: bgSurface, // Dark Grey Input Background
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}