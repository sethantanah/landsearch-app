// lib/features/land_search/presentation/widgets/custom_map_marker.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomMapMarkerWindow extends StatelessWidget {
  final dynamic land;
  final VoidCallback onViewDetails;

  const CustomMapMarkerWindow({
    super.key,
    required this.land,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final plotInfo = land.plotInfo;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Plot Number
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  plotInfo?.plotNumber ?? 'N/A',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  // Close info window
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Location Details
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plotInfo?.locality ?? 'N/A'),
                Text(
                  '${plotInfo?.district ?? 'N/A'}, ${plotInfo?.region ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Area Details
          _buildInfoRow(
            icon: Icons.square_foot_outlined,
            title: 'Area',
            content: Text(
              '${plotInfo?.area ?? 0} ${plotInfo?.metric ?? ''}',
            ),
          ),
          const SizedBox(height: 8),

          // Date
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Date',
            content: Text(plotInfo?.date ?? 'N/A'),
          ),
          const SizedBox(height: 16),

          // View Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              child: content,
            ),
          ],
        ),
      ],
    );
  }
}
