import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:landsearch_platform/core/api/api_interface.dart';
import 'package:landsearch_platform/features/land_search/data/models/search_params.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'api_endpoints.g.dart';

/// Custom exception for land API related errors
class LandApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic data;

  LandApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.data,
  });

  @override
  String toString() =>
      'LandApiException: $message (Code: $code, Status: $statusCode)';
}

/// Response wrapper for API calls
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? message;
  final String? errorCode;

  ApiResponse({
    this.data,
    required this.success,
    this.message,
    this.errorCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      success: json['success'] as bool,
      message: json['message'] as String?,
      errorCode: json['errorCode'] as String?,
    );
  }

  factory ApiResponse.error(String message, [String? errorCode]) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }
}

/// Retry interceptor for handling network issues
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Logger logger;
  final int retries;

  RetryInterceptor({
    required this.dio,
    required this.logger,
    this.retries = 3,
  });

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    var extra = err.requestOptions.extra;
    var retriesCount = extra['retries'] ?? 0;

    if (_shouldRetry(err) && retriesCount < retries) {
      logger.w('Retrying request (${retriesCount + 1}/$retries)');
      await Future.delayed(Duration(seconds: pow(2, retriesCount).toInt()));

      try {
        extra['retries'] = retriesCount + 1;
        final response = await _retry(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return super.onError(err, handler);
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.type == DioExceptionType.connectionError &&
            err.error is SocketException);
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      extra: requestOptions.extra,
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

/// Token interceptor for adding authentication
class TokenInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Add your token logic here
      // final token = await _secureStorage.read(key: 'auth_token');
      // if (token != null) {
      //   options.headers['Authorization'] = 'Bearer $token';
      // }
      return super.onRequest(options, handler);
    } catch (e) {
      return super.onRequest(options, handler);
    }
  }
}

/// API Service Implementation
@singleton
class LandApiService {
  static const int defaultTimeout = 30000; // 30 seconds
  static const int maxRetries = 3;

  final LandApiInterface _api;
  final Logger _logger;
  final Connectivity _connectivity;

  LandApiService({
    required LandApiInterface api,
    required Logger logger,
    required Connectivity connectivity,
  })  : _api = api,
        _logger = logger,
        _connectivity = connectivity;

  @factoryMethod
  static LandApiService create(
    Dio dio, {
    required String baseUrl,
    required Logger logger,
    required Connectivity connectivity,
  }) {
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: defaultTimeout),
      receiveTimeout: const Duration(milliseconds: defaultTimeout),
      sendTimeout: const Duration(milliseconds: defaultTimeout),
      headers: {'Content-Type': 'application/json'},
    );

    dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => logger.d(object.toString()),
      ),
      RetryInterceptor(
        dio: dio,
        logger: logger,
        retries: maxRetries,
      ),
      TokenInterceptor(),
    ]);

    final api = LandApiInterface(dio, baseUrl: baseUrl);

    return LandApiService(
      api: api,
      logger: logger,
      connectivity: connectivity,
    );
  }

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _handleDioError(DioException e, String context) {
    _logger.e('$context: ${e.message}', error: e, stackTrace: e.stackTrace);

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    throw LandApiException(
      message: e.message ?? context,
      code: data?['errorCode'] ?? 'UNKNOWN_ERROR',
      statusCode: statusCode,
      data: data,
    );
  }

  void _handleError(dynamic e, StackTrace stackTrace, String context) {
    _logger.e(context, error: e, stackTrace: stackTrace);

    throw LandApiException(
      message: context,
      code: 'UNKNOWN_ERROR',
    );
  }

  Future<ProcessedLandData> getLandById(String id) async {
    try {
      if (!await _hasInternetConnection()) {
        throw LandApiException(
          message: 'No internet connection',
          code: 'NO_INTERNET',
        );
      }

      _logger.i('Fetching land details: $id');
      final response = await _api.getLandById(landId: id);

      if (!response.success) {
        throw LandApiException(
          message: response.message ?? 'Failed to fetch land details',
          code: response.message,
        );
      }

      _logger.d('Land details fetched successfully: $id');
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e, 'Error fetching land details');
      rethrow;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Unexpected error fetching land details');
      rethrow;
    }
  }

  Future<List<ProcessedLandData>> loadLands(String userId, LandSearchParams params) async {
    try {
      if (!await _hasInternetConnection()) {
        throw LandApiException(
          message: 'No internet connection',
          code: 'NO_INTERNET',
        );
      }

      _logger.i('Loading site plans');
      final response = await _api.loadLands(userId: userId, params: params);

      if (!response.success) {
        throw LandApiException(
          message: response.message ?? 'Failed to load site plans',
          code: response.message,
        );
      }

      return response.data.items;
    } on DioException catch (e) {
      _handleDioError(e, 'Error loading site plans');
      rethrow;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Unexpected error loading site plans');
      rethrow;
    }
  }

  Future<List<ProcessedLandData>> loadUnApprovedSitePlans(
      UnApprovedSitePlansParams params) async {
    try {
      if (!await _hasInternetConnection()) {
        throw LandApiException(
          message: 'No internet connection',
          code: 'NO_INTERNET',
        );
      }

      _logger.i('Loading site plans');
      final response = await _api.loadUnApprovedLands(params: params);

      if (!response.success) {
        throw LandApiException(
          message: response.message ?? 'Failed to load site plans',
          code: response.message,
        );
      }

      return response.data.items;
    } on DioException catch (e) {
      _handleDioError(e, 'Error loading site plans');
      rethrow;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Unexpected error loading site plans');
      rethrow;
    }
  }

  Future<List<ProcessedLandData>> searchLands(LandSearchParams params) async {
    try {
      if (!await _hasInternetConnection()) {
        throw LandApiException(
          message: 'No internet connection',
          code: 'NO_INTERNET',
        );
      }

      _logger.i('Searching lands with params: ${params.toJson()}');
      final response = await _api.searchLands(params: params);

      if (!response.success) {
        throw LandApiException(
          message: response.message ?? 'Failed to search lands',
          code: response.message,
        );
      }

      return response.data.items;
    } on DioException catch (e) {
      _handleDioError(e, 'Error searching lands');
      rethrow;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Unexpected error searching lands');
      rethrow;
    }
  }

  Future<LandUploadResponse> uploadLand(Map<String, dynamic> landData) async {
    try {
      throw Exception("Not Implemented");
      // if (!await _hasInternetConnection()) {
      //   throw LandApiException(
      //     message: 'No internet connection',
      //     code: 'NO_INTERNET',
      //   );
      // }

      // _logger.i('Uploading land data');
      // final response = await _api.uploadLand(landData: landData);

      // if (!response.success) {
      //   throw LandApiException(
      //     message: response.message ?? 'Failed to upload land data',
      //     code: response.message,
      //   );
      // }

      // _logger.d('Land data uploaded successfully');
      // return response.data;
    } on DioException catch (e) {
      _handleDioError(e, 'Error uploading land data');
      rethrow;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Unexpected error uploading land data');
      rethrow;
    }
  }

  Future<DocumentUploadResponse> uploadDocument({
    required File file,
    required String landId,
    String? documentType,
  }) async {
    try {
      if (!await _hasInternetConnection()) {
        throw LandApiException(
          message: 'No internet connection',
          code: 'NO_INTERNET',
        );
      }

      _logger.i('Uploading document for land: $landId');
      final response = await _api.uploadDocument(
        file: file,
        landId: landId,
        documentType: documentType,
      );

      if (!response.success) {
        throw LandApiException(
          message: response.message ?? 'Failed to upload document',
          code: response.message,
        );
      }

      _logger.d('Document uploaded successfully');
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e, 'Error uploading document');
      rethrow;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Unexpected error uploading document');
      rethrow;
    }
  }

  Future<ProcessedLandData> updateSitePlan(
      ProcessedLandData landData, String landId) async {
    try {
      if (!await _hasInternetConnection()) {
        throw LandApiException(
          message: 'No internet connection',
          code: 'NO_INTERNET',
        );
      }

      _logger.i('Updating land data');
      final response =
          await _api.updateLand(landData: landData, landId: landId);

      if (!response.success) {
        throw LandApiException(
          message: response.message ?? 'Failed to update land data',
          code: response.message,
        );
      }

      _logger.d('Land data update successfully');
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e, 'Error updating land data');
      rethrow;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Unexpected error updating land data');
      rethrow;
    }
  }


  Future<ProcessedLandData> saveSitePlan(
      ProcessedLandData landData, String userId) async {
    try {
      if (!await _hasInternetConnection()) {
        throw LandApiException(
          message: 'No internet connection',
          code: 'NO_INTERNET',
        );
      }

      _logger.i('Saving land data');
      final response =
      await _api.saveSitePlanData(landData: landData, userId: userId);

      if (!response.success) {
        throw LandApiException(
          message: response.message ?? 'Failed to save land data',
          code: response.message,
        );
      }

      _logger.d('Land data saved successfully');
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e, 'Error save land data');
      rethrow;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Unexpected error save land data');
      rethrow;
    }
  }
}
