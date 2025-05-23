import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import 'dart:developer' as developer;
import 'terms_emergency_booking.dart';

class EmergencyBookingScreen extends StatefulWidget {
  const EmergencyBookingScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyBookingScreen> createState() => _EmergencyBookingScreenState();
}

class _EmergencyBookingScreenState extends State<EmergencyBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedServiceType = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  bool _isLoading = false;
  
  // Available time slots
  final List<String> _timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM', 
    '11:00 AM', '12:00 PM', '01:00 PM',
    '02:00 PM', '03:00 PM', '04:00 PM',
    '05:00 PM', '06:00 PM', '07:00 PM',
  ];
  
  // Service types
  final List<String> _serviceTypes = [
    'Air Conditioning', 
    'Refrigerator',
    'Washing Machine',
    'Microwave',
    'Electrical Wiring',
    'Plumbing',
    'General Repairs',
    'Other'
  ];
  
  // Generate list of valid dates (today + next 10 days)
  List<DateTime> _getValidDates() {
    List<DateTime> dates = [];
    DateTime now = DateTime.now();
    
    for (int i = 0; i <= 10; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    
    return dates;
  }
  
  // Check if selected date and time slot is available
  Future<bool> _isSlotAvailable(DateTime date, String timeSlot) async {
    try {
      // Format date to string for querying
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      
      // Count existing bookings for this date
      final bookingsSnapshot = await _firestore
          .collection('emergency_bookings')
          .where('bookingDate', isEqualTo: formattedDate)
          .where('bookingTime', isEqualTo: timeSlot)
          .get();
      
      // Maximum 6 bookings per day per time slot
      return bookingsSnapshot.docs.length < 6;
    } catch (e) {
      developer.log('Error checking slot availability', error: e);
      return false;
    }
  }
  
  // Count total bookings for a date
  Future<int> _getTotalBookingsForDate(DateTime date) async {
    try {
      // Format date to string for querying
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      
      // Count existing bookings for this date
      final bookingsSnapshot = await _firestore
          .collection('emergency_bookings')
          .where('bookingDate', isEqualTo: formattedDate)
          .get();
      
      return bookingsSnapshot.docs.length;
    } catch (e) {
      developer.log('Error counting bookings for date', error: e);
      return 0;
    }
  }
  
  // Save booking to Firebase
  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate() || 
        _selectedDate == null || 
        _selectedTime == null || 
        _selectedServiceType.isEmpty) {
      // Show validation error
      _showErrorDialog('Please fill all the required fields');
      return;
    }
    
    // Format date and time
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final formattedTime = _getFormattedTimeString(_selectedTime!);
    
    // Create booking data
    final bookingData = {
      'fullName': _nameController.text,
      'phoneNumber': _phoneController.text,
      'email': _emailController.text,
      'serviceType': _selectedServiceType,
      'bookingDate': formattedDate,
      'bookingTime': formattedTime,
      'emergencyCharge': 1500,
      'bookingType': 'emergency',
      'status': 'pending',
    };

    // Show terms and conditions
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TermsEmergencyBooking(
          selectedDate: _selectedDate!,
          selectedTime: formattedTime,
          bookingData: bookingData,
        ),
      ),
    );
  }
  
  String _getFormattedTimeString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final displayHour = time.hourOfPeriod == 0 ? '12' : time.hourOfPeriod.toString().padLeft(2, '0');
    return '$displayHour:$minute $period';
  }
  
  // Show date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime lastValidDate = now.add(const Duration(days: 10));
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: lastValidDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppConstants.primaryColor,
            colorScheme: ColorScheme.light(primary: AppConstants.primaryColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  
  // Show time picker dialog
  void _selectTime() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _timeSlots.length,
                  itemBuilder: (context, index) {
                    final timeSlot = _timeSlots[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          // Convert string time slot to TimeOfDay
                          final timeParts = timeSlot.split(' ');
                          final hourMinute = timeParts[0].split(':');
                          int hour = int.parse(hourMinute[0]);
                          final int minute = int.parse(hourMinute[1]);
                          
                          if (timeParts[1] == 'PM' && hour < 12) {
                            hour += 12;
                          } else if (timeParts[1] == 'AM' && hour == 12) {
                            hour = 0;
                          }
                          
                          _selectedTime = TimeOfDay(hour: hour, minute: minute);
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: _selectedTime != null && 
                                 _getFormattedTimeString(_selectedTime!) == timeSlot
                              ? Border.all(color: AppConstants.primaryColor, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            timeSlot,
                            style: TextStyle(
                              color: _selectedTime != null && 
                                    _getFormattedTimeString(_selectedTime!) == timeSlot
                                  ? AppConstants.primaryColor
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 64),
              SizedBox(height: 16),
              Text(
                'Emergency repair booked successfully!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  // Select service type
  void _selectServiceType() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Service Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _serviceTypes.length,
                  itemBuilder: (context, index) {
                    final serviceType = _serviceTypes[index];
                    return ListTile(
                      title: Text(serviceType),
                      trailing: _selectedServiceType == serviceType
                          ? Icon(Icons.check, color: AppConstants.primaryColor)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedServiceType = serviceType;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Emergency Booking',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Time selection
                  GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedTime != null
                                ? _getFormattedTimeString(_selectedTime!)
                                : 'Time',
                            style: TextStyle(
                              color: _selectedTime != null
                                  ? Colors.black
                                  : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Date selection
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate != null
                                ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                                : 'Date',
                            style: TextStyle(
                              color: _selectedDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Service Type
                  GestureDetector(
                    onTap: _selectServiceType,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedServiceType.isNotEmpty
                                ? _selectedServiceType
                                : 'Service Type',
                            style: TextStyle(
                              color: _selectedServiceType.isNotEmpty
                                  ? Colors.black
                                  : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Emergency Charge message
                  Text(
                    'Emergency Charge: Rs.1500 extra applied',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Book Emergency Repair button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Book Emergency Repair',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 