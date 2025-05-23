import 'package:flutter/material.dart';
import 'order_confirm_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceOrderScreen extends StatelessWidget {
  const PlaceOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Cash on Delivery',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Delivery Address
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text('Temple Rd, Galle', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Icon(Icons.edit, color: Colors.black, size: 22),
                ],
              ),
            ),
            const Divider(height: 1),
            // Order Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Items', style: TextStyle(fontSize: 16)),
                      Text('Rs 4000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Delivery Charges', style: TextStyle(fontSize: 16)),
                      Text('Rs  350', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Rs 4350', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Info and agreement
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lock_outline, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please keep exact amount ready for the delivery',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Icon(Icons.check_circle_outline, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'I agree to pay in cash upon delivery',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Save order details to Firestore
                    await FirebaseFirestore.instance.collection('orders').add({
                      'address': 'Temple Rd, Galle',
                      'items': [
                        {'name': 'Sample Item', 'price': 4000, 'quantity': 1},
                      ],
                      'deliveryCharges': 350,
                      'total': 4350,
                      'paymentMethod': 'Cash on Delivery',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    // Navigate to order confirm screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderConfirmScreen(),
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
                  child: const Text('Place Order', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 