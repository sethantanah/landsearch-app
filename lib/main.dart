// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:landsearch_platform/core/api/api_endpoints.dart';
import 'package:landsearch_platform/core/api/api_interface.dart';
import 'package:landsearch_platform/core/api/connectivity_service.dart';
import 'package:landsearch_platform/core/theme/app_colors.dart';
import 'package:landsearch_platform/features/land_search/controllers/controllers.dart';
import 'package:landsearch_platform/features/land_search/data/models/hive_adapters.dart';
import 'package:landsearch_platform/features/land_search/data/models/search_params.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';
import 'package:landsearch_platform/features/land_search/data/repositories/land_search_repository_impl.dart';
import 'package:landsearch_platform/features/land_search/data/repositories/local_storage.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'config/environment_config.dart';
import 'features/land_search/presentation/pages/home_page.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Setup system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependencies
  await initDependencies();

  runApp(const MainApp());
}

Future<void> initDependencies() async {
  // Register Hive Adapters
  registerHiveAdapters();

  // Open Hive Boxes
  final landBox = await Hive.openBox<ProcessedLandData>('lands');
  final searchBox = await Hive.openBox<LandSearchParams>('search_history');
  final validationBox =
      await Hive.openBox<PlotValidationResponse>('validations');
  final documentBox = await Hive.openBox<LandDocument>('documents');
  final pendingUploadBox = await Hive.openBox<PendingUpload>('pending_uploads');

  // Setup Get bindings for boxes
  Get.lazyPut(() => landBox, tag: 'landBox');
  Get.lazyPut(() => searchBox, tag: 'searchBox');
  Get.lazyPut(() => validationBox, tag: 'validationBox');
  Get.lazyPut(() => documentBox, tag: 'documentBox');
  Get.lazyPut(() => pendingUploadBox, tag: 'pendingUploadBox');

  // Initialize Dio
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(milliseconds: 30000),
    receiveTimeout: const Duration(milliseconds: 30000),
    sendTimeout: const Duration(milliseconds: 30000),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Add interceptors
  dio.interceptors.addAll([
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => debugPrint(object.toString()),
    ),
  ]);

  // Setup dependencies
  Get.put(Logger());
  Get.lazyPut(() => Connectivity());
  Get.put<ConnectivityService>(ConnectivityServiceImpl());

  // Initialize API service
  Get.put(LandApiService.create(
    dio,
    baseUrl: API_BASE_URL,
    logger: Get.find<Logger>(),
    connectivity: Get.find<Connectivity>(),
  ));

  // Initialize Storage service with all boxes
  Get.put(LandLocalStorageService(
    Get.find(tag: 'landBox'),
    Get.find(tag: 'searchBox'),
    Get.find(tag: 'validationBox'),
    Get.find(tag: 'documentBox'),
    Get.find(tag: 'pendingUploadBox'),
  ));

  // Initialize Repository
  Get.put<LandRepository>(
    LandRepositoryImpl(
      apiService: Get.find(),
      storageService: Get.find(),
    ),
  );

  // Initialize Controller
  Get.put(
    LandSearchController(
      repository: Get.find(),
      logger: Get.find(),
      connectivityService: Get.find(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Land Search',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      home: const AppScaffold(),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}

// Background pattern painter
class BackgroundPatternPainter extends CustomPainter {
  final Color color;
  final double spacing;

  BackgroundPatternPainter({
    required this.color,
    this.spacing = 30,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) =>
      color != oldDelegate.color || spacing != oldDelegate.spacing;
}
