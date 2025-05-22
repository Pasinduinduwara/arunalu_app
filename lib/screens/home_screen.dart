import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/firebase_auth_service.dart';
import '../services/banner_service.dart';
import '../services/category_service.dart';
import '../services/appointment_service.dart';
import '../services/service_service.dart';
import '../services/product_service.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';
import 'dart:developer' as developer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final BannerService _bannerService = BannerService();
  final CategoryService _categoryService = CategoryService();
  final AppointmentTypeService _appointmentTypeService = AppointmentTypeService();
  final ServiceService _serviceService = ServiceService();
  final ProductService _productService = ProductService();
  
  int _selectedIndex = 0;
  int _currentBannerIndex = 0;
  String _username = 'User';
  Map<int, bool> _favoriteItems = {};
  
  // Dynamic data
  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  List<Map<String, dynamic>> _popularProducts = [];
  List<Map<String, dynamic>> _sparePartsProducts = [];
  List<ServiceModel> _services = [];
  
  // Replace the hardcoded categories list with a getter
  List<String> get _categoryNames => 
      ['All', ..._categories.map((c) => c.name)];
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadHomePageData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserProfile();
    if (userData != null && mounted) {
      setState(() {
        _username = userData['firstName'] as String? ?? 'User';
      });
    }
  }
  
  // Add this method to load all home page data
  Future<void> _loadHomePageData() async {
    try {
      // Load banners
      final banners = await _bannerService.getAllBanners(activeOnly: true);
      
      // Load categories
      final categories = await _categoryService.getAllCategories(activeOnly: true);
      
      // Load products
      final allProducts = await _productService.getAllProducts();
      
      // Load services
      final services = await _serviceService.getAllServices(activeOnly: true);
      
      if (mounted) {
        setState(() {
          _banners = banners;
          _categories = categories;
          
          // Filter products for popular and spare parts sections
          _popularProducts = allProducts.take(5).toList();
          _sparePartsProducts = allProducts.skip(5).take(4).toList();
          
          _services = services;
          
          // Reset current banner index if needed
          if (_currentBannerIndex >= _banners.length && _banners.isNotEmpty) {
            _currentBannerIndex = 0;
          }
        });
      }
    } catch (e) {
      developer.log('Error loading home page data', error: e);
    }
  }

  void _toggleFavorite(int productId) {
    setState(() {
      _favoriteItems[productId] = !(_favoriteItems[productId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              Text(
                'AT',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ARUNALU',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'TECHNICS',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            color: Colors.black,
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            color: Colors.black,
            onPressed: () {
              // Handle notification action
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHomePageData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Welcome Back, $_username',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              
              // Banner slider
              _buildBannerSlider(),
              
              // Banner indicator
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_banners.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentBannerIndex == index 
                          ? AppConstants.primaryColor
                          : Colors.grey[300],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
  
              // Categories
              if (_categories.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCategoriesSection(),
                const SizedBox(height: 24),
              ],
  
              // Appointments section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: Text(
                                'Normal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: Text(
                                'Emergency',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Popular Products
              _buildPopularProductsSection(),
              const SizedBox(height: 24),
              
              // Spare parts section
              _buildSparePartsSection(),
              const SizedBox(height: 24),
  
              // Services section
              _buildServicesSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF00257E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(.6),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Update the banner slider
  Widget _buildBannerSlider() {
    if (_banners.isEmpty) {
      // Default banner if none are available
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No promotions available'),
        ),
      );
    }
    
    return SizedBox(
      height: 200,
      child: PageView.builder(
        onPageChanged: (index) {
          setState(() {
            _currentBannerIndex = index;
          });
        },
        itemCount: _banners.length,
        itemBuilder: (context, index) {
          final banner = _banners[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        // Left content part (text)
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Colors.black,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${banner.discountPercentage}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  banner.subtitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _socialButton(Icons.switch_access_shortcut),
                                    const SizedBox(width: 8),
                                    _socialButton(Icons.facebook),
                                    const SizedBox(width: 8),
                                    _socialButton(Icons.camera_alt_outlined),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right content part (image)
                        Expanded(
                          flex: 4,
                          child: Stack(
                            children: [
                              Image.network(
                                banner.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.amber,
                                    child: const Center(
                                      child: Text('SHOP ONLINE'),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'SHOP',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          'ONLINE',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Yellow dots for decoration
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 120,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      right: 140,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Update the categories section
  Widget _buildCategoriesSection() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _categoryNames.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppConstants.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _categoryNames[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Update the popular products section
  Widget _buildPopularProductsSection() {
    if (_popularProducts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            'Popular Products',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0, right: 8.0),
            itemCount: _popularProducts.length,
            itemBuilder: (context, index) {
              final product = _popularProducts[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 16),
                child: _buildProductCard(
                  id: product['id'] ?? index.toString(),
                  name: product['title'] ?? 'Product',
                  price: 'Rs ${product['price'] ?? '0'}',
                  imageUrl: product['imageUrl'] ?? '',
                  bgColor: index % 2 == 0 ? Colors.blue[50] : Colors.grey[200],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Update the spare parts section
  Widget _buildSparePartsSection() {
    if (_sparePartsProducts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spare Parts For You',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // First row
          if (_sparePartsProducts.length >= 2)
            Row(
              children: [
                Expanded(
                  child: _buildProductCard(
                    id: _sparePartsProducts[0]['id'] ?? '1',
                    name: _sparePartsProducts[0]['title'] ?? 'Product',
                    price: 'Rs ${_sparePartsProducts[0]['price'] ?? '0'}',
                    imageUrl: _sparePartsProducts[0]['imageUrl'] ?? '',
                    bgColor: Colors.blue[50],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProductCard(
                    id: _sparePartsProducts[1]['id'] ?? '2',
                    name: _sparePartsProducts[1]['title'] ?? 'Product',
                    price: 'Rs ${_sparePartsProducts[1]['price'] ?? '0'}',
                    imageUrl: _sparePartsProducts[1]['imageUrl'] ?? '',
                    bgColor: Colors.grey[200],
                  ),
                ),
              ],
            ),
          
          // Second row
          if (_sparePartsProducts.length >= 4)
            Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildProductCard(
                        id: _sparePartsProducts[2]['id'] ?? '3',
                        name: _sparePartsProducts[2]['title'] ?? 'Product',
                        price: 'Rs ${_sparePartsProducts[2]['price'] ?? '0'}',
                        imageUrl: _sparePartsProducts[2]['imageUrl'] ?? '',
                        bgColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProductCard(
                        id: _sparePartsProducts[3]['id'] ?? '4',
                        name: _sparePartsProducts[3]['title'] ?? 'Product',
                        price: 'Rs ${_sparePartsProducts[3]['price'] ?? '0'}',
                        imageUrl: _sparePartsProducts[3]['imageUrl'] ?? '',
                        bgColor: Colors.blue[50],
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  // Update the services section
  Widget _buildServicesSection() {
    if (_services.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Services',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _services
                .take(4)
                .map((service) => _buildServiceItem(
                      _serviceService.getIconDataFromName(service.iconName),
                      service.name,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, size: 28, color: AppConstants.primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _socialButton(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required dynamic id,
    required String name,
    required String price,
    required String imageUrl,
    Color? bgColor,
  }) {
    final productId = id is String ? id : id.toString();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bgColor ?? Colors.grey[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image, size: 50)),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => _toggleFavorite(id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _favoriteItems[id] == true 
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _favoriteItems[id] == true ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 