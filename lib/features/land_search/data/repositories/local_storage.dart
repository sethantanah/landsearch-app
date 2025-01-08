// lib/features/land_search/data/storage/land_local_storage.dart
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:landsearch_platform/core/api/api_interface.dart';
import 'package:landsearch_platform/features/land_search/data/models/hive_adapters.dart';
import 'package:landsearch_platform/features/land_search/data/models/search_params.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';
import 'package:landsearch_platform/features/land_search/data/repositories/land_search_repository_impl.dart';

@injectable
class LandLocalStorageService {
  final Box<ProcessedLandData> _landBox;
  final Box<PlotValidationResponse> _validationBox;
  final Box<LandDocument> _documentBox;
  final Box<PendingUpload> _pendingUploadBox;
  final Box<LandSearchParams> _searchHistoryBox;

  LandLocalStorageService(
    @Named('landBox') this._landBox,
    @Named('searchHistoryBox') this._searchHistoryBox,
    @Named('validationBox') this._validationBox,
    @Named('documentBox') this._documentBox,
    @Named('pendingUploadBox') this._pendingUploadBox,
  );

  // Land Data Operations
  Future<ProcessedLandData?> getLandById(String id) async {
    return _landBox.get(id);
  }

  Future<void> saveLandData(ProcessedLandData landData) async {
    await _landBox.put(landData.id, landData);
  }

  Future<void> updateLandData(ProcessedLandData landData) async {
    await _landBox.put(landData.id, landData);
  }

  Future<void> markLandDataAsPendingUpload(ProcessedLandData landData) async {
    final pendingUpload = PendingUpload(
      id: landData.id ?? DateTime.now().toIso8601String(),
      landData: landData,
      timestamp: DateTime.now(),
      type: 'land',
    );
    await _pendingUploadBox.put(pendingUpload.id, pendingUpload);
  }

  Future<void> markLandDataForSync(String id) async {
    final landData = await getLandById(id);
    if (landData != null) {
      await markLandDataAsPendingUpload(landData);
    }
  }


  // Search Operations
  Future<List<ProcessedLandData>> loadLands() async {
    // Perform local search
    return _landBox.values.where((land) {
      return true;
    }).toList();
  }

  // Search Operations
  Future<List<ProcessedLandData>> searchLands(LandSearchParams filters) async {
    // Save search filters to history
    await _searchHistoryBox.put(
      DateTime.now().toIso8601String(),
      filters,
    );

    // Perform local search
    return _landBox.values.where((land) {
      if (filters.country != null &&
          land.plotInfo.region?.toLowerCase() != filters.country?.toLowerCase()) {
        return false;
      }
      if (filters.locality != null &&
          land.plotInfo.locality?.toLowerCase() != filters.locality?.toLowerCase()) {
        return false;
      }
      if (filters.district != null &&
          land.plotInfo.district?.toLowerCase() != filters.district?.toLowerCase()) {
        return false;
      }
      if (filters.coordinates.isNotEmpty) {
        // Implement coordinate-based filtering if needed
        // This would typically involve checking if the land is within
        // the search radius of any of the provided coordinates
      }
      return true;
    }).toList();
  }

  Future<void> saveSearchResults(List<ProcessedLandData> results) async {
    final Map<String, ProcessedLandData> entries = {
      for (var land in results)
        if (land.id != null) land.id!: land
    };
    await _landBox.putAll(entries);
  }

  // Document Operations
  Future<void> saveDocument(File file, String landId, String? type) async {
    final document = LandDocument(
      id: DateTime.now().toIso8601String(),
      plotId: landId,
      documentType: type ?? 'unknown',
      fileName: file.path.split('/').last,
      url: file.path,
      uploadedAt: DateTime.now(),
      uploadedBy: await getCurrentUserId() ?? 'unknown',
    );
    await _documentBox.put(document.id, document);
  }

  Future<void> updateDocumentStatus(
    String landId,
    String documentId,
    String status,
  ) async {
    final document = _documentBox.get(documentId);
    if (document != null) {
      // Update document status logic here
    }
  }

  Future<void> markDocumentForSync(File file, String landId) async {
    final pendingUpload = PendingUpload(
      id: DateTime.now().toIso8601String(),
      file: file,
      landId: landId,
      timestamp: DateTime.now(),
      type: 'document',
    );
    await _pendingUploadBox.put(pendingUpload.id, pendingUpload);
  }

  // Validation Operations
  Future<PlotValidationResponse?> getPlotValidation(String plotNumber) async {
    return _validationBox.get(plotNumber);
  }

  Future<void> savePlotValidation(
    String plotNumber,
    PlotValidationResponse validation,
  ) async {
    await _validationBox.put(plotNumber, validation);
  }

  // Pending Operations
  Future<List<ProcessedLandData>> getPendingUploads() async {
    return _pendingUploadBox.values
        .where((pending) => pending.type == 'land')
        .map((pending) => pending.landData!)
        .toList();
  }

  Future<List<PendingDocument>> getPendingDocuments() async {
    return _pendingUploadBox.values
        .where((pending) => pending.type == 'document')
        .map((pending) => PendingDocument(
              file: pending.file!,
              landId: pending.landId!,
            ))
        .toList();
  }

  Future<List<LandDocument>> getLandDocuments(String landId) async {
    return _documentBox.values
        .where((doc) => doc.plotId == landId)
        .toList();
  }

  Future<void> saveDocuments(String landId, List<LandDocument> documents) async {
    final Map<String, LandDocument> entries = {
      for (var doc in documents) doc.id: doc
    };
    await _documentBox.putAll(entries);
  }

  // Utility Methods
  Future<String?> getCurrentUserId() async {
    // Implement getting current user ID from secure storage or auth service
    return 'user123';
  }

  // Future<void> clearOldSearchHistory() async {
  //   final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  //   final oldSearches = _searchHistoryBox.values
  //       .where((filters) => filters.timestamp.isBefore(thirtyDaysAgo));
    
  //   for (var filters in oldSearches) {
  //     await _searchHistoryBox.delete(filters.id);
  //   }
  // }
}

@HiveType(typeId: 1)
class PendingUpload {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final ProcessedLandData? landData;

  @HiveField(2)
  final File? file;

  @HiveField(3)
  final String? landId;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String type; // 'land' or 'document'

  PendingUpload({
    required this.id,
    this.landData,
    this.file,
    this.landId,
    required this.timestamp,
    required this.type,
  });
}

// Register Hive Adapters
@module
abstract class StorageModule {
  @preResolve
  Future<Box<ProcessedLandData>> getLandBox() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProcessedLandDataAdapter());
    }
    return await Hive.openBox<ProcessedLandData>('lands');
  }

  @preResolve
  Future<Box<PlotValidationResponse>> getValidationBox() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PlotValidationResponseAdapter());
    }
    return await Hive.openBox<PlotValidationResponse>('validations');
  }

  @preResolve
  Future<Box<LandDocument>> getDocumentBox() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(LandDocumentAdapter());
    }
    return await Hive.openBox<LandDocument>('documents');
  }

  @preResolve
  Future<Box<PendingUpload>> getPendingUploadBox() async {
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PendingUploadAdapter());
    }
    return await Hive.openBox<PendingUpload>('pending_uploads');
  }

  @preResolve
  Future<Box<LandSearchParams>> getSearchHistoryBox() async {
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(LandSearchParamsAdapter());
    }
    return await Hive.openBox<LandSearchParams>('search_history');
  }
}