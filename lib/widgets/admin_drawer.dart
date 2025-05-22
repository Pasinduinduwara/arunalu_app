import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/firebase_auth_service.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_products_screen.dart';

enum AdminScreen {
  dashboard,
  users,
  products,
  banners,
  categories,
  appointmentTypes,
  services
}

class AdminDrawer extends StatelessWidget {
  final AdminScreen currentScreen;
  
  const AdminDrawer({
    Key? key,
    required this.currentScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Admin header
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Admin Panel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Arunalu Technics',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  FirebaseAuthService.adminEmail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Dashboard
          _buildDrawerItem(
            context: context,
            title: 'Dashboard',
            icon: Icons.dashboard,
            isSelected: currentScreen == AdminScreen.dashboard,
            onTap: () {
              if (currentScreen != AdminScreen.dashboard) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AdminDashboard()),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          
          // Users
          _buildDrawerItem(
            context: context,
            title: 'User Management',
            icon: Icons.people,
            isSelected: currentScreen == AdminScreen.users,
            onTap: () {
              if (currentScreen != AdminScreen.users) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          
          // Products
          _buildDrawerItem(
            context: context,
            title: 'Product Management',
            icon: Icons.inventory,
            isSelected: currentScreen == AdminScreen.products,
            onTap: () {
              if (currentScreen != AdminScreen.products) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AdminProductsScreen()),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          
          // Banners
          _buildDrawerItem(
            context: context,
            title: 'Banners/Offers',
            icon: Icons.collections,
            isSelected: currentScreen == AdminScreen.banners,
            onTap: () {
              if (currentScreen != AdminScreen.banners) {
                Navigator.of(context).pushReplacementNamed('/admin/banners');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          
          // Categories
          _buildDrawerItem(
            context: context,
            title: 'Categories',
            icon: Icons.category,
            isSelected: currentScreen == AdminScreen.categories,
            onTap: () {
              if (currentScreen != AdminScreen.categories) {
                Navigator.of(context).pushReplacementNamed('/admin/categories');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          
          // Appointment Types
          _buildDrawerItem(
            context: context,
            title: 'Appointment Types',
            icon: Icons.calendar_today,
            isSelected: currentScreen == AdminScreen.appointmentTypes,
            onTap: () {
              if (currentScreen != AdminScreen.appointmentTypes) {
                Navigator.of(context).pushReplacementNamed('/admin/appointment-types');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          
          // Services
          _buildDrawerItem(
            context: context,
            title: 'Services',
            icon: Icons.miscellaneous_services,
            isSelected: currentScreen == AdminScreen.services,
            onTap: () {
              if (currentScreen != AdminScreen.services) {
                Navigator.of(context).pushReplacementNamed('/admin/services');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          
          const Spacer(),
          
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final authService = FirebaseAuthService();
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppConstants.primaryColor : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppConstants.primaryColor : Colors.grey[900],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
            )
          : null,
      onTap: onTap,
      selected: isSelected,
    );
  }
} 