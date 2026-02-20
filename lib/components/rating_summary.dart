import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/models.dart';

class RatingSummaryCard extends StatelessWidget {
  // ✅ This matches the call: return RatingSummaryCard(summary: snapshot.data!)
  final RatingSummary summary; 

  const RatingSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          // Left side: Big Number Average
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                "out of 5", 
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)
              ),
              const SizedBox(height: 8),
              Text(
                "${summary.totalReviews} Reviews", 
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 13,
                  color: AppColors.textPrimary,
                )
              ),
            ],
          ),
          const SizedBox(width: 24),
          
          // Right side: Progress Bars for 1-5 stars
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                // index 0 = 5 stars, index 4 = 1 star
                int starLevel = 5 - index;
                
                // ✅ Calculates the percentage for the progress bar safely.
                // If totalReviews is 0, percentage is 0.0 to avoid division by zero errors.
                double percent = summary.totalReviews > 0 
                    ? summary.getPercentForStar(starLevel) 
                    : 0.0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        "$starLevel", 
                        style: const TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        )
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: Colors.grey[200],
                            color: AppColors.primary,
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}