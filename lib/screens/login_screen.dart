import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/social_login_button.dart';
import '../services/firebase_auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'admin/admin_dashboard.dart';
import 'forgot_password_screen.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // For testing admin access, uncomment these lines:
    // _emailController.text = FirebaseAuthService.adminEmail;
    // _passwordController.text = FirebaseAuthService.adminPassword;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    // Check if this is direct admin login with hardcoded credentials
    if (_emailController.text.trim().toLowerCase() == FirebaseAuthService.adminEmail &&
        _passwordController.text == FirebaseAuthService.adminPassword) {
      try {
        developer.log('Admin login attempt with hardcoded credentials');
        final userCredential = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (mounted) {
          developer.log('Admin login successful, navigating to admin dashboard');
          // Navigate directly to admin dashboard
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const AdminDashboard())
          );
        }
        return;
      } catch (e) {
        developer.log('Error during admin login, attempting admin account creation', error: e);
        // If admin login fails (first time), try to create the admin account
        try {
          await _authService.createUserWithEmailAndPassword(
            FirebaseAuthService.adminEmail,
            FirebaseAuthService.adminPassword,
            'Admin',
            'User',
            role: 'admin',
          );
          
          if (mounted) {
            developer.log('Admin account created, now logging in');
            await _authService.signInWithEmailAndPassword(
              FirebaseAuthService.adminEmail,
              FirebaseAuthService.adminPassword,
            );
            
            if (mounted) {
              developer.log('Admin login successful after account creation');
              // Navigate to admin dashboard
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const AdminDashboard())
              );
            }
          }
          return;
        } catch (createError) {
          developer.log('Failed to create admin account', error: createError);
          // Continue to regular error handling
        }
      }
    }
    
    // Regular login flow
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        // Check if user is admin based on Firestore role
        final isAdmin = await _authService.isCurrentUserAdmin();
        
        if (isAdmin) {
          developer.log('User is admin, navigating to admin dashboard');
          // Navigate to Admin Dashboard
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const AdminDashboard())
          );
        } else {
          developer.log('Regular user login, navigating to home screen');
          // Regular user - navigate to home screen
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred during login';
        _isLoading = false;
      });
      developer.log('Firebase Auth Exception during login', error: e);
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
      developer.log('Unexpected error during login', error: e);
    }
  }

  void _handleForgotPassword() {    
    // Navigate to forgot password screen    
    Navigator.pushNamed(context, '/forgot_password');  
  }

  void _navigateToSignup() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Logo
                Text(
                  'AT',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'ARUNALU TECHNICS',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                // Login text
                const Text(
                  'Log in to your Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Error message display
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Email field
                CustomInputField(
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                // Password field
                CustomInputField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  isRequired: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Login button
                CustomButton(
                  text: 'Sign in',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 30),
                // Or sign in with
                const Text(
                  '-or sign in with-',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialLoginButton(
                      type: SocialLoginType.facebook,
                      onPressed: () {
                        // Facebook login to be implemented later
                      },
                    ),
                    const SizedBox(width: 20),
                    SocialLoginButton(
                      type: SocialLoginType.apple,
                      onPressed: () {
                        // Apple login to be implemented later
                      },
                    ),
                    const SizedBox(width: 20),
                    SocialLoginButton(
                      type: SocialLoginType.google,
                      onPressed: () {
                        // Google login to be implemented later
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Don't have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Dont have an account?'),
                    TextButton(
                      onPressed: _navigateToSignup,
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Admin login hint
                const SizedBox(height: 5),
                Text(
                  'For admin access: admin@gmail.com / 123456789',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 