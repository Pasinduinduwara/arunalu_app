import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'booking_success_screen.dart';
import 'booking_failure_screen.dart';

class TermsNormalBookingScreen extends StatelessWidget {
  final DateTime selectedDate;
  final String selectedSlot;
  final String name;
  final String email;
  final String contact;
  final String serviceType;

  const TermsNormalBookingScreen({
    Key? key,
    required this.selectedDate,
    required this.selectedSlot,
    required this.name,
    required this.email,
    required this.contact,
    required this.serviceType,
  }) : super(key: key);

  Future<bool> checkBookingAvailability() async {
    final String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final bool isMorning = selectedSlot.startsWith('M');

    // Get bookings for the selected date
    final QuerySnapshot bookings = await FirebaseFirestore.instance
        .collection('bookings')
        .where('date', isEqualTo: dateStr)
        .get();

    // Count morning and afternoon bookings
    int morningCount = 0;
    int afternoonCount = 0;

    for (var doc in bookings.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['slot'].toString().startsWith('M')) {
        morningCount++;
      } else {
        afternoonCount++;
      }
    }

    // Check if slot is available
    if (isMorning && morningCount >= 12) return false;
    if (!isMorning && afternoonCount >= 12) return false;
    if ((morningCount + afternoonCount) >= 24) return false;

    return true;
  }

  Future<void> createBooking(BuildContext context) async {
    try {
      // Check availability
      final bool isAvailable = await checkBookingAvailability();
      
      if (!isAvailable) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BookingFailureScreen()),
        );
        return;
      }

      // Create booking
      await FirebaseFirestore.instance.collection('bookings').add({
        'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'slot': selectedSlot,
        'name': name,
        'email': email,
        'contact': contact,
        'serviceType': serviceType,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'confirmed',
      });

      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookingSuccessScreen()),
      );
    } catch (e) {
      // Navigate to failure screen on error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookingFailureScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Terms & Condition',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildTermItem(
              '1',
              'Service Booking: Users must provide accurate information when booking a repair.',
            ),
            const SizedBox(height: 24),
            _buildTermItem(
              '2',
              'Appointment Changes: Bookings can be rescheduled up to 24 hours before the appointment.',
            ),
            const SizedBox(height: 24),
            _buildTermItem(
              '3',
              'Payment: Charges may vary based on issue type. Payment is due after service completion.',
            ),
            const SizedBox(height: 24),
            _buildTermItem(
              '4',
              'Warranty: Repairs may include limited warranty based on parts replaced.',
            ),
            const SizedBox(height: 24),
            _buildTermItem(
              '5',
              'Liability: We are not responsible for damages caused by user mishandling before or after repair.',
            ),
            const SizedBox(height: 24),
            _buildTermItem(
              '6',
              'Cancellations: Cancellations made less than 12 hours before may incur a fee.',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => createBooking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00257E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Agree',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
} 