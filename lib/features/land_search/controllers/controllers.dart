import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landsearch_platform/core/api/api_endpoints.dart';
import 'package:landsearch_platform/core/api/connectivity_service.dart';
import 'package:landsearch_platform/features/land_search/data/models/search_params.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';
import 'package:landsearch_platform/features/land_search/data/repositories/land_search_repository_impl.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:async/async.dart';

import '../data/models/app_status.dart';

class LandSearchController extends GetxController {
  // Dependencies
  final LandRepository _repository;
  final Logger _logger;
  final ConnectivityService _connectivityService;

  // Observables
  final Rx<LandSearchParams> searchFilters = const LandSearchParams().obs;
  final RxList<ProcessedLandData> searchResults = <ProcessedLandData>[].obs;
  final RxList<ProcessedLandData> uploadedSitePlans = <ProcessedLandData>[].obs;
  final RxList<ProcessedLandData> unApprovedSitePlans =
      <ProcessedLandData>[].obs;

  final Rx<ProcessedLandData?> uploadedSitePlan = Rx<ProcessedLandData?>(null);
  final Rx<ProcessedLandData?> selectedMatchSitePlan =
      Rx<ProcessedLandData?>(null);

  final RxList<ProcessedLandData> documentSearchResults =
      <ProcessedLandData>[].obs;
  final RxList<ProcessedLandData> searchResultsUnfiltered =
      <ProcessedLandData>[].obs;
  final RxList<List<RegionData>> regionsData = <List<RegionData>>[].obs;
  final Rx<ProcessedLandData?> selectedSitePlan = Rx<ProcessedLandData?>(null);
  final Rx<ProcessedLandData?> selectedMatchingSitePlan =
      Rx<ProcessedLandData?>(null);
  final Rx<ProcessedLandData?> selectedUnApprovedSitePlan =
      Rx<ProcessedLandData?>(null);
  final Rx<LandSearchStatus> status = LandSearchStatus.idle.obs;
  final Rx<LandSearchUpdateStatus> updateStatus =
      LandSearchUpdateStatus.idle.obs;
  final Rx<LandSearchManagementPageStatus> managementPageStatus =
      LandSearchManagementPageStatus.idle.obs;
  final Rx<SearchStatus> searchStatus = SearchStatus.idle.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool landSearchPageSelected = false.obs;
  final RxInt activePage = 1.obs;
  final RxInt selectedSitePlanIndex = 0.obs;
  final RxInt selectedUnApprovedSitePlanIndex = 0.obs;

  // Search Page
  final RxInt selectedMatchPlansIndex = 0.obs;
  final Rx<CameraPosition?> initialCameraPosition = Rx<CameraPosition?>(null);
  final Rx<CameraPosition?> initialCameraPosition2 = Rx<CameraPosition?>(null);
  final Rx<CameraPosition?> initialCameraPosition3 = Rx<CameraPosition?>(null);
  final Rx<CameraPosition?> initialCameraPosition4 = Rx<CameraPosition?>(null);
  final Rx<CameraPosition?> initialCameraPosition5 = Rx<CameraPosition?>(null);

  // Form controllers
  late TextEditingController searchController;
  late TextEditingController plotNumberController;
  late TextEditingController regionController;
  late TextEditingController districtController;
  late ScrollController scrollController;

  // Internal state
  CancelableOperation<void>? _searchOperation;
  StreamSubscription? _connectivitySubscription;
  Timer? _searchDebouncer;

  // Current land data
  final Rx<ProcessedLandData?> selectedLand = Rx<ProcessedLandData?>(null);
  final RxBool isValidatingPlot = false.obs;

  LandSearchController({
    required LandRepository repository,
    required Logger logger,
    required ConnectivityService connectivityService,
  })  : _repository = repository,
        _logger = logger,
        _connectivityService = connectivityService;

  @override
  void onInit() {
    searchController = TextEditingController();
    plotNumberController = TextEditingController();
    regionController = TextEditingController();
    districtController = TextEditingController();
    scrollController = ScrollController();

    super.onInit();
    _setupConnectivityListener();
    _initializeLoading();
    loadUnApprovedSitePlans();

    initialCameraPosition.value = const CameraPosition(
      target: LatLng(5.6037, -0.1870),
      zoom: 8,
    );

    initialCameraPosition2.value = const CameraPosition(
      target: LatLng(5.6037, -0.1870),
      zoom: 15,
    );

    initialCameraPosition3.value = const CameraPosition(
      target: LatLng(5.6037, -0.1870),
      zoom: 15,
    );

    initialCameraPosition5.value = const CameraPosition(
      target: LatLng(5.6037, -0.1870),
      zoom: 15,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    plotNumberController.dispose();
    regionController.dispose();
    districtController.dispose();
    scrollController.dispose();
    _disposeResources();
    super.onClose();
  }

  // Private methods
  Future<void> _initializeLoading() async {
    try {
      await _loadInitialSitePlans();
    } catch (e, stackTrace) {
      status.value = LandSearchStatus.error;
      _handleError(e, stackTrace, 'Error initializing chat');
    }
  }

  Future<void> _loadInitialSitePlans() async {
    try {
      status.value = LandSearchStatus.loading;
      final sitePlans = await _repository.loadLands("123456");
      await _countItemsByRegion(sitePlans);

      // Reset All
      searchResults.value = [];
      uploadedSitePlans.value = [];
      searchResultsUnfiltered.value = [];

      searchResults.assignAll(sitePlans);
      uploadedSitePlans.addAll(sitePlans);
      searchResultsUnfiltered.addAll(sitePlans);
      if (sitePlans.isNotEmpty) {
        // setSelectedSitePlan(sitePlans.first);
        status.value = LandSearchStatus.success;
      } else {
        status.value = LandSearchStatus.empty;
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Error loading site plans');
    }
  }

  Future<void> loadUnApprovedSitePlans() async {
    try {
      managementPageStatus.value = LandSearchManagementPageStatus.loading;
      const UnApprovedSitePlansParams params =
          UnApprovedSitePlansParams(userId: "123456");
      final sitePlans = await _repository.loadUnApprovedSitePlans(params);
      unApprovedSitePlans.value = [];
      unApprovedSitePlans.addAll(sitePlans);
      if (sitePlans.isNotEmpty) {
        setSelectedUnApprovedSitePlan(sitePlans.first);
        managementPageStatus.value = LandSearchManagementPageStatus.success;
      } else {
        managementPageStatus.value = LandSearchManagementPageStatus.empty;
      }
    } catch (e, stackTrace) {
      managementPageStatus.value = LandSearchManagementPageStatus.error;
      _handleError(e, stackTrace, 'Error loading site plans');
    }
  }

  Future<void> documentSearch(ProcessedLandData searchDoc) async {
    try {
      searchStatus.value = SearchStatus.searching;
      final LandSearchParams params = LandSearchParams(
          coordinates: searchDoc.pointList,
          country: searchDoc.plotInfo.plotNumber);
      final sitePlans = await _repository.searchLands(params);

      documentSearchResults.value = [];
      documentSearchResults.addAll([...sitePlans]);
      if (sitePlans.isNotEmpty) {
        setSelectedUnApprovedSitePlan(sitePlans.first, which: "search");
        searchStatus.value = SearchStatus.success;
      } else {
        searchStatus.value = SearchStatus.empty;
      }
    } catch (e, stackTrace) {
      searchStatus.value = SearchStatus.error;
      _handleError(e, stackTrace, 'Error loading site plans');
    }
  }

  Future<ProcessedLandData?> updateSitePlanCoordinatesGeneral(
      ProcessedLandData data) async {
    try {
      updateStatus.value = LandSearchUpdateStatus.updating;
      final results = await _repository.updateSitePlanCoordinates('12344', data);
      final index = uploadedSitePlans.indexWhere((plan) => plan.id == data.id);
      searchResults[index] = results;
      uploadedSitePlans[index] = results;
      searchResultsUnfiltered[index] = results;
      setSelectedSitePlan(results);
      return results;
    } catch (error) {
      print(error);
    }
    return null;
  }

  Future<ProcessedLandData?> updateSitePlanCoordinates(ProcessedLandData data) async {
    try {
      updateStatus.value = LandSearchUpdateStatus.updating;
      final results = await _repository.updateSitePlanCoordinates('12344', data);
      final index =
          unApprovedSitePlans.indexWhere((plan) => plan.id == data.id);
      unApprovedSitePlans[index] = results;
      setSelectedUnApprovedSitePlan(results, index: index);
      updateStatus.value = LandSearchUpdateStatus.updateComplete;
      return results;
    } catch (error) {
      updateStatus.value = LandSearchUpdateStatus.updateError;
      print(error);
    }

    return null;
  }

  Future<ProcessedLandData?> reComputeCoordinates(
      ProcessedLandData data) async {
    try {
      updateStatus.value = LandSearchUpdateStatus.updating;
      final results = await _repository.updateSitePlanCoordinates('12344', data);
      return results;
    } catch (error) {
      print(error);
    }
    return null;
  }

  Future<void> saveSitePlanGeneral(ProcessedLandData? data) async {
    try {
      if (data != null) {
        final results = await _repository.saveSitePlan('123456', data);
        // final index =
        // uploadedSitePlans.indexWhere((plan) => plan.id == data.id);
        // searchResults[index] = results;
        // uploadedSitePlans[index] = results;
        // searchResultsUnfiltered[index] = results;
        // setSelectedSitePlan(results);
      }
    } catch (error) {
      updateStatus.value = LandSearchUpdateStatus.updateError;
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> saveSitePlan() async {
    try {
      ProcessedLandData? data = selectedUnApprovedSitePlan.value;
      if (data != null) {
        updateStatus.value = LandSearchUpdateStatus.saving;
        final results = await _repository.saveSitePlan('123456', data);
        final index =
            unApprovedSitePlans.indexWhere((plan) => plan.id == data.id);
        unApprovedSitePlans.removeAt(index);
        if (unApprovedSitePlans.length == 1) {
          setSelectedUnApprovedSitePlan(unApprovedSitePlans[0], index: 0);
          selectedUnApprovedSitePlanIndex.value = 0;
        } else if (unApprovedSitePlans.length > 1) {
          final nextIndex = index - 1;
          setSelectedUnApprovedSitePlan(unApprovedSitePlans[nextIndex],
              index: nextIndex);
          selectedUnApprovedSitePlanIndex.value = nextIndex;
        } else {
          setSelectedUnApprovedSitePlan(null, refresh: false);
        }
      }

      if (unApprovedSitePlans.isNotEmpty) {
        updateStatus.value = LandSearchUpdateStatus.updateComplete;
      } else {
        managementPageStatus.value = LandSearchManagementPageStatus.empty;
        _loadInitialSitePlans();
        managementPageStatus.value = LandSearchManagementPageStatus.empty;
      }
    } catch (error) {
      updateStatus.value = LandSearchUpdateStatus.updateError;
      print(error);
    }
  }




  Future<ProcessedLandData?> updateSitePlan(
      ProcessedLandData data) async {
    try {
      updateStatus.value = LandSearchUpdateStatus.updating;
      final results = await _repository.updateSitePlan(data.id!, data);
      final index = uploadedSitePlans.indexWhere((plan) => plan.id == data.id);
      searchResults[index] = results;
      uploadedSitePlans[index] = results;
      searchResultsUnfiltered[index] = results;
      setSelectedSitePlan(results);
      updateStatus.value = LandSearchUpdateStatus.success;
      return results;
    } catch (error) {
      print(error);
    }
    return null;
  }



  Future<void> deleteSitePlan(
      ProcessedLandData data) async {
    try {
      updateStatus.value = LandSearchUpdateStatus.updating;
      await _repository.deleteSitePlan(data);
      final index = uploadedSitePlans.indexWhere((plan) => plan.id == data.id);
      searchResults.removeAt(index);
      uploadedSitePlans.removeAt(index);
      searchResultsUnfiltered.removeAt(index);
      // setSelectedSitePlan(results);
      updateStatus.value = LandSearchUpdateStatus.updateComplete;
    } catch (error) {
      print(error);
    }
    return null;
  }

  Future<void> deleteUnapprovedSitePlan(
      ProcessedLandData data) async {
    try {
      updateStatus.value = LandSearchUpdateStatus.updating;
      await _repository.deleteUnapprovedSitePlan(data);
      final index =
      unApprovedSitePlans.indexWhere((plan) => plan.id == data.id);
      unApprovedSitePlans.removeAt(index);
      // setSelectedUnApprovedSitePlan(results, index: index);
      updateStatus.value = LandSearchUpdateStatus.updateComplete;
    } catch (error) {
      print(error);
    }
    return null;
  }

  CameraPosition getCenterPoints(List<ProcessedLandData> data) {
    List<List<double>> allPoints = [];
    for (var land in data) {
      // Check if point_list exists and is not empty
      if (land.pointList.isNotEmpty) {
        allPoints.addAll(
            land.pointList.map((point) => [point.latitude, point.longitude]));
      }
    }

    double centerLat =
        allPoints.map((p) => p[0]).reduce((a, b) => a + b) / allPoints.length;
    double centerLon =
        allPoints.map((p) => p[1]).reduce((a, b) => a + b) / allPoints.length;
    _logger.i([centerLon, centerLat]);

    return CameraPosition(
      target: LatLng(centerLat, centerLon),
      zoom: 15,
    );
  }

  Future<void> computeCenterPoints(List<ProcessedLandData> data,
      {String whichMap = "search"}) async {
    await _computeCenterPoints(data, whichMap: whichMap);
  }

  Future<void> _computeCenterPoints(List<ProcessedLandData> data,
      {String whichMap = "search"}) async {
    List<List<double>> allPoints = [];
    for (var land in data) {
      // Check if point_list exists and is not empty
      if (land.pointList.isNotEmpty) {
        allPoints.addAll(
            land.pointList.map((point) => [point.latitude, point.longitude]));
      }
    }

    double centerLat =
        allPoints.map((p) => p[0]).reduce((a, b) => a + b) / allPoints.length;
    double centerLon =
        allPoints.map((p) => p[1]).reduce((a, b) => a + b) / allPoints.length;
    _logger.i([centerLon, centerLat]);

    if (whichMap != "search") {
      initialCameraPosition2.value = CameraPosition(
        target: LatLng(centerLat, centerLon),
        zoom: 15,
      );
    }

    if (whichMap == "explorer") {
      initialCameraPosition.value = CameraPosition(
        target: LatLng(centerLat, centerLon),
        zoom: 8,
      );
      refreshMapMainPage();
    }

    if (whichMap == "preview") {
      initialCameraPosition4.value = CameraPosition(
        target: LatLng(centerLat, centerLon),
        zoom: 15,
      );
    } else {
      initialCameraPosition3.value = CameraPosition(
        target: LatLng(centerLat, centerLon),
        zoom: 15,
      );
    }
  }

  Future<void> _countItemsByRegion(List<ProcessedLandData> data) async {
    Map<String, int> regionCounts = {};
    List<RegionData> regions = [];

    for (var item in data) {
      String? region = item.plotInfo.region;
      if (regionCounts.containsKey(region) && region != null) {
        regionCounts[region] = regionCounts[region]! + 1;
      } else {
        if (region != null) {
          regionCounts[region] = 1;
        }
      }
    }

    regions.addAll(regionCounts.entries.map(
      (entry) => RegionData(
          name: entry.key, image: 'map.jpeg', activePlots: entry.value),
    ));

    if (regions.isNotEmpty) {
      regions.add(
          RegionData(name: "All", image: 'map.jpeg', activePlots: data.length));
      regionsData.assign(regions.reversed.toList());
    }
  }

  void setSelectedSitePlan(ProcessedLandData sitePlan, {bool refresh = true}) {
    selectedSitePlan.value = sitePlan;
    selectedSitePlanIndex.value = 1;
    _computeCenterPoints([sitePlan], whichMap: "upload");
    if (refresh) {
      refreshMapMainPage();
    }
  }

  void setSelectedUnApprovedSitePlan(ProcessedLandData? sitePlan,
      {bool refresh = true, int index = 0, String which = "manager"}) {
    if (which == "manager") {
      selectedUnApprovedSitePlan.value = sitePlan;
      selectedUnApprovedSitePlanIndex.value = index;
      if (sitePlan != null) {
        _computeCenterPoints([sitePlan], whichMap: "upload");
      }
      if (refresh) {
        refreshMap();
      }
    } else {
      selectedMatchingSitePlan.value = sitePlan;
      selectedMatchPlansIndex.value = index;
      if (sitePlan != null) {
        _computeCenterPoints([sitePlan], whichMap: "search");
      }
      if (refresh) {
        refreshMap(which: "search");
      }
    }
  }

  void nextSitePlan({String which = "manager"}) {
    if (which == "manager") {
      if (unApprovedSitePlans.isNotEmpty &
          ((selectedUnApprovedSitePlanIndex.value + 1) <
              unApprovedSitePlans.length)) {
        selectedUnApprovedSitePlanIndex.value =
            selectedUnApprovedSitePlanIndex.value + 1;

        selectedUnApprovedSitePlan.value =
            unApprovedSitePlans[selectedUnApprovedSitePlanIndex.value];
        _computeCenterPoints([selectedUnApprovedSitePlan.value!],
            whichMap: "upload");
        // refreshMap();
      }
    } else {
      if (documentSearchResults.isNotEmpty &
          ((selectedMatchPlansIndex.value + 1) <
              documentSearchResults.length)) {
        selectedMatchPlansIndex.value = selectedMatchPlansIndex.value + 1;

        selectedMatchingSitePlan.value =
            documentSearchResults[selectedMatchPlansIndex.value];
        _computeCenterPoints([selectedMatchingSitePlan.value!],
            whichMap: "search");
        // refreshMap(which: "search");
      }
    }
  }

  void previousSitePlan({which = "manager"}) {
    if (which == "manager") {
      if (unApprovedSitePlans.isNotEmpty &
          (selectedUnApprovedSitePlanIndex.value > 0)) {
        selectedUnApprovedSitePlanIndex.value =
            selectedUnApprovedSitePlanIndex.value - 1;

        selectedUnApprovedSitePlan.value =
            unApprovedSitePlans[selectedUnApprovedSitePlanIndex.value];
        _computeCenterPoints([selectedUnApprovedSitePlan.value!],
            whichMap: "upload");
        // refreshMap();
      }
    } else {
      if (documentSearchResults.isNotEmpty &
          (selectedMatchPlansIndex.value > 0)) {
        selectedMatchPlansIndex.value = selectedMatchPlansIndex.value - 1;

        selectedMatchingSitePlan.value =
            documentSearchResults[selectedMatchPlansIndex.value];
        _computeCenterPoints([selectedMatchingSitePlan.value!],
            whichMap: "search");
        // refreshMap(which: "search");
      }
    }
  }

  void refreshMapMainPage() {
    status.value = LandSearchStatus.loading;
    Future.delayed(const Duration(microseconds: 1)).then((val) {
      status.value = LandSearchStatus.success;
    });
  }

  void refreshMap({String which = "manager"}) {
    if (which == "manager") {
      managementPageStatus.value = LandSearchManagementPageStatus.loading;
      Future.delayed(const Duration(microseconds: 1)).then((val) {
        managementPageStatus.value = LandSearchManagementPageStatus.success;
      });
    } else {
      searchStatus.value = SearchStatus.loading;
      Future.delayed(const Duration(microseconds: 1)).then((val) {
        searchStatus.value = SearchStatus.success;
      });
    }
  }

  void setActivePage(int page) {
    activePage.value = page;
  }

  // Public methods

  /// Search for lands
  Future<void> searchLands({
    String? country,
    String? locality,
    String? district,
    int? searchRadius,
    String? match,
    List<PointList?>? coordinates,
  }) async {
    try {
      await _searchOperation?.cancel();
      // status.value = LandSearchStatus.searching;
      isSearching.value = true;

      final filters = searchFilters.value.copyWith(
        country: country,
        locality: locality,
        district: district,
        searchRadius: searchRadius,
        match: match,
        coordinates: coordinates,
      );

      searchFilters.value = filters; // Update the current filters

      final List<ProcessedLandData> results =
          searchResultsUnfiltered.where((plot) {
        final plotInfo = plot.plotInfo;
        bool matches = true;
        bool plotNumberMatch = true;
        bool localityMatch = true;
        bool districtMatch = true;
        bool regionMatch = true;

        if (match == null || match == "all") {
          return true;
        }

        if (plotInfo.plotNumber != null && match.length >= 2) {
          plotNumberMatch &= plotInfo.plotNumber!.contains(match);
        }
        //
        if (plotInfo.locality != null && match.length >= 2) {
          localityMatch &= plotInfo.locality!.contains(match);
        }

        if (plotInfo.district != null && match.length >= 2) {
          districtMatch &= plotInfo.district!.contains(match);
        }

        if (plotInfo.region != null && match.length >= 2) {
          regionMatch &= plotInfo.region!.toLowerCase().contains(match);
        }

        return plotNumberMatch || localityMatch || districtMatch || regionMatch;
      }).toList();

      searchResults.value = [];
      searchResults.assignAll(results);
      if (results.isNotEmpty) {
        await _computeCenterPoints(results, whichMap: "explorer");
      }

      _logger.i('Search completed: ${results.length} results found');
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Error searching lands');
    } finally {
      isSearching.value = false;
      _searchOperation = null;
    }
  }

  /// Upload new land data
  Future<void> uploadLand(ProcessedLandData landData) async {
    try {
      updateStatus.value = LandSearchUpdateStatus.uploading;
      isUploading.value = true;

      final response = await _repository.uploadLand(landData);
      selectedLand.value = response.processedData;

      status.value = LandSearchStatus.success;
      _logger.i('Land data uploaded successfully: ${response.id}');

      Get.snackbar(
        'Success',
        'Land data uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Error uploading land data');
    } finally {
      isUploading.value = false;
    }
  }

  /// Validate plot number
  Future<void> validatePlotNumber(String plotNumber) async {
    try {
      isValidatingPlot.value = true;

      final validation = await _repository.validatePlotNumber(plotNumber);

      if (!validation.isValid) {
        Get.snackbar(
          'Invalid Plot',
          validation.errorMessage ?? 'Invalid plot number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Error validating plot number');
    } finally {
      isValidatingPlot.value = false;
    }
  }

  /// Upload document
  Future<void> uploadDocument(File file, String landId, {String? type}) async {
    try {
      updateStatus.value = LandSearchUpdateStatus.uploading;

      final response = await _repository.uploadDocument(
        file: file,
        landId: landId,
        documentType: type,
      );

      _logger.i('Document uploaded successfully: ${response.documentId}');

      Get.snackbar(
        'Success',
        'Document uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Error uploading document');
    } finally {
      status.value = LandSearchStatus.success;
    }
  }

  /// Get land details
  Future<void> getLandDetails(String id) async {
    try {
      status.value = LandSearchStatus.loading;

      final landData = await _repository.getLandById(id);
      selectedLand.value = landData;

      status.value = LandSearchStatus.success;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Error fetching land details');
    }
  }

  // Search input handling
  // void onSearchInputChanged(String value) {
  //   _searchDebouncer?.cancel();
  //   _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
  //     if (value.isNotEmpty) {
  //       searchLands(query: value);
  //     }
  //   });
  // }

  // Error handling
  // void retry() {
  //   errorMessage.value = '';
  //   status.value = LandSearchStatus.idle;
  //   if (searchController.text.isNotEmpty) {
  //     searchLands(query: searchController.text);
  //   }
  // }

  // Add method to update coordinates
  void updateSearchCoordinates(List<PointList?> coordinates) {
    final updatedFilters =
        searchFilters.value.copyWith(coordinates: coordinates);
    searchFilters.value = updatedFilters;
    searchLands(coordinates: coordinates);
  }

  // Add method to clear filters
  void clearSearchFilters() {
    searchFilters.value = const LandSearchParams();
    searchLands();
  }

  void clearError() {
    errorMessage.value = '';
    status.value = LandSearchStatus.idle;
  }

  // Private methods
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      status.value = LandSearchStatus.noConnection;
      Get.snackbar(
        'No Connection',
        'Please check your internet connection',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else if (status.value == LandSearchStatus.noConnection) {
      status.value = LandSearchStatus.idle;
      // retry();
    }
  }

  void _handleError(dynamic error, StackTrace stackTrace, String context) {
    _logger.e(context, error: error, stackTrace: stackTrace);

    if (error is LandApiException) {
      errorMessage.value = error.message;
    } else {
      errorMessage.value = 'An unexpected error occurred';
    }

    status.value = LandSearchStatus.error;

    Get.snackbar(
      'Error',
      errorMessage.value,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _disposeResources() {
    _searchOperation?.cancel();
    _searchDebouncer?.cancel();
    _connectivitySubscription?.cancel();
  }
}
