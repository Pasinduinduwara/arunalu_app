import 'package:flutter/material.dart';
import 'place_order_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedCard = 0;
  bool _saveCard = true;

  final TextEditingController _ownerController = TextEditingController(text: 'Mrh Raju');
  final TextEditingController _numberController = TextEditingController(text: '5254 7634 8734 7690');
  final TextEditingController _expController = TextEditingController(text: '24/24');
  final TextEditingController _cvvController = TextEditingController(text: '7763');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
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
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Payment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                // Card carousel
                SizedBox(
                  height: 180,
                  child: PageView(
                    controller: PageController(viewportFraction: 0.8, initialPage: _selectedCard),
                    onPageChanged: (i) => setState(() => _selectedCard = i),
                    children: [
                      _buildCard(
                        name: 'Devindi',
                        type: 'Visa Classic',
                        number: '5254 **** **** 7690',
                        balance: 'Rs 1000',
                        color1: const Color(0xFFFFD600),
                        color2: const Color(0xFFFF5252),
                        logo: 'assets/images/visa_logo.png',
                      ),
                      _buildCard(
                        name: 'Madhawa',
                        type: 'Visa Classic',
                        number: '5254 **** **** 1234',
                        balance: 'Rs 3500',
                        color1: const Color(0xFFB2DFDB),
                        color2: const Color(0xFF388E3C),
                        logo: 'assets/images/visa_logo.png',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Card Owner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text('Card Owner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextField(
                    controller: _ownerController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF7F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Card Owner',
                    ),
                  ),
                ),
                // Card Number
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text('Card Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextField(
                    controller: _numberController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF7F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Card Number',
                    ),
                  ),
                ),
                // EXP and CVV
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('EXP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _expController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF7F7FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'EXP',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CVV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _cvvController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF7F7FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'CVV',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Save card info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Save card info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Switch(
                        value: _saveCard,
                        onChanged: (v) => setState(() => _saveCard = v),
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Save Card button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Save card details to Firestore
                        await FirebaseFirestore.instance.collection('cards').add({
                          'owner': _ownerController.text,
                          'number': _numberController.text,
                          'exp': _expController.text,
                          'cvv': _cvvController.text,
                          'saveCard': _saveCard,
                          'savedAt': FieldValue.serverTimestamp(),
                        });
                        // Navigate to place order screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlaceOrderScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00257E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text('Save Card', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String name,
    required String type,
    required String number,
    required String balance,
    required Color color1,
    required Color color2,
    required String logo,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: 320,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 24,
            left: 24,
            child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: 54,
            left: 24,
            child: Text(type, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Positioned(
            top: 80,
            left: 24,
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            child: Text(balance, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: Image.asset(logo, width: 48, height: 32),
          ),
        ],
      ),
    );
  }
} 