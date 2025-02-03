// lib/features/land_search/presentation/pages/explorer_dashboard.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:landsearch_platform/features/land_search/presentation/pages/upload_manager_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/controllers.dart';
import 'document_search_page.dart';
import 'explorer_dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LandSearchController _landSearchController = Get.find();

  @override
  void initState() {
    super.initState();
    // Initialize search with default parameters if needed
    _landSearchController.searchLands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar with Animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 220,
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Animated Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder(
                        tween: ColorTween(
                          begin: AppColors.primary.withOpacity(0.5),
                          end: AppColors.primary,
                        ),
                        duration: const Duration(seconds: 2),
                        builder: (context, Color? color, child) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'PD',
                              style: TextStyle(
                                color: color,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Enhanced Navigation Items
                Obx(() {
                  return Column(
                    children: [
                      _buildNavigationItem(
                        icon: "images/database-upload-gray.png",
                        title: 'Add to Database',
                        onTap: () {
                          _landSearchController.setActivePage(0);
                        },
                        isSelected: _landSearchController.activePage.value == 0,
                      ),
                      _buildNavigationItem(
                        icon: "images/database-gray.png",
                        title: 'View Database',
                        onTap: () {
                          _landSearchController.setActivePage(1);
                        },
                        isSelected: _landSearchController.activePage.value == 1,
                      )
                    ],
                  );
                })
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Enhanced Top Navigation Bar
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Spacer(),
                      _buildTopBarIcon(
                        icon: Icons.notifications_outlined,
                        onTap: () {},
                        badge: '3',
                      ),
                      _buildTopBarIcon(
                        icon: Icons.settings_outlined,
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundImage:
                                NetworkImage('https://via.placeholder.com/36'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Obx(() {
                  return _landSearchController.activePage.value == 0
                      ? const Expanded(child: UploadManager())
                      : _landSearchController.activePage.value == 1
                          ? const Expanded(child: ExplorerDashboard())
                          : _landSearchController.activePage.value == 2
                              ? const Expanded(child: DocumentSearchDashboard())
                              : const Center(
                                  child: CircularProgressIndicator(),
                                );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper Widgets
  Widget _buildNavigationItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected, // Add this parameter to indicate selection
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Material(
        color: isSelected
            ? AppColors.primaryLight.withOpacity(0.1)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              border: isSelected
                  ? const Border(
                      left: BorderSide(
                          color: AppColors.primary, // Blue bar color
                          width: 5 // Width of the blue bar
                          ),
                    )
                  : null, // No border if not selected
            ),
            child: Row(
              children: [
                // Image.asset(icon, width: 20, height: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    // color:  isSelected ? AppColors.white : Colors.black
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBarIcon({
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onTap,
          color: Colors.grey[700],
          hoverColor: AppColors.primary.withOpacity(0.1),
          splashColor: AppColors.primary.withOpacity(0.1),
        ),
        if (badge != null)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
