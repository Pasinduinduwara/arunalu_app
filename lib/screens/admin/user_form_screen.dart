import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';
import '../../constants/app_constants.dart';

class UserFormScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Function(Map<String, dynamic>) onUserSaved;

  const UserFormScreen({
    Key? key,
    this.user,
    required this.onUserSaved,
  }) : super(key: key);

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isAdmin = false;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.user != null;
    
    if (_isEditMode) {
      // Populate form with existing user data
      _firstNameController.text = widget.user!['firstName'] as String? ?? '';
      _lastNameController.text = widget.user!['lastName'] as String? ?? '';
      _emailController.text = widget.user!['email'] as String? ?? '';
      _isAdmin = (widget.user!['role'] as String?) == 'admin';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isEditMode) {
        // Update existing user
        final userData = {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'fullName': '${_firstNameController.text} ${_lastNameController.text}',
          'role': _isAdmin ? 'admin' : 'user',
        };

        await _authService.updateUser(widget.user!['id'] as String, userData);
        
        // Update the widget's callback with updated user
        final updatedUser = Map<String, dynamic>.from(widget.user!);
        updatedUser.addAll(userData);
        
        if (mounted) {
          widget.onUserSaved(updatedUser);
          Navigator.of(context).pop();
        }
      } else {
        // Create new user
        final userCredential = await _authService.createUserWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
          _firstNameController.text,
          _lastNameController.text,
          role: _isAdmin ? 'admin' : 'user',
        );
        
        if (userCredential.user != null) {
          // Get the created user data
          final userData = {
            'id': userCredential.user!.uid,
            'email': _emailController.text,
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'fullName': '${_firstNameController.text} ${_lastNameController.text}',
            'role': _isAdmin ? 'admin' : 'user',
          };
          
          if (mounted) {
            widget.onUserSaved(userData);
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit User' : 'Add New User'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email - readonly in edit mode
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                readOnly: _isEditMode,
                enabled: !_isEditMode,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password - only for new users
              if (!_isEditMode)
                Column(
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password *',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              
              // Admin checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isAdmin,
                    onChanged: (value) {
                      setState(() {
                        _isAdmin = value ?? false;
                      });
                    },
                    activeColor: AppConstants.primaryColor,
                  ),
                  const Text('Admin User'),
                ],
              ),
              const SizedBox(height: 24),
              
              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditMode ? 'Update User' : 'Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 