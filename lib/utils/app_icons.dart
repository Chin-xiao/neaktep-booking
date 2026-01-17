import 'package:flutter/material.dart';

IconData facilityIcon(String facility) {
  switch (facility.toLowerCase()) {
    case 'ac':
      return Icons.ac_unit;
    case 'restaurant':
      return Icons.restaurant;
    case 'swimming pool':
      return Icons.pool;
    case '24-hours front desk':
      return Icons.support_agent;
    case 'free wifi':
      return Icons.wifi;
    case 'tv':
      return Icons.tv;
    case 'laundry':
      return Icons.local_laundry_service;
    default:
      return Icons.check_circle_outline;
  }
}
