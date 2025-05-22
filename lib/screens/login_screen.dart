import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/social_login_button.dart';
import '../services/firebase_auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

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
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      try {
        final userCredential = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        // Update last login time in Firestore
        if (userCredential.user != null) {
          await _authService.updateLastLogin(userCredential.user!.uid);
        }
        
        if (!mounted) return;
        
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email to reset password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  isRequired: true,
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
                      onPressed: () {
                        Navigator.of(context).pushNamed('/signup');
                      },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
} 