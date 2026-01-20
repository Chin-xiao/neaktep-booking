import 'package:flutter/material.dart';

import '../components/facility_group_tile.dart';
import '../layout/round_icon_button.dart';
import '../services/hotel_service.dart';
import '../utils/app_colors.dart';
import '../utils/models.dart';

class FacilityPage extends StatefulWidget {
  const FacilityPage({super.key});

  @override
  State<FacilityPage> createState() => _FacilityPageState();
}

class _FacilityPageState extends State<FacilityPage> {
  final HotelService _hotelService = HotelService();
  late final Future<List<FacilityGroup>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _hotelService.fetchFacilityGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: RoundIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'All Facilities',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FacilityGroup>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final groups = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            children: groups.asMap().entries.map((entry) {
              final index = entry.key;
              final group = entry.value;
              return FacilityGroupTile(
                group: group,
                expanded: index == 0,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
