import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import 'booking_successful_screen.dart';
import 'booking_unsuccessful_screen.dart';
import 'dart:developer' as developer;

class TermsEmergencyBooking extends StatelessWidget {
  final DateTime selectedDate;
  final String selectedTime;
  final Map<String, dynamic> bookingData;

  const TermsEmergencyBooking({
    Key? key,
    required this.selectedDate,
    required this.selectedTime,
    required this.bookingData,
  }) : super(key: key);

  // Check if selected date and time slot is available
  Future<bool> _isSlotAvailable(BuildContext context) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Format date to string for querying
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      
      // Count existing bookings for this date and time
      final bookingsSnapshot = await firestore
          .collection('emergency_bookings')
          .where('bookingDate', isEqualTo: formattedDate)
          .where('bookingTime', isEqualTo: selectedTime)
          .get();
      
      // Count total bookings for the day
      final totalBookingsSnapshot = await firestore
          .collection('emergency_bookings')
          .where('bookingDate', isEqualTo: formattedDate)
          .get();
      
      // Check both conditions:
      // 1. Maximum 6 bookings per time slot
      // 2. Maximum 72 bookings per day (6 bookings × 12 time slots)
      bool isTimeSlotAvailable = bookingsSnapshot.docs.length < 6;
      bool isDaySlotAvailable = totalBookingsSnapshot.docs.length < 72;
      
      return isTimeSlotAvailable && isDaySlotAvailable;
      
    } catch (e) {
      developer.log('Error checking slot availability', error: e);
      return false;
    }
  }

  Future<void> _handleAgreePressed(BuildContext context) async {
    try {
      final bool isAvailable = await _isSlotAvailable(context);
      
      if (!isAvailable) {
        // Show unsuccessful screen if slot is not available
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BookingUnsuccessfulScreen(),
            ),
          );
        }
        return;
      }

      // If slot is available, save the booking
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('emergency_bookings').add({
        ...bookingData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show successful screen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingSuccessfulScreen(),
          ),
        );
      }
    } catch (e) {
      developer.log('Error saving booking', error: e);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingUnsuccessfulScreen(),
          ),
        );
      }
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Terms & Condition',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _handleAgreePressed(context),
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
          number,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
} 