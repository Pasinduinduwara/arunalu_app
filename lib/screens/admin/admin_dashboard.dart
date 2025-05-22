import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../services/firebase_auth_service.dart';
import '../../widgets/admin_drawer.dart';
import '../../widgets/stats_card.dart';
import 'admin_users_screen.dart';
import 'admin_products_screen.dart';
import 'dart:developer' as developer;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalProducts = 0;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Load dashboard statistics
      final users = await _authService.getAllUsers();
      _totalUsers = users.length;
      
      // Mock product count for now - this would come from the ProductService
      _totalProducts = 12;
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading dashboard data', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
    );
  }

  void _navigateToProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminProductsScreen()),
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      developer.log('Error signing out', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      drawer: const AdminDrawer(currentScreen: AdminScreen.dashboard),
      body: _isLoading 
        ? Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Admin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Manage your application from here',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Total Users',
                          value: _totalUsers.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                          onTap: _navigateToUsers,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: 'Total Products',
                          value: _totalProducts.toString(),
                          icon: Icons.inventory,
                          color: Colors.orange,
                          onTap: _navigateToProducts,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Management cards
                  const Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // User Management
                  _buildQuickAccessCard(
                    title: 'User Management',
                    description: 'Add, edit or delete users',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: _navigateToUsers,
                  ),
                  const SizedBox(height: 16),
                  
                  // Product Management
                  _buildQuickAccessCard(
                    title: 'Product Management',
                    description: 'Manage your product catalog',
                    icon: Icons.inventory,
                    color: Colors.orange,
                    onTap: _navigateToProducts,
                  ),
                ],
              ),
            ),
          ),
    );
  }
  
  Widget _buildQuickAccessCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
} 