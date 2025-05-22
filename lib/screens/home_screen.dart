import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/firebase_auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  int _selectedIndex = 0;
  int _currentBannerIndex = 2;
  String _username = 'User';
  Map<int, bool> _favoriteItems = {};
  
  final List<String> _categories = [
    'All', 'TV Accessories', 'Phone Parts', 'Cables', 'Tools', 'Electronics'
  ];
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserProfile();
    if (userData != null && mounted) {
      setState(() {
        _username = userData['firstName'] as String? ?? 'User';
      });
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
      body: SingleChildScrollView(
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
            SizedBox(
              height: 200,
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemCount: 5, // Multiple promotions
                itemBuilder: (context, index) {
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
                                          '${70 - index * 10}%',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 50,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'OFF',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          index == 0 ? 'SPECIAL OFFER' : 'LIMITED TIME',
                                          style: TextStyle(
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
                                        'https://img.freepik.com/free-photo/pretty-young-stylish-sexy-woman-pink-luxury-dress-summer-fashion-trend-chic-style-sunglasses-blue-studio-background-shopping-holding-paper-bags-talking-mobile-phone-shopaholic_285396-2957.jpg',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.amber,
                                            child: Center(
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
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
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
            ),
            
            // Banner indicator
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
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
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _categories.length,
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
                          _categories[index],
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
            ),

            const SizedBox(height: 24),

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
            
            // Popular Products (Horizontal scroll)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
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
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildProductCard(
                      id: index + 10,
                      name: _getProductName(index),
                      price: 'Rs ${(index + 1) * 500}',
                      imageUrl: _getProductImage(index),
                      bgColor: index % 2 == 0 ? Colors.blue[50] : Colors.grey[200],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Spare parts section
            Padding(
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
                  
                  // Product grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildProductCard(
                          id: 1,
                          name: 'ACF Blue Glue',
                          price: 'Rs 1500',
                          imageUrl: 'https://m.media-amazon.com/images/I/71zZiICGnsL._SL1500_.jpg',
                          bgColor: Colors.blue[50],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildProductCard(
                          id: 2,
                          name: 'PEO TV Remote',
                          price: 'Rs 500',
                          imageUrl: 'https://m.media-amazon.com/images/I/61IMRs+o0iL._AC_UF1000,1000_QL80_.jpg',
                          bgColor: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProductCard(
                          id: 3,
                          name: 'HDMI Cable',
                          price: 'Rs 800',
                          imageUrl: 'https://m.media-amazon.com/images/I/61vBpR+rKSL._AC_UF894,1000_QL80_.jpg',
                          bgColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildProductCard(
                          id: 4,
                          name: 'USB-C Adapter',
                          price: 'Rs 1200',
                          imageUrl: 'https://m.media-amazon.com/images/I/61OJ+1-0gEL._AC_UF894,1000_QL80_.jpg',
                          bgColor: Colors.blue[50],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Services section
            Container(
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
                    children: [
                      _buildServiceItem(Icons.build, 'Repairs'),
                      _buildServiceItem(Icons.electrical_services, 'Installation'),
                      _buildServiceItem(Icons.miscellaneous_services, 'Maintenance'),
                      _buildServiceItem(Icons.home_repair_service, 'Consultation'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
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
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getProductName(int index) {
    List<String> names = [
      'Wifi Router',
      'HDMI Splitter',
      'Power Bank',
      'Smart Remote',
      'USB Hub',
    ];
    return names[index % names.length];
  }

  String _getProductImage(int index) {
    List<String> images = [
      'https://m.media-amazon.com/images/I/61gYRGY1K1L._AC_UF1000,1000_QL80_.jpg',
      'https://m.media-amazon.com/images/I/71+-M5AJYUL._AC_UF1000,1000_QL80_.jpg',
      'https://m.media-amazon.com/images/I/61JPre0eclL._AC_UF894,1000_QL80_.jpg',
      'https://m.media-amazon.com/images/I/61+WMsDAUPL._AC_UF894,1000_QL80_.jpg',
      'https://m.media-amazon.com/images/I/71YzF+8HYHL._AC_UF894,1000_QL80_.jpg',
    ];
    return images[index % images.length];
  }

  Widget _socialButton(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
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
    required int id,
    required String name,
    required String price,
    required String imageUrl,
    Color? bgColor,
  }) {
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