// lib/features/land_search/data/api/land_api_interface.dart
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:landsearch_platform/features/land_search/data/models/search_params.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';
import 'package:retrofit/retrofit.dart';

part 'api_interface.g.dart';


@RestApi()
abstract class LandApiInterface {
  factory LandApiInterface(Dio dio, {String baseUrl}) = _LandApiInterface;

  @GET('/api/lands/{landId}')
  Future<ApiResponse<ProcessedLandData>> getLandById({
    @Path('landId') required String landId,
  });


@GET('/api/site-plans/all/')
Future<ApiResponse<LandListResponse>> loadLands({
  @Path('userId') required String userId,
  @Queries() LandSearchParams params = const LandSearchParams(),
});

@GET('/api/site-plans/unapproved/')
  Future<ApiResponse<LandListResponse>> loadUnApprovedLands({
    @Queries() UnApprovedSitePlansParams params = const UnApprovedSitePlansParams(),
  });


@POST('/api/site-plans/document-search')
  Future<ApiResponse<LandListResponse>> searchLands({
  @Body() LandSearchParams params = const LandSearchParams(),
  });

  @POST('/api/lands')
  Future<ApiResponse<LandUploadResponse>> uploadLand({
    @Body() required ProcessedLandData landData,
  });

  @PUT('/api/document-processing/update/{landId}')
  Future<ApiResponse<ProcessedLandData>> updateLand({
    @Path('landId') required String landId,
    @Body() required ProcessedLandData landData,
  });


  @POST('/api/document-processing/store/{userId}')
  Future<ApiResponse<ProcessedLandData>> saveSitePlanData({
    @Path('userId') required String userId,
    @Body() required ProcessedLandData landData,
  });

  @MultiPart()
  @POST('/api/lands/documents')
  Future<ApiResponse<DocumentUploadResponse>> uploadDocument({
    @Part() required File file,
    @Part() required String landId,
    @Part() String? documentType,
  });

  @GET('/api/lands/{landId}/documents')
  Future<ApiResponse<List<LandDocument>>> getLandDocuments({
    @Path('landId') required String landId,
  });

  @DELETE('/api/lands/{landId}')
  Future<ApiResponse<EmptyResponse>> deleteLand({
    @Path('landId') required String landId,
  });

  @GET('/api/lands/validate/{plotNumber}')
  Future<ApiResponse<PlotValidationResponse>> validatePlotNumber({
    @Path('plotNumber') required String plotNumber,
  });

  @GET('/api/lands/history/{landId}')
  Future<ApiResponse<List<LandHistoryEntry>>> getLandHistory({
    @Path('landId') required String landId,
    @Queries() HistoryParams params = const HistoryParams(),
  });
}



// Models and Supporting Classes

@JsonSerializable()
class HistoryParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? action;
  final int limit;

  const HistoryParams({
    this.startDate,
    this.endDate,
    this.action,
    this.limit = 50,
  });

  Map<String, dynamic> toJson() => _$HistoryParamsToJson(this);
}

@JsonSerializable()
class LandListResponse {
  @JsonKey(name: 'items')
  final List<ProcessedLandData> items;

  const LandListResponse({
    required this.items,
  });

  factory LandListResponse.fromJson(Map<String, dynamic> json) {
    return LandListResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) =>
              ProcessedLandData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((item) => item.toJson()).toList(),
      };

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;

  @override
  String toString() => 'LandListResponse(count: ${items.length})';
}

@JsonSerializable()
class LandDocument {
  final String id;
  final String plotId;
  final String documentType;
  final String fileName;
  final String url;
  final DateTime uploadedAt;
  final String uploadedBy;

  LandDocument({
    required this.id,
    required this.plotId,
    required this.documentType,
    required this.fileName,
    required this.url,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory LandDocument.fromJson(Map<String, dynamic> json) =>
      _$LandDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$LandDocumentToJson(this);
}

@JsonSerializable()
class DocumentUploadResponse {
  final String documentId;
  final String url;

  DocumentUploadResponse({
    required this.documentId,
    required this.url,
  });

  factory DocumentUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentUploadResponseToJson(this);
}

@JsonSerializable()
class PlotValidationResponse {
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic>? existingData;

  PlotValidationResponse({
    required this.isValid,
    this.errorMessage,
    this.existingData,
  });

  factory PlotValidationResponse.fromJson(Map<String, dynamic> json) =>
      _$PlotValidationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlotValidationResponseToJson(this);
}

@JsonSerializable()
class LandHistoryEntry {
  final String id;
  final String plotId;
  final String action;
  final String performedBy;
  final DateTime timestamp;
  final Map<String, dynamic>? changes;

  LandHistoryEntry({
    required this.id,
    required this.plotId,
    required this.action,
    required this.performedBy,
    required this.timestamp,
    this.changes,
  });

  factory LandHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$LandHistoryEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LandHistoryEntryToJson(this);
}

class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      const EmptyResponse();

  Map<String, dynamic> toJson() => {};
}

class ApiResponse<T> {
  final T data;
  final bool success;
  final String? message;

  ApiResponse({
    required this.data,
    required this.success,
    this.message,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      data: fromJsonT(json['data']),
      success: json['success'] as bool,
      message: json['message'] as String?,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LandDetailsResponse {
  final String id;
  @JsonKey(name: 'plot_info')
  final PlotInfo plotInfo;
  @JsonKey(name: 'survey_points')
  final List<SurveyPoint> surveyPoints;
  @JsonKey(name: 'boundary_points')
  final List<BoundaryPoint> boundaryPoints;
  @JsonKey(name: 'point_list')
  final List<PointList> pointList;

  LandDetailsResponse({
    required this.id,
    required this.plotInfo,
    required this.surveyPoints,
    required this.boundaryPoints,
    required this.pointList,
  });

  factory LandDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$LandDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LandDetailsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LandUploadResponse {
  final String id;
  final String referenceNumber;
  @JsonKey(name: 'uploaded_at')
  final DateTime uploadedAt;
  @JsonKey(name: 'uploaded_by')
  final String uploadedBy;
  final String status;
  @JsonKey(name: 'validation_status')
  final String validationStatus;
  @JsonKey(name: 'validation_messages')
  final List<String>? validationMessages;
  @JsonKey(name: 'processed_data')
  final ProcessedLandData processedData;
  @JsonKey(name: 'pending_documents')
  final List<RequiredDocument>? pendingDocuments;
  final Map<String, dynamic>? metadata;

  const LandUploadResponse({
    required this.id,
    required this.referenceNumber,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.status,
    required this.validationStatus,
    this.validationMessages,
    required this.processedData,
    this.pendingDocuments,
    this.metadata,
  });

  factory LandUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$LandUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LandUploadResponseToJson(this);
}

@JsonSerializable()
class RequiredDocument {
  final String type;
  final String name;
  final String description;
  final bool required;
  @JsonKey(name: 'file_types')
  final List<String> fileTypes;
  @JsonKey(name: 'max_size')
  final int maxSize;
  final DateTime? deadline;

  const RequiredDocument({
    required this.type,
    required this.name,
    required this.description,
    required this.required,
    required this.fileTypes,
    required this.maxSize,
    this.deadline,
  });

  factory RequiredDocument.fromJson(Map<String, dynamic> json) =>
      _$RequiredDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$RequiredDocumentToJson(this);
}

enum UploadStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('rejected')
  rejected
}

enum ValidationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('valid')
  valid,
  @JsonValue('invalid')
  invalid,
  @JsonValue('needs_review')
  needsReview
}

extension UploadStatusExtension on UploadStatus {
  String get displayName {
    switch (this) {
      case UploadStatus.pending:
        return 'Pending';
      case UploadStatus.processing:
        return 'Processing';
      case UploadStatus.completed:
        return 'Completed';
      case UploadStatus.failed:
        return 'Failed';
      case UploadStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isTerminal =>
      this == UploadStatus.completed ||
      this == UploadStatus.failed ||
      this == UploadStatus.rejected;
}

extension ValidationStatusExtension on ValidationStatus {
  String get displayName {
    switch (this) {
      case ValidationStatus.pending:
        return 'Pending Validation';
      case ValidationStatus.inProgress:
        return 'Validating';
      case ValidationStatus.valid:
        return 'Valid';
      case ValidationStatus.invalid:
        return 'Invalid';
      case ValidationStatus.needsReview:
        return 'Needs Review';
    }
  }

  bool get requiresAction =>
      this == ValidationStatus.invalid || this == ValidationStatus.needsReview;
}
