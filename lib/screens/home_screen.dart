import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserProfile();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSignOut() async {
    await _authService.signOut();
    if (!mounted) return;
    
    // Navigate back to the login screen
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/technician.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // User profile section
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userData != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // User info card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserInfoRow('Name', _userData?['fullName'] ?? 'N/A'),
                              const Divider(),
                              _buildUserInfoRow('Email', _userData?['email'] ?? 'N/A'),
                              const Divider(),
                              _buildUserInfoRow('First Name', _userData?['firstName'] ?? 'N/A'),
                              const Divider(),
                              _buildUserInfoRow('Last Name', _userData?['lastName'] ?? 'N/A'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Bottom button
                        CustomButton(
                          text: 'Get Started',
                          onPressed: () {
                            // Navigate to main features
                          },
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Failed to load user data',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
} 