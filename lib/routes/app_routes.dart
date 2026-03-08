import 'package:flutter/material.dart';

// ✅ 1. IMPORT FIX:
// Ensure this points to the correct location of your detail screen file.
import '../pages/detail_page.dart';
import '../pages/filter_page.dart';
import '../pages/search_page.dart';
import '../pages/reviews_page.dart';
import '../pages/facility_page.dart';
import '../screens/booking_summary_screen.dart';
import '../utils/models.dart';

class AppRoutes {
  static const String search = '/search';
  static const String filter = '/filter';
  static const String detail = '/detail';
  static const String reviews = '/reviews';
  static const String facilities = '/facilities';

  static Route toSearch() {
    return MaterialPageRoute(
      builder: (_) => const SearchPage(),
      settings: const RouteSettings(name: search),
    );
  }

  static Route<FilterState> toFilter(FilterState initial) {
    return _slideFromBottom<FilterState>(
      FilterPage(initial: initial),
      settings: const RouteSettings(name: filter),
    );
  }

  /// ✅ 2. CONSTRUCTOR FIX:
  /// Passes the 'hotel' object into the named parameter 'hotel'.
  static Route<void> toDetail(Hotel hotel) {
    return _fadeScale(
      HotelDetailScreen(
        hotel: hotel,
      ), // ✅ This calls the class inside detail_page.dart
      settings: const RouteSettings(name: detail),
    );
  }

  static Route<void> toReviews({String? hotelId}) {
    return _slideFromRight(
      ReviewsPage(hotelId: hotelId),
      settings: const RouteSettings(name: reviews),
    );
  }

  static Route<void> toFacilities() {
    return _slideFromRight(
      const FacilityPage(),
      settings: const RouteSettings(name: facilities),
    );
  }

  static Route<void> toBookingSummary(Hotel hotel) {
    return _slideFromRight(
      BookingSummaryScreen(hotel: hotel),
      settings: const RouteSettings(name: '/bookingSummary'),
    );
  }

  // --- Animation Builders ---

  static PageRouteBuilder<T> _slideFromRight<T>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetTween = Tween<Offset>(
          begin: const Offset(0.15, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(offsetTween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  static PageRouteBuilder<T> _slideFromBottom<T>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetTween = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(offsetTween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  static PageRouteBuilder<T> _fadeScale<T>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleTween = Tween<double>(
          begin: 0.98,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
    );
  }
}
