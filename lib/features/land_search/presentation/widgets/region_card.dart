// lib/features/land_search/presentation/widgets/region_card.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RegionCard extends StatefulWidget {
  final String name;
  final String image;
  final int activePlots;
  final Function onTap;

  const RegionCard(
      {super.key,
      required this.name,
      required this.image,
      required this.activePlots,
      required this.onTap});

  @override
  State<RegionCard> createState() => _RegionCardState();
}

class _RegionCardState extends State<RegionCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        radius: 12,
        onTap: (){widget.onTap();},
        child: Ink(
          color: Colors.transparent,
          child: Container(
            width: 180,
            // margin: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // image: DecorationImage(
              //   image: AssetImage("images/${widget.image}"),
              //   fit: BoxFit.cover,
              // ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.1),
              //     blurRadius: 8,
              //     offset: const Offset(0, 2),
              //   ),
              // ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.activePlots} registered plots',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
