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
  late Future<List<FacilityGroup>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    setState(() {
      _groupsFuture = _hotelService.fetchFacilityGroups();
    });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadGroups,
          )
        ],
      ),
      body: FutureBuilder<List<FacilityGroup>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          
          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Text("Error loading facilities: ${snapshot.error}"),
            );
          }

          final groups = snapshot.data ?? [];

          // 3. Empty State
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.layers_clear, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("No facilities available.", 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // 4. Data State
          return ListView.builder( // ListView.builder is better for performance
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return FacilityGroupTile(
                group: groups[index],
                expanded: index == 0,
              );
            },
          );
        },
      ),
    );
  }
}