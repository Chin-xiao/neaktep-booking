import 'package:flutter/material.dart';
import '../../utils/models.dart';
import '../../services/hotel_service.dart';

class BookingInvoiceSheet {
  static void show(BuildContext context, Booking booking, VoidCallback onRefresh) {
    final HotelService hotelService = HotelService();
    bool isCancelling = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            // ✅ FIX: Ensures the sheet isn't hidden by the keyboard/system bottom bar
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "INVOICE", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                const Divider(height: 30),
                
                _buildRow("Hotel:", booking.hotel.name),
                _buildRow("Check-In:", "${booking.checkIn.toLocal()}".split(' ')[0]),
                
                // ✅ FIX: Standard Divider (dashArray is not part of standard Divider)
                const Divider(height: 30, thickness: 1),
                
                _buildRow(
                  "Total:", 
                  "\$${booking.totalPrice.toStringAsFixed(2)}", 
                  color: Colors.green
                ),
                
                const SizedBox(height: 30),
                
                if (booking.status.toLowerCase() != 'cancelled') 
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                      onPressed: isCancelling 
                        ? null 
                        : () async {
                            setSheetState(() => isCancelling = true);
                            
                            // ✅ FIX: Ensure hotelService has cancelBooking(int)
                            bool success = await hotelService.cancelBooking(booking.id);
                            
                            if (success) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                onRefresh();
                              }
                            } else {
                              setSheetState(() => isCancelling = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Error cancelling booking")),
                                );
                              }
                            }
                          },
                      child: isCancelling 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text(
                            "Cancel Booking", 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                    ),
                  ),
              ],
            ),
          );
        }
      ),
    );
  }

  static Widget _buildRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value, 
            style: TextStyle(color: color, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}