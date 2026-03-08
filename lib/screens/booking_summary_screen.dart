import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:intl/intl.dart'; // ✅ Added for date formatting
import '../utils/models.dart';
import '../utils/app_colors.dart';
import '../components/safe_network_image.dart';
import '../services/hotel_service.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Hotel hotel;

  const BookingSummaryScreen({super.key, required this.hotel});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final HotelService _hotelService = HotelService();
  File? _receiptImage;
  
  // ✅ NEW: Date Selection State
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Default range: Today to Tomorrow
    _selectedDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 1)),
    );
  }

  /// ✅ NEW: Function to pick dates from a calendar
  Future<void> _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _pickReceipt(StateSetter setModalState) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, 
      );

      if (image != null) {
        setState(() => _receiptImage = File(image.path));
        setModalState(() {}); 
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Calculate nights based on selection
    final int nights = _selectedDateRange?.duration.inDays ?? 1;
    final double subtotal = widget.hotel.price * nights;
    final double serviceFee = 15.00;
    final double totalPay = subtotal + serviceFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Booking Summary", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHotelBrief(),
            const SizedBox(height: 20),

            // --- 1. Stay Details Card (Now Clickable) ---
            InkWell(
              onTap: _selectDates,
              child: _buildSectionCard(
                title: "Stay Details (Tap to change)",
                child: Column(
                  children: [
                    _buildSummaryRow("Check-in", DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)),
                    const Divider(height: 24),
                    _buildSummaryRow("Check-out", DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)),
                    _buildSummaryRow("Duration", "$nights Nights"),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // --- 2. Price Breakdown Card ---
            _buildSectionCard(
              title: "Price Breakdown",
              child: Column(
                children: [
                  _buildSummaryRow("$nights Nights x \$${widget.hotel.price.toStringAsFixed(0)}", "\$${subtotal.toStringAsFixed(2)}"),
                  _buildSummaryRow("Service Fees", "\$${serviceFee.toStringAsFixed(2)}"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(thickness: 1),
                  ),
                  _buildSummaryRow("Total Amount", "\$${totalPay.toStringAsFixed(2)}", isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomPayButton(totalPay),
    );
  }

  // --- UI Components ---

  Widget _buildHotelBrief() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SafeNetworkImage(url: widget.hotel.image, width: 80, height: 80),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.hotel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(widget.hotel.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Icon(Icons.calendar_month, size: 16, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: isTotal ? 16 : 14)),
          Text(value, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 20 : 14,
            color: isTotal ? AppColors.primary : Colors.black87,
          )),
        ],
      ),
    );
  }

  Widget _buildBottomPayButton(double amount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => _showPaymentModal(context, amount),
        child: const Text("Pay Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _showPaymentModal(BuildContext context, double totalAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Scan to Pay", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset("assets/images/my_qr.jpg", height: 200, width: 200, fit: BoxFit.contain),
                ),
                const SizedBox(height: 25),
                const Text("Upload Payment Receipt", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _pickReceipt(setModalState),
                  child: Container(
                    height: 120, width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100], borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _receiptImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_receiptImage!, fit: BoxFit.cover))
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 30),
                              Text("Optional for testing", style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _handleBookingExecution(totalAmount),
                  child: const Text("Confirm & Complete", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleBookingExecution(double totalAmount) async {
    Navigator.pop(context); 
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    // ✅ FIXED: Using actual selected dates for the booking
    final int? bookingId = await _hotelService.createBooking(
      hotelId: widget.hotel.id,
      totalPrice: totalAmount,
      checkIn: DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start),
      checkOut: DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end),
    );

    if (bookingId != null) {
      if (_receiptImage != null) {
        await _hotelService.uploadPaymentReceipt(bookingId, _receiptImage!);
      }
      if (mounted) Navigator.pop(context); 
      _showSuccessScreen();
    } else {
      if (mounted) Navigator.pop(context);
      _showSnackBar("Failed to create booking.", Colors.red);
    }
  }

  void _showSuccessScreen() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Booking Submitted!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Check your status in 'My Trips'.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50)),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("Back to Home", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));
  }
}