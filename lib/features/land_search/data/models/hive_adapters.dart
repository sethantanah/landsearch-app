// lib/features/land_search/data/models/hive_adapters.dart
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:landsearch_platform/core/api/api_interface.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';
import 'package:landsearch_platform/features/land_search/data/repositories/local_storage.dart';
import 'search_params.dart';

// SearchFilters Adapter
@HiveType(typeId: 0)
class SearchFiltersAdapter extends TypeAdapter<LandSearchParams> {
  @override
  final int typeId = 0;

  @override
  LandSearchParams read(BinaryReader reader) {
    return LandSearchParams(
      country: reader.readString(),
      locality: reader.readString(),
      district: reader.readString(),
      searchRadius: reader.readInt(),
      match: reader.readString(),
      coordinates: (reader.readList()).cast<PointList?>(),
    );
  }

  @override
  void write(BinaryWriter writer, LandSearchParams obj) {
    writer.writeString(obj.country ?? '');
    writer.writeString(obj.locality ?? '');
    writer.writeString(obj.district ?? '');
    writer.writeInt(obj.searchRadius ?? 0);
    writer.writeString(obj.match ?? '');
    writer.writeList(obj.coordinates);
  }
}

// ConvertedCoords Adapter
@HiveType(typeId: 1)
class ConvertedCoordsAdapter extends TypeAdapter<PointList> {
  @override
  final int typeId = 1;

  @override
  PointList read(BinaryReader reader) {
    return PointList(
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
      refPoint: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, PointList obj) {
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
    writer.writeBool(obj.refPoint);
  }
}

// ProcessedLandData Adapter
@HiveType(typeId: 2)
class ProcessedLandDataAdapter extends TypeAdapter<ProcessedLandData> {
  @override
  final int typeId = 2;

  @override
  ProcessedLandData read(BinaryReader reader) {
    return ProcessedLandData(
      id: reader.readString(),
      plotInfo: reader.read() as PlotInfo,
      surveyPoints: (reader.readList()).cast<SurveyPoint>(),
      boundaryPoints: (reader.readList()).cast<BoundaryPoint>(),
      pointList: (reader.readList()).cast<PointList>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProcessedLandData obj) {
    writer.writeString(obj.id ?? '');
    writer.write(obj.plotInfo);
    writer.writeList(obj.surveyPoints);
    writer.writeList(obj.boundaryPoints);
    writer.writeList(obj.pointList);
  }
}

// PlotInfo Adapter
@HiveType(typeId: 3)
class PlotInfoAdapter extends TypeAdapter<PlotInfo> {
  @override
  final int typeId = 3;

  @override
  PlotInfo read(BinaryReader reader) {
    return PlotInfo(
      plotNumber: reader.readString(),
      area: reader.readDouble(),
      metric: reader.readString(),
      locality: reader.readString(),
      district: reader.readString(),
      region: reader.readString(),
      owners: (reader.readList()).cast<String>(),
      date: reader.readString(),
      scale: reader.readString(),
      otherLocationDetails: reader.readString(),
      surveyorsName: reader.readString(),
      surveyorsLocation: reader.readString(),
      surveyorsRegNumber: reader.readString(),
      regionalNumber: reader.readString(),
      referenceNumber: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, PlotInfo obj) {
    writer.writeString(obj.plotNumber ?? '');
    writer.writeDouble(obj.area ?? 0.0);
    writer.writeString(obj.metric ?? '');
    writer.writeString(obj.locality ?? '');
    writer.writeString(obj.district ?? '');
    writer.writeString(obj.region ?? '');
    writer.writeList(obj.owners);
    writer.writeString(obj.date ?? '');
    writer.writeString(obj.scale ?? '');
    writer.writeString(obj.otherLocationDetails ?? '');
    writer.writeString(obj.surveyorsName ?? '');
    writer.writeString(obj.surveyorsLocation ?? '');
    writer.writeString(obj.surveyorsRegNumber ?? '');
    writer.writeString(obj.regionalNumber ?? '');
    writer.writeString(obj.referenceNumber ?? '');
  }
}

// LandDocument Adapter
@HiveType(typeId: 4)
class LandDocumentAdapter extends TypeAdapter<LandDocument> {
  @override
  final int typeId = 4;

  @override
  LandDocument read(BinaryReader reader) {
    return LandDocument(
      id: reader.readString(),
      plotId: reader.readString(),
      documentType: reader.readString(),
      fileName: reader.readString(),
      url: reader.readString(),
      uploadedAt: DateTime.parse(reader.readString()),
      uploadedBy: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, LandDocument obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.plotId);
    writer.writeString(obj.documentType);
    writer.writeString(obj.fileName);
    writer.writeString(obj.url);
    writer.writeString(obj.uploadedAt.toIso8601String());
    writer.writeString(obj.uploadedBy);
  }
}

// PlotValidationResponse Adapter
@HiveType(typeId: 5)
class PlotValidationResponseAdapter
    extends TypeAdapter<PlotValidationResponse> {
  @override
  final int typeId = 5;

  @override
  PlotValidationResponse read(BinaryReader reader) {
    return PlotValidationResponse(
      isValid: reader.readBool(),
      errorMessage: reader.readString(),
      existingData: reader.readMap().cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, PlotValidationResponse obj) {
    writer.writeBool(obj.isValid);
    writer.writeString(obj.errorMessage ?? '');
    writer.writeMap(obj.existingData ?? {});
  }
}

// Add these adapters to the existing hive_adapters.dart file

// PendingUpload Adapter
@HiveType(typeId: 6)
class PendingUploadAdapter extends TypeAdapter<PendingUpload> {
  @override
  final int typeId = 6;

  @override
  PendingUpload read(BinaryReader reader) {
    return PendingUpload(
      id: reader.readString(),
      landData: reader.read() as ProcessedLandData?,
      file: reader.readString().isNotEmpty ? File(reader.readString()) : null,
      landId: reader.readString(),
      timestamp: DateTime.parse(reader.readString()),
      type: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, PendingUpload obj) {
    writer.writeString(obj.id);
    writer.write(obj.landData);
    writer.writeString(obj.file?.path ?? '');
    writer.writeString(obj.landId ?? '');
    writer.writeString(obj.timestamp.toIso8601String());
    writer.writeString(obj.type);
  }
}

// LandSearchParams Adapter
@HiveType(typeId: 7)
class LandSearchParamsAdapter extends TypeAdapter<LandSearchParams> {
  @override
  final int typeId = 7;

  @override
  LandSearchParams read(BinaryReader reader) {
    return LandSearchParams(
      country: reader.readString(),
      locality: reader.readString(),
      district: reader.readString(),
      searchRadius: reader.readInt(),
      match: reader.readString(),
      coordinates: (reader.readList()).cast<PointList?>(),
    );
  }

  @override
  void write(BinaryWriter writer, LandSearchParams obj) {
    writer.writeString(obj.country ?? '');
    writer.writeString(obj.locality ?? '');
    writer.writeString(obj.district ?? '');
    writer.writeInt(obj.searchRadius ?? 0);
    writer.writeString(obj.match ?? '');
    writer.writeList(obj.coordinates);
  }
}

// Update the registerHiveAdapters function to include these new adapters
void registerHiveAdapters() {
  Hive.registerAdapter(SearchFiltersAdapter());
  Hive.registerAdapter(ConvertedCoordsAdapter());
  Hive.registerAdapter(ProcessedLandDataAdapter());
  Hive.registerAdapter(PlotInfoAdapter());
  Hive.registerAdapter(LandDocumentAdapter());
  Hive.registerAdapter(PlotValidationResponseAdapter());
  Hive.registerAdapter(PendingUploadAdapter()); // Add this
  Hive.registerAdapter(LandSearchParamsAdapter()); // Add this
}
