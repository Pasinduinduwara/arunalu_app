import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String name;
  final String price;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final List<Color> colors;

  const ProductDetailsScreen({
    Key? key,
    required this.name,
    required this.price,
    required this.images,
    this.rating = 4.8,
    this.reviewCount = 231,
    this.colors = const [Colors.black, Color(0xFFD9D9D9), Color(0xFFF3F3F3)],
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImage = 0;
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      _circleButton(icon: Icons.favorite_border, onTap: () {}),
                      const SizedBox(width: 16),
                      _circleButton(icon: Icons.share_outlined, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
            // Product image
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      itemCount: widget.images.length,
                      controller: PageController(initialPage: _selectedImage),
                      onPageChanged: (i) => setState(() => _selectedImage = i),
                      itemBuilder: (context, idx) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.network(
                          widget.images[idx],
                          fit: BoxFit.contain,
                          height: 220,
                        ),
                      ),
                    ),
                  ),
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.images.length, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: i == _selectedImage ? const Color(0xFF00257E) : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    )),
                  ),
                  // Thumbnails
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.images.length, (i) => GestureDetector(
                        onTap: () => setState(() => _selectedImage = i),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: i == _selectedImage ? const Color(0xFF00257E) : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.network(
                            widget.images[i],
                            width: 48,
                            height: 48,
                          ),
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs.${widget.price}',
                    style: const TextStyle(
                      color: Color(0xFF00257E),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Color selection
                  Row(
                    children: List.generate(widget.colors.length, (i) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: widget.colors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: i == _selectedColor ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFC107), size: 22),
                      const SizedBox(width: 4),
                      Text(
                        widget.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text('(${widget.reviewCount})', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Save to Firestore cart collection
                            await FirebaseFirestore.instance.collection('cart').add({
                              'name': widget.name,
                              'imageUrl': widget.images.isNotEmpty ? widget.images[0] : '',
                              'price': double.tryParse(widget.price) ?? 0,
                              'quantity': 1,
                              'addedAt': FieldValue.serverTimestamp(),
                            });
                            // Navigate to cart screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartScreen(
                                  cartItems: [
                                    CartItem(
                                      name: widget.name,
                                      imageUrl: widget.images.isNotEmpty ? widget.images[0] : '',
                                      price: double.tryParse(widget.price) ?? 0,
                                      quantity: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Add to  cart', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutScreen(
                                  cartItems: [
                                    CartItem(
                                      name: widget.name,
                                      imageUrl: widget.images.isNotEmpty ? widget.images[0] : '',
                                      price: double.tryParse(widget.price) ?? 0,
                                      quantity: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00257E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Buy Now', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 22),
      ),
    );
  }
} 