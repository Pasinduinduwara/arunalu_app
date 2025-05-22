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

// Import the offline demo mode constant
import '../main.dart';

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
  Map<String, bool> _favoriteItems = {};
  
  // Dynamic data
  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  List<Map<String, dynamic>> _popularProducts = [];
  List<Map<String, dynamic>> _sparePartsProducts = [];
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Replace the hardcoded categories list with a getter
  List<String> get _categoryNames => 
      ['All', ..._categories.map((c) => c.name)];
  int _selectedCategory = 0;
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    developer.log('HomeScreen: USE_OFFLINE_DEMO_MODE = $USE_OFFLINE_DEMO_MODE');
    
    // If in offline demo mode, use demo data immediately
    if (USE_OFFLINE_DEMO_MODE) {
      developer.log('HomeScreen: Using offline demo mode');
      _createDemoData();
      setState(() {
        _isLoading = false;
      });
    } else {
      // Otherwise load data from Firebase
      developer.log('HomeScreen: Attempting to load data from Firebase');
      _loadHomePageData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserProfile();
      if (userData != null && mounted) {
        setState(() {
          _username = userData['firstName'] as String? ?? 'User';
        });
      }
    } catch (e) {
      developer.log('HomeScreen: Error loading user data', error: e);
      // Use default username
    }
  }
  
  // Add this method to create fallback demo data
  void _createDemoData() {
    developer.log('HomeScreen: Creating demo data for display');
    
    // Create demo banners
    _banners = [
      BannerModel(
        id: 'demo1',
        title: 'Special Offer',
        subtitle: 'Get 20% off on all appliance repairs this week',
        imageUrl: 'https://placehold.co/800x400/orange/white?text=Special+Offer',
        discountPercentage: 20,
      ),
      BannerModel(
        id: 'demo2',
        title: 'New Arrivals',
        subtitle: 'Check out our latest products and tools',
        imageUrl: 'https://placehold.co/800x400/blue/white?text=New+Arrivals',
        discountPercentage: 15,
      ),
    ];
    
    // Create demo categories
    _categories = [
      CategoryModel(id: "cat1", name: "Electronics"),
      CategoryModel(id: "cat2", name: "Appliances"),
      CategoryModel(id: "cat3", name: "Tools"),
      CategoryModel(id: "cat4", name: "Spare Parts"),
    ];
    
    // Create demo products with categories
    _popularProducts = [
      {
        "id": "prod1", 
        "title": "Digital Multimeter", 
        "price": "1200",
        "category": "Electronics",
        "imageUrl": "https://placehold.co/400x400/blue/white?text=Multimeter"
      },
      {
        "id": "prod2", 
        "title": "Soldering Iron Kit", 
        "price": "2500",
        "category": "Electronics",
        "imageUrl": "https://placehold.co/400x400/blue/white?text=Soldering+Kit"
      },
      {
        "id": "prod3", 
        "title": "Electric Drill", 
        "price": "4500",
        "category": "Tools",
        "imageUrl": "https://placehold.co/400x400/blue/white?text=Drill"
      },
    ];
    
    // Create demo spare parts with categories
    _sparePartsProducts = [
      {
        "id": "spare1", 
        "title": "Fan Motor", 
        "price": "1800",
        "category": "Spare Parts",
        "imageUrl": "https://placehold.co/400x400/gray/white?text=Fan+Motor"
      },
      {
        "id": "spare2", 
        "title": "Circuit Board", 
        "price": "3200",
        "category": "Spare Parts",
        "imageUrl": "https://placehold.co/400x400/gray/white?text=Circuit+Board"
      },
      {
        "id": "spare3", 
        "title": "Washing Machine Pump", 
        "price": "2500",
        "category": "Appliances",
        "imageUrl": "https://placehold.co/400x400/gray/white?text=Washing+Pump"
      },
    ];
    
    // Create demo services
    _services = [
      ServiceModel(id: "serv1", name: "Repair", description: "Repair service", iconName: "build"),
      ServiceModel(id: "serv2", name: "Installation", description: "Installation service", iconName: "settings"),
      ServiceModel(id: "serv3", name: "Maintenance", description: "Maintenance service", iconName: "engineering"),
      ServiceModel(id: "serv4", name: "Consultation", description: "Consultation service", iconName: "miscellaneous_services"),
    ];
    
    developer.log('HomeScreen: Demo data created successfully');
  }

  // Add this method to load all home page data
  Future<void> _loadHomePageData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      developer.log('HomeScreen: Starting to load home page data');
      
      // Load banners - fetch ALL banners first to debug
      developer.log('HomeScreen: Loading all banners');
      List<BannerModel> banners = [];
      List<BannerModel> allBanners = [];
      try {
        // First get ALL banners to see what's available
        allBanners = await _bannerService.getAllBanners(activeOnly: false);
        developer.log('HomeScreen: Found ${allBanners.length} total banners in database');
        
        // Log them all for debugging
        for (var b in allBanners) {
          developer.log('HomeScreen: Banner from DB - ID: ${b.id}, Title: ${b.title}, Active: ${b.isActive}');
        }
        
        if (allBanners.isNotEmpty) {
          // IMPORTANT: Show all banners regardless of isActive status for now
          setState(() {
            _banners = allBanners;
            _currentBannerIndex = 0; // Reset to first banner
          });
          developer.log('HomeScreen: Showing ALL ${allBanners.length} banners regardless of active status');
        } else {
          // Try getting active banners specifically (in case there's an issue with the previous query)
          banners = await _bannerService.getAllBanners(activeOnly: true);
          
          if (banners.isNotEmpty) {
            setState(() {
              _banners = banners;
              _currentBannerIndex = 0;
            });
            developer.log('HomeScreen: Successfully loaded ${banners.length} active banners');
          } else {
            developer.log('HomeScreen: No banners found in database');
            
            // Create a default banner if none exist
            setState(() {
              _banners = [
                BannerModel(
                  id: 'default',
                  title: 'Welcome to Arunalu Technics',
                  subtitle: 'Quality repair services for all your needs',
                  imageUrl: 'https://placehold.co/800x400/orange/white?text=Arunalu+Technics',
                  discountPercentage: 10,
                  isActive: true,
                ),
              ];
            });
            developer.log('HomeScreen: Created default banner since none found in database');
          }
        }
      } catch (e) {
        developer.log('HomeScreen: Error loading banners', error: e);
        // Continue with other data loading
      }
      
      // Load categories
      developer.log('HomeScreen: Loading categories');
      final categories = await _categoryService.getAllCategories(activeOnly: true);
      developer.log('HomeScreen: Successfully loaded ${categories.length} categories');
      
      // Load active products - use the enhanced method
      developer.log('HomeScreen: Loading active products');
      final activeProducts = await _productService.getActiveProducts();
      developer.log('HomeScreen: Successfully loaded ${activeProducts.length} active products');
      
      // Load featured products separately if available
      List<Map<String, dynamic>> featuredProducts = [];
      try {
        featuredProducts = await _productService.getFeaturedProducts();
        developer.log('HomeScreen: Successfully loaded ${featuredProducts.length} featured products');
      } catch (e) {
        developer.log('HomeScreen: Error loading featured products, will use active products instead', error: e);
      }
      
      // Load services
      developer.log('HomeScreen: Loading services');
      final services = await _serviceService.getAllServices(activeOnly: true);
      developer.log('HomeScreen: Successfully loaded ${services.length} services');
      
      if (mounted) {
        setState(() {
          // Use real data only if available, otherwise keep any existing data or use demo data
          if (banners.isNotEmpty) {
            _banners = banners;
          } else if (_banners.isEmpty) {
            // Create demo banners
            _banners = [
              BannerModel(
                id: 'demo1',
                title: 'Special Offer',
                subtitle: 'Get 20% off on all appliance repairs this week',
                imageUrl: 'https://placehold.co/800x400/orange/white?text=Special+Offer',
                discountPercentage: 20,
              ),
            ];
          }
          
          if (categories.isNotEmpty) {
            _categories = categories;
          } else if (_categories.isEmpty) {
            // Create demo categories
            _categories = [
              CategoryModel(id: "cat1", name: "Electronics"),
              CategoryModel(id: "cat2", name: "Appliances"),
              CategoryModel(id: "cat3", name: "Tools"),
            ];
          }
          
          // If we have featured products or active products, use those for display
          if (featuredProducts.isNotEmpty || activeProducts.isNotEmpty) {
            if (featuredProducts.isNotEmpty) {
              _popularProducts = featuredProducts;
              developer.log('HomeScreen: Using ${_popularProducts.length} featured products for popular section');
              
              // For spare parts, use non-featured active products
              _sparePartsProducts = activeProducts
                  .where((product) => !featuredProducts.any((featured) => featured['id'] == product['id']))
                  .take(4)
                  .toList();
            } else {
              // Otherwise just split the active products between popular and spare parts
              _popularProducts = activeProducts.take(activeProducts.length < 5 ? activeProducts.length : 5).toList();
              developer.log('HomeScreen: Added ${_popularProducts.length} active products to popular section');
              
              // Spare parts - get the next 4 if available
              if (activeProducts.length > 5) {
                _sparePartsProducts = activeProducts.skip(5).take(4).toList();
                developer.log('HomeScreen: Added ${_sparePartsProducts.length} active products to spare parts section');
              } else {
                _sparePartsProducts = [];
                developer.log('HomeScreen: No products available for spare parts section');
              }
            }
          } else if (_popularProducts.isEmpty) {
            // Create demo products if no real products are available
            _popularProducts = [
              {
                "id": "prod1", 
                "title": "Digital Multimeter", 
                "price": "1200", 
                "imageUrl": "https://placehold.co/400x400/blue/white?text=Multimeter"
              },
              {
                "id": "prod2", 
                "title": "Soldering Iron Kit", 
                "price": "2500", 
                "imageUrl": "https://placehold.co/400x400/blue/white?text=Soldering+Kit"
              },
            ];
            
            // Create demo spare parts
            _sparePartsProducts = [
              {
                "id": "spare1", 
                "title": "Fan Motor", 
                "price": "1800", 
                "imageUrl": "https://placehold.co/400x400/gray/white?text=Fan+Motor"
              },
              {
                "id": "spare2", 
                "title": "Circuit Board", 
                "price": "3200", 
                "imageUrl": "https://placehold.co/400x400/gray/white?text=Circuit+Board"
              },
            ];
          }
          
          if (services.isNotEmpty) {
            _services = services;
          } else if (_services.isEmpty) {
            // Create demo services
            _services = [
              ServiceModel(id: "serv1", name: "Repair", description: "Repair service", iconName: "build"),
              ServiceModel(id: "serv2", name: "Installation", description: "Installation service", iconName: "settings"),
            ];
          }
          
          _isLoading = false;
          
          // Reset current banner index if needed
          if (_currentBannerIndex >= _banners.length && _banners.isNotEmpty) {
            _currentBannerIndex = 0;
          }
          
          developer.log('HomeScreen: Successfully loaded all home page data');
        });
      }
    } catch (e, stackTrace) {
      developer.log('HomeScreen: Error loading home page data', error: e);
      developer.log('HomeScreen: Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load data: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}';
          _isLoading = false;
          
          // If we have no data, create demo data so UI always shows something
          if (_banners.isEmpty && _categories.isEmpty && _popularProducts.isEmpty && _services.isEmpty) {
            _createDemoData();
            _errorMessage = null; // Hide error message since we have demo data
          }
        });
      }
    }
  }

  void _toggleFavorite(String productId) {
    setState(() {
      _favoriteItems[productId] = !(_favoriteItems[productId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Prevent overflow with MediaQuery
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = kBottomNavigationBarHeight + bottomPadding;
    
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
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadHomePageData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                      ),
                      child: const Text('Try Again'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // Create demo data for display
                        setState(() {
                          _createDemoData();
                          _errorMessage = null;
                          _isLoading = false;
                        });
                      },
                      child: const Text('Continue With Demo Data'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                  if (_banners.isNotEmpty) ...[
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
                  ],
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
                  
                  // Spare parts section - only show when on All category and we have spare parts
                  if (_selectedCategory == 0 && _sparePartsProducts.isNotEmpty)
                    _buildSparePartsSection(),
                  if (_selectedCategory == 0 && _sparePartsProducts.isNotEmpty)
                    const SizedBox(height: 24),
      
                  // Services section
                  _buildServicesSection(),
                  
                  // Bottom padding to avoid overflow
                  const SizedBox(height: 32),
                ],
              ),
            ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
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
      ),
    );
  }

  // Update the banner slider
  Widget _buildBannerSlider() {
    if (_banners.isEmpty) {
      // Default banner if none are available
      developer.log('HomeScreen: No banners available for slider, showing default');
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Left content part (text)
                Expanded(
                  flex: 3,
                  child: Container(
                    color: const Color.fromARGB(40, 0, 0, 0),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '20%',
                          style: TextStyle(
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
                        const Text(
                          'On all appliance repairs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
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
                      Container(
                        color: Colors.amber,
                        child: const Center(
                          child: Text('SHOP ONLINE'),
                        ),
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
      );
    }
    
    developer.log('HomeScreen: Building banner slider with ${_banners.length} banners');
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
          developer.log('HomeScreen: Building banner UI for: ${banner.id}, title: ${banner.title}, discount: ${banner.discountPercentage}%, isActive: ${banner.isActive}');
          
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
                            color: const Color.fromARGB(40, 0, 0, 0),
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  banner.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                              SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: banner.imageUrl.isNotEmpty
                                ? Image.network(
                                    banner.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      developer.log('Error loading banner image: $error', error: error);
                                      developer.log('Failed URL: ${banner.imageUrl}');
                                      return Container(
                                        color: Colors.amber,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.image_not_supported, size: 32, color: Colors.white),
                                              const SizedBox(height: 8),
                                              Text(
                                                banner.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / 
                                                loadingProgress.expectedTotalBytes!
                                              : null,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.amber,
                                    child: Center(
                                      child: Text(
                                        banner.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
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
    if (_categories.isEmpty) {
      // Default categories if none are available
      return SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            _buildCategoryChip('All', true),
            _buildCategoryChip('Electronics', false),
            _buildCategoryChip('Appliances', false),
            _buildCategoryChip('Tools', false),
          ],
        ),
      );
    }
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _categoryNames.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == index;
          return _buildCategoryChip(_categoryNames[index], isSelected, onTap: () {
            setState(() {
              _selectedCategory = index;
            });
            // Load products for the selected category
            _loadProductsByCategory(_categoryNames[index]);
          });
        },
      ),
    );
  }
  
  Widget _buildCategoryChip(String name, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  
  // Load products by category
  Future<void> _loadProductsByCategory(String category) async {
    try {
      setState(() {
        _isLoadingProducts = true;
      });
      
      developer.log('HomeScreen: Loading products for category: $category');
      
      // If in offline demo mode, filter demo products instead of querying Firebase
      if (USE_OFFLINE_DEMO_MODE) {
        // Simulate loading delay
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (category == 'All') {
          // Keep current products for All category
          setState(() {
            _isLoadingProducts = false;
          });
          return;
        }
        
        // Filter demo products by selected category
        final filteredProducts = [
          ...(_popularProducts),
          ...(_sparePartsProducts)
        ].where((product) => 
          product['category'] == category
        ).toList();
        
        // If no products match the category, create some for that category
        if (filteredProducts.isEmpty) {
          filteredProducts.addAll([
            {
              "id": "${category.toLowerCase()}1",
              "title": "$category Item 1",
              "price": "1500",
              "category": category,
              "imageUrl": "https://placehold.co/400x400/blue/white?text=$category+1"
            },
            {
              "id": "${category.toLowerCase()}2",
              "title": "$category Item 2",
              "price": "2700",
              "category": category,
              "imageUrl": "https://placehold.co/400x400/blue/white?text=$category+2"
            }
          ]);
        }
        
        setState(() {
          _popularProducts = filteredProducts;
          _sparePartsProducts = []; // Hide spare parts when filtering
          _isLoadingProducts = false;
        });
        return;
      }
      
      // Normal Firebase data loading
      final products = await _productService.getProductsByCategory(category);
      
      developer.log('HomeScreen: Loaded ${products.length} products for category: $category');
      
      if (mounted) {
        setState(() {
          if (products.isNotEmpty) {
            // Show all products in the popular section when filtering by category
            _popularProducts = products;
            _sparePartsProducts = []; // Don't show spare parts section when category filtered
          } else {
            // If no products in category, show a message
            _popularProducts = [];
            _sparePartsProducts = [];
          }
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      developer.log('HomeScreen: Error loading products by category', error: e);
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  // Update the popular products section
  Widget _buildPopularProductsSection() {
    Widget content;
    
    if (_isLoadingProducts) {
      // Show loading indicator
      content = Center(
        child: SizedBox(
          height: 230,
          child: Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          ),
        ),
      );
    } else if (_popularProducts.isEmpty) {
      // Show placeholder products if none are available
      content = SizedBox(
        height: 230,
        child: _selectedCategory == 0 
            ? ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                children: [
                  Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildPlaceholderProductCard("Sample Product 1", "Rs 1200", Colors.blue[50]!),
                  ),
                  Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildPlaceholderProductCard("Sample Product 2", "Rs 1800", Colors.grey[200]!),
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No products found in the "${_categoryNames[_selectedCategory]}" category',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
      );
    } else {
      // Show actual products
      content = SizedBox(
        height: 230,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          itemCount: _popularProducts.length,
          itemBuilder: (context, index) {
            final product = _popularProducts[index];
            final productId = product['id'] ?? '';
            
            // Handle image - check for both imageUrl and imageBase64
            Widget productImage = _getProductImage(product);
            
            return Container(
              width: 180,
              margin: const EdgeInsets.only(right: 16),
              child: _buildProductCard(
                id: productId,
                name: product['title'] ?? 'Product',
                price: 'Rs ${product['price'] ?? '0'}',
                productImage: productImage,
                bgColor: index % 2 == 0 ? Colors.blue[50] : Colors.grey[200],
              ),
            );
          },
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            _selectedCategory == 0 ? 'Popular Products' : 'Products in ${_categoryNames[_selectedCategory]}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }
  
  // Add a placeholder product card
  Widget _buildPlaceholderProductCard(String name, String price, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                ),
              ),
            ),
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
  
  // Update the spare parts section
  Widget _buildSparePartsSection() {
    if (_sparePartsProducts.isEmpty) {
      // Show placeholder products if none are available
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
            Row(
              children: [
                Expanded(
                  child: _buildPlaceholderProductCard(
                    "Spare Part 1",
                    "Rs 800",
                    Colors.blue[50]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPlaceholderProductCard(
                    "Spare Part 2",
                    "Rs 1500",
                    Colors.grey[200]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
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
                    id: _sparePartsProducts[0]['id'] ?? '',
                    name: _sparePartsProducts[0]['title'] ?? 'Product',
                    price: 'Rs ${_sparePartsProducts[0]['price'] ?? '0'}',
                    productImage: _getProductImage(_sparePartsProducts[0]),
                    bgColor: Colors.blue[50],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProductCard(
                    id: _sparePartsProducts[1]['id'] ?? '',
                    name: _sparePartsProducts[1]['title'] ?? 'Product',
                    price: 'Rs ${_sparePartsProducts[1]['price'] ?? '0'}',
                    productImage: _getProductImage(_sparePartsProducts[1]),
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
                        id: _sparePartsProducts[2]['id'] ?? '',
                        name: _sparePartsProducts[2]['title'] ?? 'Product',
                        price: 'Rs ${_sparePartsProducts[2]['price'] ?? '0'}',
                        productImage: _getProductImage(_sparePartsProducts[2]),
                        bgColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProductCard(
                        id: _sparePartsProducts[3]['id'] ?? '',
                        name: _sparePartsProducts[3]['title'] ?? 'Product',
                        price: 'Rs ${_sparePartsProducts[3]['price'] ?? '0'}',
                        productImage: _getProductImage(_sparePartsProducts[3]),
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
  
  // Helper method to get product image widget
  Widget _getProductImage(Map<String, dynamic> product) {
    if (product.containsKey('imageBase64') && product['imageBase64'] != null && product['imageBase64'].toString().isNotEmpty) {
      try {
        // Use product service to convert base64 to image
        return _productService.safeBase64ToImage(
          product['imageBase64'],
          fit: BoxFit.contain,
        );
      } catch (e) {
        developer.log('Error displaying base64 image: $e');
      }
    } 
    
    if (product.containsKey('imageUrl') && product['imageUrl'] != null && product['imageUrl'].toString().isNotEmpty) {
      try {
        // Use network image
        return Image.network(
          product['imageUrl'],
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            developer.log('Error loading network image: $error');
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 50),
            );
          },
        );
      } catch (e) {
        developer.log('Error displaying URL image: $e');
      }
    }
    
    // Fallback image
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }
  
  // Update the services section
  Widget _buildServicesSection() {
    if (_services.isEmpty) {
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildServiceItem(Icons.build, 'Repair Service'),
                  const SizedBox(width: 16),
                  _buildServiceItem(Icons.electrical_services, 'Electrical'),
                  const SizedBox(width: 16),
                  _buildServiceItem(Icons.plumbing, 'Plumbing'),
                  const SizedBox(width: 16),
                  _buildServiceItem(Icons.engineering, 'Engineering'),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      width: double.infinity,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: _services.map((service) => 
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildServiceItem(
                    _serviceService.getIconDataFromName(service.iconName),
                    service.name,
                  ),
                )
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title) {
    return Container(
      width: 100,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
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
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
    required String id,
    required String name,
    required String price,
    required Widget productImage,
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
                  child: productImage,
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