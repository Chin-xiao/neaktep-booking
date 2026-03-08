import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/models.dart';

class FacilityGroupTile extends StatefulWidget {
  final FacilityGroup group;
  final bool expanded;

  const FacilityGroupTile({
    super.key,
    required this.group,
    this.expanded = false,
  });

  @override
  State<FacilityGroupTile> createState() => _FacilityGroupTileState();
}

class _FacilityGroupTileState extends State<FacilityGroupTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expanded;
  }

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: AppColors.divider);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _isExpanded ? Colors.white : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: border,
      ),
      child: Theme(
        // This removes the highlight color and the border lines from ExpansionTile
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          maintainState: true,
          initiallyExpanded: _isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          
          // Match the container corners
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          
          title: Text(
            widget.group.title, 
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          trailing: Icon(
            _isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
            color: _isExpanded ? AppColors.primary : AppColors.textMuted,
          ),
          
          onExpansionChanged: (value) {
            setState(() => _isExpanded = value);
          },
          
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          // map through 'facilities' list from your model
          children: widget.group.facilities.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}