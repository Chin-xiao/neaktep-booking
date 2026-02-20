import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../utils/app_colors.dart';
import '../utils/models.dart';

class NotificationDetailScreen extends StatelessWidget {
  /// Safely catches both raw Maps and Booking objects
  final dynamic booking; 
  final String? title;
  final String? message;
  final IconData? icon;
  final Color? iconColor;
  final String? timestamp;
  final String? detailedDescription;

  const NotificationDetailScreen({
    super.key,
    this.booking,
    this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.timestamp,
    this.detailedDescription,
  });

  /// Formats date safely whether it is a DateTime object or a String
  String _formatDate(dynamic date) {
    if (date == null) return "N/A";
    try {
      if (date is DateTime) return DateFormat('EEE, MMM dd, yyyy').format(date);
      return DateFormat('EEE, MMM dd, yyyy').format(DateTime.parse(date.toString()));
    } catch (e) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are showing a detailed booking receipt or a simple text alert
    final bool isBookingInvoice = booking != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          isBookingInvoice ? "Booking Details" : "Notification",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // Standard back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: isBookingInvoice 
            ? _buildDetailedInvoice(context) 
            : _buildGeneralNotification(),
      ),
    );
  }

  Widget _buildDetailedInvoice(BuildContext context) {
    /// Auto-convert Map to Booking Object if necessary to avoid subtype errors.
    final Booking b = booking is Booking ? booking : Booking.fromJson(booking);
    final hotel = b.hotel;

    return Column(
      children: [
        // 1. Success Header
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
              ),
              const SizedBox(height: 16),
              const Text(
                "Booking Confirmed", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8),
              Text(
                "Transaction ID: #TRX-${b.id}", 
                style: const TextStyle(color: Colors.grey, fontSize: 13, letterSpacing: 0.5)
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hotel Information", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
              ),
              const SizedBox(height: 12),
              
              // 2. Hotel Card
              _buildCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        hotel.image, 
                        width: 80, 
                        height: 80, 
                        fit: BoxFit.cover, 
                        errorBuilder: (c, e, s) => Container(
                          width: 80, height: 80, color: Colors.grey[200],
                          child: const Icon(Icons.hotel, color: Colors.grey),
                        )
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  hotel.location, 
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Stay Details", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
              ),
              const SizedBox(height: 12),

              // 3. Stay Details Card
              _buildCard(
                child: Column(
                  children: [
                    _row("Status", b.status.toUpperCase(), color: b.statusColor),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(thickness: 0.5),
                    ),
                    _row("Check In", _formatDate(b.checkIn)),
                    _row("Check Out", _formatDate(b.checkOut)),
                    _row("Guests", "2 Adults, 1 Room"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Payment Summary Card
              _buildCard(
                child: Column(
                  children: [
                    _row("Payment Method", "Online Transfer"),
                    const Divider(thickness: 0.5),
                    _row(
                      "Total Amount Paid", 
                      "\$${b.totalPrice.toStringAsFixed(2)}", 
                      isBold: true, 
                      color: AppColors.primary
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 5. Download Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _simulateDownload(context),
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text("Download PDF Invoice", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 15,
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: child,
    );
  }

  Widget _row(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600, 
            fontSize: 14,
            color: color ?? Colors.black
          )),
        ],
      ),
    );
  }

  Widget _buildGeneralNotification() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.grey).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.notifications_none_rounded, 
              size: 80, 
              color: iconColor ?? Colors.grey
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title ?? "Notification", 
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)
          ),
          const SizedBox(height: 12),
          if (timestamp != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                timestamp!, 
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)
              ),
            ),
          const SizedBox(height: 32),
          Text(
            detailedDescription ?? message ?? "No further details are available for this notification.", 
            textAlign: TextAlign.center, 
            style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.6)
          ),
        ],
      ),
    );
  }

  void _simulateDownload(BuildContext context) {
    // High-quality UX feedback
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invoice saved to Downloads"), 
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      }
    );
  }
}