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
    final titleStyle = const TextStyle(fontWeight: FontWeight.bold);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _isExpanded ? AppColors.background : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: border,
      ),
      child: ExpansionTile(
        maintainState: true,
        initiallyExpanded: _isExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(widget.group.title, style: titleStyle),
        trailing: Icon(
          _isExpanded ? Icons.remove : Icons.add,
          color: AppColors.textMuted,
        ),
        onExpansionChanged: (value) {
          setState(() {
            _isExpanded = value;
          });
        },
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: widget.group.items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 12),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
