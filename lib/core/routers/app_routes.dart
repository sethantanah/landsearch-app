// lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:landsearch_platform/features/land_search/presentation/pages/explorer_dashboard.dart';

class AppRoutes {
  static const String home = '/';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const ExplorerDashboard(),
      };
}