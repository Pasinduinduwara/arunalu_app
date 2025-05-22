import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/social_login_button.dart';
import '../services/firebase_auth_service.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      try {
        await _authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
        );
        
        if (!mounted) return;
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to home screen
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
                const SizedBox(height: 30),
                // Signup text
                const Text(
                  'Sign Up Your Account',
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
                
                // First Name field
                CustomInputField(
                  hint: 'First name',
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                // Last Name field
                CustomInputField(
                  hint: 'Last name',
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                // Email field
                CustomInputField(
                  hint: 'Enter email address',
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
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                // Confirm Password field
                CustomInputField(
                  hint: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  isRequired: true,
                ),
                const SizedBox(height: 24),
                // Sign up button
                CustomButton(
                  text: 'Sign Up',
                  isLoading: _isLoading,
                  onPressed: _handleSignup,
                ),
                const SizedBox(height: 20),
                // Or sign up with
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
              ],
            ),
          ),
        ),
      ),
    );
  }
} 