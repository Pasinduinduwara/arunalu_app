import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../services/product_service.dart';
import 'dart:developer' as developer;
import 'product_details_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  bool _isAdmin = false; // This should be set based on user role
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  Map<String, bool> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndProducts();
    // TODO: Check if user is admin
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    // TODO: Implement proper admin check
    setState(() {
      _isAdmin = true; // For testing purposes
    });
  }

  Future<void> _loadCategoriesAndProducts() async {
    setState(() => _isLoading = true);
    final products = await _productService.getAllProducts();
    final cats = await _productService.getCategories();
    setState(() {
      _products = products;
      _categories = ['All', ...cats];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'All') return _products;
    return _products.where((p) => p['category'] == _selectedCategory).toList();
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
      _loadCategoriesAndProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product')),
      );
    }
  }

  Future<void> _showAddEditProductDialog([Map<String, dynamic>? product]) async {
    final titleController = TextEditingController(text: product?['title'] ?? '');
    final priceController = TextEditingController(text: product?['price']?.toString() ?? '');
    final stockController = TextEditingController(text: product?['stock']?.toString() ?? '');
    final descriptionController = TextEditingController(text: product?['description'] ?? '');
    String selectedCategory = product?['category'] ?? _categories[1];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add New Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: _categories.where((c) => c != 'All').map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final productData = {
                'title': titleController.text,
                'price': priceController.text,
                'stock': int.tryParse(stockController.text) ?? 0,
                'description': descriptionController.text,
                'category': selectedCategory,
              };

              try {
                if (product == null) {
                  await _productService.addProduct(productData);
                } else {
                  await _productService.updateProduct(product['id'], productData);
                }
                Navigator.pop(context);
                _loadCategoriesAndProducts();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(product == null ? 'Product added successfully' : 'Product updated successfully'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to save product')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: Text(product == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Store',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () => _showAddEditProductDialog(),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'store',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7FA),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Find your favorite items',
                          hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7FA),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(Icons.qr_code_scanner, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            // Category Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final selected = cat == _selectedCategory;
                    return ChoiceChip(
                      label: Text(cat, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.black : Colors.black)),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFF7F7FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: selected ? Colors.black12 : Colors.black12),
                      ),
                      elevation: 0,
                    );
                  },
                ),
              ),
            ),
            // Product Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GridView.builder(
                        itemCount: _filteredProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, idx) {
                          final product = _filteredProducts[idx];
                          final isFav = _favorites[product['id']] ?? false;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    name: product['title'] ?? '',
                                    price: product['price']?.toString() ?? '',
                                    images: product['images'] != null && product['images'] is List && (product['images'] as List).isNotEmpty
                                      ? List<String>.from(product['images'])
                                      : [product['imageUrl'] ?? ''],
                                  ),
                                ),
                              );
                            },
                            child: _StoreProductCard(
                              name: product['title'] ?? '',
                              price: product['price']?.toString() ?? '',
                              imageUrl: product['imageUrl'],
                              isFavorite: isFav,
                              onFavorite: () => setState(() => _favorites[product['id']] = !isFav),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const _StoreProductCard({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavorite,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(imageUrl!, fit: BoxFit.cover)
                      : Container(color: Colors.grey[300]),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onFavorite,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Text(
              'Rs $price',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 