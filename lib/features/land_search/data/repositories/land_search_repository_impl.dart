// lib/features/land_search/data/repositories/land_repository.dart
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:landsearch_platform/core/api/api_endpoints.dart';
import 'package:landsearch_platform/core/api/api_interface.dart';
import 'package:landsearch_platform/features/land_search/data/models/search_params.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';
import 'package:landsearch_platform/features/land_search/data/repositories/local_storage.dart';

abstract class LandRepository {
  Future<ProcessedLandData> getLandById(String id);
  Future<List<ProcessedLandData>> loadLands(String userId);
  Future<List<ProcessedLandData>> loadUnApprovedSitePlans(
      UnApprovedSitePlansParams params);
  Future<List<ProcessedLandData>> searchLands(LandSearchParams filters);
  Future<LandUploadResponse> uploadLand(ProcessedLandData landData);
  Future<ProcessedLandData> updateLand(String id, ProcessedLandData landData);
  Future<ProcessedLandData> saveSitePlan(String id, ProcessedLandData landData);
  Future<DocumentUploadResponse> uploadDocument({
    required File file,
    required String landId,
    String? documentType,
  });
  Future<PlotValidationResponse> validatePlotNumber(String plotNumber);
  Future<List<LandDocument>> getLandDocuments(String landId);
}

@Injectable()
class LandRepositoryImpl implements LandRepository {
  final LandApiService _apiService;
  final LandLocalStorageService _storageService;

  LandRepositoryImpl({
    required LandApiService apiService,
    required LandLocalStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  @override
  Future<ProcessedLandData> getLandById(String id) async {
    try {
      // First try to get from local storage
      final localData = await _storageService.getLandById(id);
      if (localData != null) {
        return localData;
      }

      // If not in local storage, fetch from API
      final landData = await _apiService.getLandById(id);

      // Save to local storage
      await _storageService.saveLandData(landData);

      return landData;
    } catch (e) {
      // If API call fails, try to get from local storage as fallback
      final localData = await _storageService.getLandById(id);
      if (localData != null) {
        return localData;
      }
      rethrow;
    }
  }

  @override
  Future<List<ProcessedLandData>> loadLands(String userId) async {
    try {
      // First try API search
      LandSearchParams params = LandSearchParams(user: userId);
      final searchResults = await _apiService.loadLands(userId, params);

      // Cache results locally
      // await _storageService.saveSearchResults(searchResults);

      return searchResults;
    } catch (e) {
      // Fall back to local search if API fails
      return await _storageService.loadLands();
    }
  }

  @override
  Future<List<ProcessedLandData>> loadUnApprovedSitePlans(
      UnApprovedSitePlansParams params) async {
    try {
      // First try API search
      final searchResults = await _apiService.loadUnApprovedSitePlans(params);
      return searchResults;
    } catch (e) {
      // Fall back to local search if API fails
      return [];
    }
  }

  @override
  Future<List<ProcessedLandData>> searchLands(LandSearchParams filters) async {
    try {
      // First try API search
      final searchResults = await _apiService
          .searchLands(filters);

      // Cache results locally
      // await _storageService.saveSearchResults(searchResults);

      return searchResults;
    } catch (e) {
      // Fall back to local search if API fails
      return await _storageService.searchLands(filters);
    }
  }

  @override
  Future<LandUploadResponse> uploadLand(ProcessedLandData landData) async {
    try {
      // Save to local storage first
      await _storageService.saveLandData(landData);
      throw Exception("Not Implemented");

      // Upload to server
      // final response = await _apiService.uploadLand(
      //   LandDataRequest(
      //     landData: landData,
      //     userId: await _storageService.getCurrentUserId(),
      //   ),
      // );

      // Update local storage with server response
      // await _storageService.updateLandData(response.processedData);

      // return response;
    } catch (e) {
      // Mark as pending upload in local storage
      await _storageService.markLandDataAsPendingUpload(landData);
      rethrow;
    }
  }

  @override
  Future<ProcessedLandData> updateLand(
      String id, ProcessedLandData landData) async {
    try {
      // Update locally first
      final result = await _apiService.updateSitePlan(landData, id);
      // await _storageService.updateLandData(result);
      return result;
    } catch (e) {
      // Mark for sync later
      // await _storageService.markLandDataForSync(id);
      rethrow;
    }
  }

  @override
  Future<ProcessedLandData> saveSitePlan(
      String id, ProcessedLandData landData) async {
    try {
      // Update locally first
      final result = await _apiService.saveSitePlan(landData, id);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DocumentUploadResponse> uploadDocument({
    required File file,
    required String landId,
    String? documentType,
  }) async {
    try {
      throw Exception("Not Implemented");
      // Store document locally first
      // await _storageService.saveDocument(file, landId, documentType);

      // // Upload to server
      // final response = await _apiService.uploadDocument(
      //   file: file,
      //   landId: landId,
      //   documentType: documentType,
      // );

      // // Update local storage with server response
      // await _storageService.updateDocumentStatus(
      //   landId,
      //   response.id,
      //   'uploaded',
      // );

      // return response;
    } catch (e) {
      // Mark document for sync later
      await _storageService.markDocumentForSync(file, landId);
      rethrow;
    }
  }

  @override
  Future<PlotValidationResponse> validatePlotNumber(String plotNumber) async {
    try {
      throw Exception("Not Implemented");
      // Check local cache first
      // final cachedValidation =
      //     await _storageService.getPlotValidation(plotNumber);
      // if (cachedValidation != null) {
      //   return cachedValidation;
      // }

      // // Validate with server
      // final response = await _apiService.validatePlotNumber(plotNumber);

      // // Cache validation result
      // await _storageService.savePlotValidation(plotNumber, response);

      // return response;
    } catch (e) {
      // Try to get cached validation as fallback
      final cachedValidation =
          await _storageService.getPlotValidation(plotNumber);
      if (cachedValidation != null) {
        return cachedValidation;
      }
      rethrow;
    }
  }

  @override
  Future<List<LandDocument>> getLandDocuments(String landId) async {
    try {
      throw Exception("Not Implemented");
      // // Try to get from API first
      // final documents = await _apiService.getLandDocuments(landId);

      // // Update local cache
      // await _storageService.saveDocuments(landId, documents);

      // return documents;
    } catch (e) {
      // Fall back to locally cached documents
      return await _storageService.getLandDocuments(landId);
    }
  }

  // Helper methods for syncing
  Future<void> syncPendingUploads() async {
    try {
      final pendingLands = await _storageService.getPendingUploads();
      for (final land in pendingLands) {
        try {
          await uploadLand(land);
        } catch (e) {
          print('Failed to sync land data: $e');
        }
      }
    } catch (e) {
      print('Error during land sync: $e');
    }
  }

  Future<void> syncPendingDocuments() async {
    try {
      final pendingDocs = await _storageService.getPendingDocuments();
      for (final doc in pendingDocs) {
        try {
          await uploadDocument(
            file: doc.file,
            landId: doc.landId,
            documentType: doc.type,
          );
        } catch (e) {
          print('Failed to sync document: $e');
        }
      }
    } catch (e) {
      print('Error during document sync: $e');
    }
  }
}

class LandDataRequest {}

class PendingDocument {
  final File file;
  final String landId;
  final String? type;

  PendingDocument({
    required this.file,
    required this.landId,
    this.type,
  });
}
