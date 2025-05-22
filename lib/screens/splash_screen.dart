import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../services/firebase_auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    // Add a delay before checking authentication and navigating
    Timer(const Duration(seconds: 2), () {
      _checkAuthentication();
    });
  }

  void _checkAuthentication() {
    // Check if user is already logged in
    final currentUser = _authService.currentUser;
    
    if (!mounted) return;

    if (currentUser != null) {
      // User is logged in, navigate to home screen
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // User is not logged in, navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Text(
              'AT',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'ARUNALU TECHNICS',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 16,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 