import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_products_screen.dart';
import 'services/firebase_auth_service.dart';
import 'constants/app_constants.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully');
  } catch (e) {
    developer.log('Error initializing Firebase: $e');
    // Continue to show the app with appropriate error handling
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arunalu Technics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthenticationWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/admin_users': (context) => const AdminUsersScreen(),
        '/admin_products': (context) => const AdminProductsScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = true;
  bool _isAdmin = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final user = _authService.currentUser;
      if (user != null) {
        developer.log('User is already signed in: ${user.email}');
        
        // Check if the user is an admin (by email or role)
        if (user.email?.toLowerCase() == FirebaseAuthService.adminEmail) {
          developer.log('Admin user detected by email');
          _isAdmin = true;
        } else {
          _isAdmin = await _authService.isCurrentUserAdmin();
          developer.log('Admin check result: $_isAdmin');
        }
        
        // Update last login time
        await _authService.updateLastLogin(user.uid);
        developer.log('Last login time updated');
        
        // Ensure admin role if needed
        if (_isAdmin && user.email?.toLowerCase() == FirebaseAuthService.adminEmail) {
          await _authService.signInWithEmailAndPassword(
            FirebaseAuthService.adminEmail,
            FirebaseAuthService.adminPassword,
          );
          developer.log('Admin role refreshed');
        }
      } else {
        developer.log('No user is currently signed in');
      }
    } catch (e) {
      developer.log('Error checking authentication: $e');
      _errorMessage = 'Authentication error: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'AT',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'ARUNALU',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'TECHNICS',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CircularProgressIndicator(color: AppConstants.primaryColor),
            ],
          ),
        ),
      );
    }

    // If there's an error during initialization
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                const Text('An error occurred', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_errorMessage, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginScreen())
                  ),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // If stream is still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryColor,
              ),
            ),
          );
        }
        
        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // If admin, go to admin dashboard
          if (_isAdmin) {
            developer.log('Routing to admin dashboard');
            return const AdminDashboard();
          }
          
          // Otherwise, go to normal home screen
          developer.log('Routing to normal home screen');
          return const HomeScreen();
        }
        
        // User is not logged in
        developer.log('No user logged in, routing to login screen');
        return const LoginScreen();
      },
    );
  }
}
