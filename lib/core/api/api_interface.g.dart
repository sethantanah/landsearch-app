// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_interface.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryParams _$HistoryParamsFromJson(Map<String, dynamic> json) =>
    HistoryParams(
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      action: json['action'] as String?,
      limit: (json['limit'] as num?)?.toInt() ?? 50,
    );

Map<String, dynamic> _$HistoryParamsToJson(HistoryParams instance) =>
    <String, dynamic>{
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'action': instance.action,
      'limit': instance.limit,
    };

LandListResponse _$LandListResponseFromJson(Map<String, dynamic> json) =>
    LandListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => ProcessedLandData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LandListResponseToJson(LandListResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
    };

LandDocument _$LandDocumentFromJson(Map<String, dynamic> json) => LandDocument(
      id: json['id'] as String,
      plotId: json['plotId'] as String,
      documentType: json['documentType'] as String,
      fileName: json['fileName'] as String,
      url: json['url'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      uploadedBy: json['uploadedBy'] as String,
    );

Map<String, dynamic> _$LandDocumentToJson(LandDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plotId': instance.plotId,
      'documentType': instance.documentType,
      'fileName': instance.fileName,
      'url': instance.url,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'uploadedBy': instance.uploadedBy,
    };

DocumentUploadResponse _$DocumentUploadResponseFromJson(
        Map<String, dynamic> json) =>
    DocumentUploadResponse(
      documentId: json['documentId'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$DocumentUploadResponseToJson(
        DocumentUploadResponse instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'url': instance.url,
    };

PlotValidationResponse _$PlotValidationResponseFromJson(
        Map<String, dynamic> json) =>
    PlotValidationResponse(
      isValid: json['isValid'] as bool,
      errorMessage: json['errorMessage'] as String?,
      existingData: json['existingData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PlotValidationResponseToJson(
        PlotValidationResponse instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'errorMessage': instance.errorMessage,
      'existingData': instance.existingData,
    };

LandHistoryEntry _$LandHistoryEntryFromJson(Map<String, dynamic> json) =>
    LandHistoryEntry(
      id: json['id'] as String,
      plotId: json['plotId'] as String,
      action: json['action'] as String,
      performedBy: json['performedBy'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      changes: json['changes'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LandHistoryEntryToJson(LandHistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plotId': instance.plotId,
      'action': instance.action,
      'performedBy': instance.performedBy,
      'timestamp': instance.timestamp.toIso8601String(),
      'changes': instance.changes,
    };

LandDetailsResponse _$LandDetailsResponseFromJson(Map<String, dynamic> json) =>
    LandDetailsResponse(
      id: json['id'] as String,
      plotInfo: PlotInfo.fromJson(json['plot_info'] as Map<String, dynamic>),
      surveyPoints: (json['survey_points'] as List<dynamic>)
          .map((e) => SurveyPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      boundaryPoints: (json['boundary_points'] as List<dynamic>)
          .map((e) => BoundaryPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      pointList: (json['point_list'] as List<dynamic>)
          .map((e) => PointList.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LandDetailsResponseToJson(
        LandDetailsResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plot_info': instance.plotInfo.toJson(),
      'survey_points': instance.surveyPoints.map((e) => e.toJson()).toList(),
      'boundary_points':
          instance.boundaryPoints.map((e) => e.toJson()).toList(),
      'point_list': instance.pointList.map((e) => e.toJson()).toList(),
    };

LandUploadResponse _$LandUploadResponseFromJson(Map<String, dynamic> json) =>
    LandUploadResponse(
      id: json['id'] as String,
      referenceNumber: json['referenceNumber'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      uploadedBy: json['uploaded_by'] as String,
      status: json['status'] as String,
      validationStatus: json['validation_status'] as String,
      validationMessages: (json['validation_messages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      processedData: ProcessedLandData.fromJson(
          json['processed_data'] as Map<String, dynamic>),
      pendingDocuments: (json['pending_documents'] as List<dynamic>?)
          ?.map((e) => RequiredDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LandUploadResponseToJson(LandUploadResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'referenceNumber': instance.referenceNumber,
      'uploaded_at': instance.uploadedAt.toIso8601String(),
      'uploaded_by': instance.uploadedBy,
      'status': instance.status,
      'validation_status': instance.validationStatus,
      'validation_messages': instance.validationMessages,
      'processed_data': instance.processedData.toJson(),
      'pending_documents':
          instance.pendingDocuments?.map((e) => e.toJson()).toList(),
      'metadata': instance.metadata,
    };

RequiredDocument _$RequiredDocumentFromJson(Map<String, dynamic> json) =>
    RequiredDocument(
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      required: json['required'] as bool,
      fileTypes: (json['file_types'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      maxSize: (json['max_size'] as num).toInt(),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
    );

Map<String, dynamic> _$RequiredDocumentToJson(RequiredDocument instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'description': instance.description,
      'required': instance.required,
      'file_types': instance.fileTypes,
      'max_size': instance.maxSize,
      'deadline': instance.deadline?.toIso8601String(),
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _LandApiInterface implements LandApiInterface {
  _LandApiInterface(
    this._dio, {
    this.baseUrl,
    this.errorLogger,
  });

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ApiResponse<ProcessedLandData>> getLandById(
      {required String landId}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<ProcessedLandData>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/lands/${landId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ProcessedLandData> _value;
    try {
      _value = ApiResponse<ProcessedLandData>.fromJson(
        _result.data!,
        (json) => ProcessedLandData.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<LandListResponse>> loadLands({
    required String userId,
    LandSearchParams params = const LandSearchParams(),
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.addAll(params.toJson());
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<LandListResponse>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/site-plans/all/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<LandListResponse> _value;
    try {
      _value = ApiResponse<LandListResponse>.fromJson(
        _result.data!,
        (json) => LandListResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<LandListResponse>> loadUnApprovedLands(
      {UnApprovedSitePlansParams params =
          const UnApprovedSitePlansParams()}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.addAll(params.toJson());
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<LandListResponse>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/site-plans/unapproved/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<LandListResponse> _value;
    try {
      _value = ApiResponse<LandListResponse>.fromJson(
        _result.data!,
        (json) => LandListResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<LandListResponse>> searchLands(
      {LandSearchParams params = const LandSearchParams()}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(params.toJson());
    final _options = _setStreamType<ApiResponse<LandListResponse>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/site-plans/document-search',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<LandListResponse> _value;
    try {
      _value = ApiResponse<LandListResponse>.fromJson(
        _result.data!,
        (json) => LandListResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<LandUploadResponse>> uploadLand(
      {required ProcessedLandData landData}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(landData.toJson());
    final _options = _setStreamType<ApiResponse<LandUploadResponse>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/lands',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<LandUploadResponse> _value;
    try {
      _value = ApiResponse<LandUploadResponse>.fromJson(
        _result.data!,
        (json) => LandUploadResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ProcessedLandData>> updateLand({
    required String landId,
    required ProcessedLandData landData,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(landData.toJson());
    final _options = _setStreamType<ApiResponse<ProcessedLandData>>(Options(
      method: 'PUT',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/document-processing/update-coordinates/${landId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ProcessedLandData> _value;
    try {
      _value = ApiResponse<ProcessedLandData>.fromJson(
        _result.data!,
        (json) => ProcessedLandData.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ProcessedLandData>> saveSitePlanData({
    required String userId,
    required ProcessedLandData landData,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(landData.toJson());
    final _options = _setStreamType<ApiResponse<ProcessedLandData>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/document-processing/store-unapproved-siteplan/${userId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ProcessedLandData> _value;
    try {
      _value = ApiResponse<ProcessedLandData>.fromJson(
        _result.data!,
        (json) => ProcessedLandData.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ProcessedLandData>> updateSitePlan({
    required String landId,
    required ProcessedLandData landData,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(landData.toJson());
    final _options = _setStreamType<ApiResponse<ProcessedLandData>>(Options(
      method: 'PUT',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/document-processing/update-siteplan/${landId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ProcessedLandData> _value;
    try {
      _value = ApiResponse<ProcessedLandData>.fromJson(
        _result.data!,
        (json) => ProcessedLandData.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<DocumentUploadResponse>> uploadDocument({
    required File file,
    required String landId,
    String? documentType,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(MapEntry(
      'file',
      MultipartFile.fromFileSync(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    ));
    _data.fields.add(MapEntry(
      'landId',
      landId,
    ));
    if (documentType != null) {
      _data.fields.add(MapEntry(
        'documentType',
        documentType,
      ));
    }
    final _options =
        _setStreamType<ApiResponse<DocumentUploadResponse>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
            .compose(
              _dio.options,
              '/api/lands/documents',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<DocumentUploadResponse> _value;
    try {
      _value = ApiResponse<DocumentUploadResponse>.fromJson(
        _result.data!,
        (json) => DocumentUploadResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<List<LandDocument>>> getLandDocuments(
      {required String landId}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<List<LandDocument>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/lands/${landId}/documents',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<List<LandDocument>> _value;
    try {
      _value = ApiResponse<List<LandDocument>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                .map<LandDocument>(
                    (i) => LandDocument.fromJson(i as Map<String, dynamic>))
                .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<EmptyResponse>> deleteUnApproved(
      {required String landId}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<EmptyResponse>>(Options(
      method: 'DELETE',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/document-processing/delete-unapproved-document/${landId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<EmptyResponse> _value;
    try {
      _value = ApiResponse<EmptyResponse>.fromJson(
        _result.data!,
        (json) => EmptyResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<EmptyResponse>> deleteSitePlan(
      {required String landId}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<EmptyResponse>>(Options(
      method: 'DELETE',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/document-processing/delete-document/${landId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<EmptyResponse> _value;
    try {
      _value = ApiResponse<EmptyResponse>.fromJson(
        _result.data!,
        (json) => EmptyResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<PlotValidationResponse>> validatePlotNumber(
      {required String plotNumber}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ApiResponse<PlotValidationResponse>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/api/lands/validate/${plotNumber}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<PlotValidationResponse> _value;
    try {
      _value = ApiResponse<PlotValidationResponse>.fromJson(
        _result.data!,
        (json) => PlotValidationResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<List<LandHistoryEntry>>> getLandHistory({
    required String landId,
    HistoryParams params = const HistoryParams(),
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.addAll(params.toJson());
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ApiResponse<List<LandHistoryEntry>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/api/lands/history/${landId}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<List<LandHistoryEntry>> _value;
    try {
      _value = ApiResponse<List<LandHistoryEntry>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                .map<LandHistoryEntry>(
                    (i) => LandHistoryEntry.fromJson(i as Map<String, dynamic>))
                .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
