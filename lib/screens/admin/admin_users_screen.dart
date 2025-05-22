import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';
import '../../constants/app_constants.dart';
import 'user_form_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _authService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _applySearch(); // Initialize filtered users
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_users);
    } else {
      final lowercaseQuery = _searchQuery.toLowerCase();
      _filteredUsers = _users.where((user) {
        final email = (user['email'] as String?)?.toLowerCase() ?? '';
        final firstName = (user['firstName'] as String?)?.toLowerCase() ?? '';
        final lastName = (user['lastName'] as String?)?.toLowerCase() ?? '';
        final fullName = (user['fullName'] as String?)?.toLowerCase() ?? '';

        return email.contains(lowercaseQuery) || 
               firstName.contains(lowercaseQuery) || 
               lastName.contains(lowercaseQuery) ||
               fullName.contains(lowercaseQuery);
      }).toList();
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applySearch();
    });
  }

  Future<void> _deleteUser(String userId, String userEmail) async {
    // Prevent deletion of admin account
    if (userEmail.toLowerCase() == FirebaseAuthService.adminEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete admin account')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete user $userEmail?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.deleteUser(userId);
      _loadUsers(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }

  void _editUser(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(
          user: user,
          onUserSaved: (updatedUser) {
            _loadUsers(); // Refresh user list
          },
        ),
      ),
    );
  }

  void _addNewUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(
          onUserSaved: (_) {
            _loadUsers(); // Refresh user list
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final isAdmin = (user['role'] as String?) == 'admin';
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAdmin
                                    ? Colors.amber
                                    : AppConstants.primaryColor,
                                child: Text(
                                  (user['firstName'] as String? ?? '')
                                          .isNotEmpty
                                      ? (user['firstName'] as String)[0]
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(user['fullName'] as String? ?? 'N/A'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user['email'] as String? ?? 'No email'),
                                  if (isAdmin)
                                    const Text(
                                      'Admin',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editUser(user),
                                    color: Colors.blue,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteUser(
                                      user['id'] as String,
                                      user['email'] as String,
                                    ),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                              isThreeLine: isAdmin,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewUser,
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
} 