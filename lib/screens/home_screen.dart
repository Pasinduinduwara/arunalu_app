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
import '../models/appointment_model.dart';
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
      // Load products immediately for initial display
      _loadProductsByCategory('All');
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
      
      // IMPORTANT: Load all products directly to debug  
      developer.log('HomeScreen: Loading ALL products for debugging');
      List<Map<String, dynamic>> allProducts = await _productService.getAllProducts();
      developer.log('HomeScreen: Found ${allProducts.length} TOTAL products in database');
      
      // Log first few products to see their structure
      for (var product in allProducts.take(3)) {
        developer.log('HomeScreen: Product from DB - ID: ${product['id']}, Title: ${product['title']}');
        developer.log('HomeScreen: Product details - Price: ${product['price']}, Category: ${product['category']}');
        developer.log('HomeScreen: Product active? ${product['isActive']}, featured? ${product['isFeatured']}');
      }
      
      // Load active products directly - simplify to debug
      developer.log('HomeScreen: Loading active products');
      final activeProducts = await _productService.getActiveProducts();
      developer.log('HomeScreen: Successfully loaded ${activeProducts.length} active products');
      
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
          
          // IMPORTANT: Directly use the active products for display
          if (activeProducts.isNotEmpty) {
            _popularProducts = activeProducts.take(4).toList();
            developer.log('HomeScreen: Added ${_popularProducts.length} products to popular section');
            
            // Spare parts - get the next products if available
            if (activeProducts.length > 4) {
              _sparePartsProducts = activeProducts.skip(4).take(4).toList();
              developer.log('HomeScreen: Added ${_sparePartsProducts.length} products to spare parts section');
            } else {
              _sparePartsProducts = [];
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
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
        onRefresh: () async {
          await _loadHomePageData();
          await _loadProductsByCategory(_selectedCategory == 0 ? 'All' : _categoryNames[_selectedCategory]);
        },
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
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: bottomNavHeight + 24), // Extra padding at bottom
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
                const SizedBox(height: 24), // Reduced padding
    
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
                  const SizedBox(height: 12), // Reduced padding
                  _buildCategoriesSection(),
                  const SizedBox(height: 16), // Reduced padding
                ],
    
                // Appointments section
                _buildAppointmentSection(),
                const SizedBox(height: 16), // Reduced padding
                
                // Popular Products
                _buildPopularProductsSection(),
                const SizedBox(height: 16), // Reduced padding
                
                // Spare parts section - only show when on All category
                if (_selectedCategory == 0)
                  _buildSparePartsSection(),
                
                // Services section
                _buildServicesSection(),
              ],
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
    
    developer.log('HomeScreen: Building categories section with ${_categories.length} categories');
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
      
      try {
        // Normal Firebase data loading
        List<Map<String, dynamic>> products = [];
        
        // For "All" category, load all products
        if (category == 'All') {
          // First try to get featured products
          try {
            products = await _productService.getFeaturedProducts();
            developer.log('HomeScreen: Fetched ${products.length} featured products');
          } catch (e) {
            developer.log('HomeScreen: Error fetching featured products', error: e);
            products = [];
          }
          
          // If no featured products available, get all active products
          if (products.isEmpty) {
            try {
              products = await _productService.getActiveProducts();
              developer.log('HomeScreen: Fetched ${products.length} active products (no featured found)');
            } catch (e) {
              developer.log('HomeScreen: Error fetching active products', error: e);
              products = [];
            }
          }
        } else {
          // Get products filtered by category
          try {
            products = await _productService.getProductsByCategory(category);
            developer.log('HomeScreen: Loaded ${products.length} products for category: $category');
          } catch (e) {
            developer.log('HomeScreen: Error fetching products by category', error: e);
            products = [];
          }
        }
        
        // Process products based on loaded data
        if (products.isNotEmpty) {
          developer.log('HomeScreen: Processing ${products.length} products');
          
          // Debug log product details
          for (var product in products.take(3)) {
            developer.log('HomeScreen: Product: ${product['title']}, Price: ${product['price']}, Category: ${product['category']}');
            if (product.containsKey('imageBase64')) {
              developer.log('HomeScreen: Product has base64 image');
            } else if (product.containsKey('imageUrl')) {
              developer.log('HomeScreen: Product has URL image: ${product['imageUrl']}');
            } else {
              developer.log('HomeScreen: Product has no image');
            }
          }
          
          // For "All" category, split products between popular and spare parts
          if (category == 'All') {
            if (products.length > 3) {
              _popularProducts = products.sublist(0, 3);
              
              // Remaining products for spare parts (up to 4)
              final remaining = products.length - 3;
              final count = remaining > 4 ? 4 : remaining;
              _sparePartsProducts = products.sublist(3, 3 + count);
            } else {
              _popularProducts = products;
              _sparePartsProducts = [];
            }
            
            developer.log('HomeScreen: Split products - Popular: ${_popularProducts.length}, Spare Parts: ${_sparePartsProducts.length}');
          } else {
            // For specific category, all products go to popular section
            _popularProducts = products;
            _sparePartsProducts = [];
            developer.log('HomeScreen: Category products - Popular: ${_popularProducts.length}');
          }
        } else {
          // No products found
          developer.log('HomeScreen: No products found to display');
          
          if (category == 'All') {
            // For "All" category with no products, use placeholders
            _popularProducts = [
              {
                "id": "sample1",
                "title": "Sample Product 1",
                "price": "1200",
                "category": "Electronics",
                "imageUrl": "https://placehold.co/400x400/blue/white?text=Sample+1"
              },
              {
                "id": "sample2",
                "title": "Sample Product 2",
                "price": "1800",
                "category": "Tools",
                "imageUrl": "https://placehold.co/400x400/blue/white?text=Sample+2"
              }
            ];
            _sparePartsProducts = [];
          } else {
            // For specific category with no products
            _popularProducts = [
              {
                "id": "${category.toLowerCase()}1",
                "title": "$category Item",
                "price": "2500",
                "category": category,
                "imageUrl": "https://placehold.co/400x400/blue/white?text=$category"
              }
            ];
            _sparePartsProducts = [];
          }
        }
        
        setState(() {
          _isLoadingProducts = false;
        });
        
      } catch (e) {
        developer.log('HomeScreen: Error in product loading', error: e);
        
        // Create some dummy products if loading fails
        setState(() {
          _popularProducts = [
            {
              "id": "error1",
              "title": "Sample Product",
              "price": "1500",
              "category": "Sample",
              "imageUrl": "https://placehold.co/400x400/red/white?text=Error+Loading"
            }
          ];
          _sparePartsProducts = [];
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      developer.log('HomeScreen: Critical error loading products', error: e);
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  // Update the popular products section
  Widget _buildPopularProductsSection() {
    Widget content;
    
    if (_isLoadingProducts) {
      // Show loading indicator
      content = Center(
        child: SizedBox(
          height: 200, // Reduced fixed height
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
        height: 200, // Reduced fixed height
        child: _selectedCategory == 0 
            ? ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                children: [
                  Container(
                    width: 160, // Reduced width
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildPlaceholderProductCard("Sample Product 1", "Rs 1200", Colors.blue[50]!),
                  ),
                  Container(
                    width: 160, // Reduced width
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
      developer.log('HomeScreen: Building product list UI with ${_popularProducts.length} products');
      
      content = SizedBox(
        height: 200, // Reduced fixed height
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          itemCount: _popularProducts.length,
          itemBuilder: (context, index) {
            final product = _popularProducts[index];
            final productId = product['id'] ?? '';
            
            // Ensure we handle all possible data types for price
            String priceText = 'Rs 0';
            if (product.containsKey('price')) {
              var price = product['price'];
              if (price is int) {
                priceText = 'Rs $price';
              } else if (price is double) {
                priceText = 'Rs ${price.toStringAsFixed(2)}';
              } else if (price is String) {
                priceText = 'Rs $price';
              } else {
                priceText = 'Rs 0';
              }
            }
            
            final title = product['title'] ?? 'Product';
            final category = product['category'] ?? '';
            
            // Handle image - check for both imageUrl and imageBase64
            Widget productImage = _getProductImage(product);
            
            return GestureDetector(
              onTap: () => _viewProductDetails(product),
              child: Container(
                width: 160, // Reduced width
                margin: const EdgeInsets.only(right: 16),
                child: _buildProductCard(
                  id: productId,
                  name: title,
                  price: priceText,
                  productImage: productImage,
                  bgColor: index % 2 == 0 ? Colors.blue[50] : Colors.grey[200],
                ),
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
        const SizedBox(height: 12), // Reduced padding
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
      // Don't show the section if no spare parts available
      return const SizedBox.shrink();
    }
    
    developer.log('HomeScreen: Building spare parts section with ${_sparePartsProducts.length} products');
    
    // Calculate item count to avoid having a partial row
    final itemCount = _sparePartsProducts.length > 4 ? 4 : _sparePartsProducts.length; // Limit to max 4 items
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spare Parts',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12), // Reduced spacing
          
          // Use fixed height container with Row layout
          Container(
            height: 200, // Fixed height to prevent overflow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final product = _sparePartsProducts[index];
                
                // Ensure we handle all possible data types for price
                String priceText = 'Rs 0';
                if (product.containsKey('price')) {
                  var price = product['price'];
                  if (price is int) {
                    priceText = 'Rs $price';
                  } else if (price is double) {
                    priceText = 'Rs ${price.toStringAsFixed(2)}';
                  } else if (price is String) {
                    priceText = 'Rs $price';
                  } else {
                    priceText = 'Rs 0';
                  }
                }
                
                final productId = product['id'] ?? '';
                final title = product['title'] ?? 'Product';
                
                return GestureDetector(
                  onTap: () => _viewProductDetails(product),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildProductCard(
                      id: productId,
                      name: title,
                      price: priceText,
                      productImage: _getProductImage(product),
                      bgColor: index % 2 == 0 ? Colors.grey[200] : Colors.blue[50],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get product image widget
  Widget _getProductImage(Map<String, dynamic> product) {
    // First check for base64 encoded image
    if (product.containsKey('imageBase64') && product['imageBase64'] != null && product['imageBase64'].toString().isNotEmpty) {
      try {
        developer.log('HomeScreen: Using base64 image for: ${product['title']}');
        // Use product service to convert base64 to image
        return _productService.safeBase64ToImage(
          product['imageBase64'],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            developer.log('HomeScreen: Error rendering base64 image', error: error);
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported, size: 50),
            );
          },
        );
      } catch (e) {
        developer.log('HomeScreen: Error processing base64 image', error: e);
      }
    }
    
    // Then check for image URL
    if (product.containsKey('imageUrl') && product['imageUrl'] != null && product['imageUrl'].toString().isNotEmpty) {
      try {
        developer.log('HomeScreen: Using URL image for: ${product['title']}');
        // Use network image
        return Image.network(
          product['imageUrl'],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            developer.log('HomeScreen: Error loading network image', error: error);
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported, size: 50),
            );
          },
        );
      } catch (e) {
        developer.log('HomeScreen: Error processing URL image', error: e);
      }
    }
    
    // Fallback image
    developer.log('HomeScreen: Using fallback image for: ${product['title']}');
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
    );
  }
  
  // Update the services section
  Widget _buildServicesSection() {
    if (_services.isEmpty) {
      developer.log('HomeScreen: No services available, showing placeholders');
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
    
    developer.log('HomeScreen: Building services section with ${_services.length} services');
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
              children: _services
                .where((service) => service.isActive) // Only show active services
                .map((service) {
                  developer.log('HomeScreen: Adding service to UI: ${service.name}, icon: ${service.iconName}');
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildServiceItem(
                      _serviceService.getIconDataFromName(service.iconName),
                      service.name,
                    ),
                  );
                }).toList(),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed height for image container
          SizedBox(
            height: 120, // Reduced fixed height
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 120, // Must match parent height
                    child: productImage,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => _toggleFavorite(id),
                    child: Container(
                      padding: const EdgeInsets.all(6), // Reduced
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
                        size: 18, // Reduced
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Fixed height for text content
          Padding(
            padding: const EdgeInsets.all(8.0), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12, // Reduced
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // Reduced
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 14, // Reduced
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSection() {
    return Padding(
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
          FutureBuilder<List<AppointmentTypeModel>>(
            future: _appointmentTypeService.getAllAppointmentTypes(activeOnly: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SizedBox(
                    height: 50,
                    child: CircularProgressIndicator(color: AppConstants.primaryColor),
                  ),
                );
              }
              
              final appointmentTypes = snapshot.data ?? [];
              
              // If no appointment types defined, show default buttons
              if (appointmentTypes.isEmpty) {
                return Row(
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
                );
              }
              
              // Show appointment types from admin panel
              return SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: appointmentTypes.length,
                  itemBuilder: (context, index) {
                    final type = appointmentTypes[index];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: type.color,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type.isEmergency ? Icons.emergency : Icons.calendar_today,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _viewProductDetails(Map<String, dynamic> product) {
    // Show a dialog with the product details - simple implementation for now
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product['title'] ?? 'Product Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              if (product.containsKey('imageUrl') && product['imageUrl'] != null) 
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    product['imageUrl'],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, _) => const Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                )
              else if (product.containsKey('imageBase64') && product['imageBase64'] != null)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: _getProductImage(product),
                ),
              const SizedBox(height: 16),
              
              // Product price
              Text(
                'Rs ${product['price'] ?? '0'}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Product description
              if (product.containsKey('description') && product['description'] != null) ...[
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product['description'],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
              
              // Product category
              if (product.containsKey('category') && product['category'] != null) ...[
                Row(
                  children: [
                    const Text(
                      'Category: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      product['category'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              
              // Product stock
              if (product.containsKey('stock') && product['stock'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Stock: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${product['stock']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add to cart functionality would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to cart')),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
} 