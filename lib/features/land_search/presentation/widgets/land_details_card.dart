import 'package:flutter/material.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';

import 'edit_siteplan_data.dart';

class LandDetailsInfoWidget extends StatelessWidget {
  final ProcessedLandData? data;
  final bool showEditButton;
  final Function(ProcessedLandData) onSave;
  final Function(ProcessedLandData) onUpdate;
  final Function(ProcessedLandData)? onDelete;

  const LandDetailsInfoWidget({
    super.key,
    required this.data,
    required this.showEditButton,
    required this.onSave,
    required this.onUpdate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            data?.pointList.length == 1
                ? Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 12.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    child: const Text(
                      "Automated extraction failed! Modify with details.",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  )
                : SizedBox(),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                      data?.pointList.length != 1 ? 'PlotId' : 'File Name',
                      data?.plotInfo.plotNumber != null
                          ? "${data?.plotInfo.plotNumber}"
                          : ""),
                ),
                if (showEditButton)
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return PlotForm(
                                actionText: "Save Document",
                                validate: true,
                                landData: data!,
                                onSave: onSave,
                                onUpdate: onUpdate,
                                onDelete: onDelete,
                              );
                            });
                      },
                      icon: const Icon(Icons.edit_outlined)),
              ],
            ),
            _buildDivider(),
            _buildInfoRow('Area',
                data?.plotInfo.area != null ? "${data?.plotInfo.area}" : ""),
            _buildDivider(),
            _buildInfoRow('Metric', data?.plotInfo.metric ?? ""),
            _buildDivider(),
            _buildInfoRow('Locality', data?.plotInfo.locality ?? ""),
            _buildDivider(),
            _buildInfoRow('District', data?.plotInfo.district ?? ""),
            _buildDivider(),
            _buildInfoRow('Region', data?.plotInfo.region ?? ""),
            _buildDivider(),
            _buildInfoRow('Owners', data?.plotInfo.owners.join(" ") ?? ""),
            _buildDivider(),
            _buildInfoRow('Date', data?.plotInfo.date ?? ""),
            _buildDivider(),
            _buildInfoRow('Scale', data?.plotInfo.scale ?? ""),
            _buildDivider(),
            _buildInfoRow('Other Location Details',
                data?.plotInfo.otherLocationDetails ?? ""),
            _buildDivider(),
            _buildInfoRow(
                'Surveyor\'s Name', data?.plotInfo.surveyorsName ?? ""),
            _buildDivider(),
            _buildInfoRow(
                'Surveyor\'s Location', data?.plotInfo.surveyorsLocation ?? ""),
            _buildDivider(),
            _buildInfoRow(
                'Surveyor\'s Reg No.', data?.plotInfo.surveyorsRegNumber ?? ""),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Value
          Expanded(
            flex: 5,
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    // return const Divider(height: 1, color: Colors.grey);
    return const SizedBox();
  }
}
