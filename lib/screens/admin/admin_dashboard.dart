import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/product_service.dart';
import '../../services/banner_service.dart';
import '../../services/category_service.dart';
import '../../services/appointment_service.dart';
import '../../services/service_service.dart';
import '../../widgets/admin_drawer.dart';
import '../../widgets/stats_card.dart';
import 'admin_users_screen.dart';
import 'admin_products_screen.dart';
import 'admin_banners_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_appointment_types_screen.dart';
import 'admin_services_screen.dart';
import 'dart:developer' as developer;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ProductService _productService = ProductService();
  final BannerService _bannerService = BannerService();
  final CategoryService _categoryService = CategoryService();
  final AppointmentTypeService _appointmentTypeService = AppointmentTypeService();
  final ServiceService _serviceService = ServiceService();
  
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalProducts = 0;
  int _totalBanners = 0;
  int _totalCategories = 0;
  int _totalAppointmentTypes = 0;
  int _totalServices = 0;
  
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
      
      // Load user statistics
      final users = await _authService.getAllUsers();
      _totalUsers = users.length;
      
      // Load product statistics
      final products = await _productService.getAllProducts();
      _totalProducts = products.length;
      
      // Load banner statistics
      final banners = await _bannerService.getAllBanners();
      _totalBanners = banners.length;
      
      // Load category statistics
      final categories = await _categoryService.getAllCategories();
      _totalCategories = categories.length;
      
      // Load appointment type statistics
      final appointmentTypes = await _appointmentTypeService.getAllAppointmentTypes();
      _totalAppointmentTypes = appointmentTypes.length;
      
      // Load service statistics
      final services = await _serviceService.getAllServices();
      _totalServices = services.length;
      
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

  void _navigateToScreen(AdminScreen screen) {
    switch (screen) {
      case AdminScreen.users:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
        );
        break;
      case AdminScreen.products:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminProductsScreen()),
        );
        break;
      case AdminScreen.banners:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminBannersScreen()),
        );
        break;
      case AdminScreen.categories:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminCategoriesScreen()),
        );
        break;
      case AdminScreen.appointmentTypes:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminAppointmentTypesScreen()),
        );
        break;
      case AdminScreen.services:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminServicesScreen()),
        );
        break;
      default:
        // Do nothing for dashboard
        break;
    }
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
                  
                  // Stats grid - top row
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Total Users',
                          value: _totalUsers.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                          onTap: () => _navigateToScreen(AdminScreen.users),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: 'Total Products',
                          value: _totalProducts.toString(),
                          icon: Icons.inventory,
                          color: Colors.orange,
                          onTap: () => _navigateToScreen(AdminScreen.products),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats grid - middle row
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Banners & Offers',
                          value: _totalBanners.toString(),
                          icon: Icons.collections,
                          color: Colors.purple,
                          onTap: () => _navigateToScreen(AdminScreen.banners),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: 'Categories',
                          value: _totalCategories.toString(),
                          icon: Icons.category,
                          color: Colors.green,
                          onTap: () => _navigateToScreen(AdminScreen.categories),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats grid - bottom row
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Appointment Types',
                          value: _totalAppointmentTypes.toString(),
                          icon: Icons.calendar_today,
                          color: Colors.red,
                          onTap: () => _navigateToScreen(AdminScreen.appointmentTypes),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: 'Services',
                          value: _totalServices.toString(),
                          icon: Icons.miscellaneous_services,
                          color: Colors.teal,
                          onTap: () => _navigateToScreen(AdminScreen.services),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Quick access section
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
                    onTap: () => _navigateToScreen(AdminScreen.users),
                  ),
                  const SizedBox(height: 16),
                  
                  // Product Management
                  _buildQuickAccessCard(
                    title: 'Product Management',
                    description: 'Manage your product catalog',
                    icon: Icons.inventory,
                    color: Colors.orange,
                    onTap: () => _navigateToScreen(AdminScreen.products),
                  ),
                  const SizedBox(height: 16),
                  
                  // Banner Management
                  _buildQuickAccessCard(
                    title: 'Banner Management',
                    description: 'Manage promotional banners and offers',
                    icon: Icons.collections,
                    color: Colors.purple,
                    onTap: () => _navigateToScreen(AdminScreen.banners),
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