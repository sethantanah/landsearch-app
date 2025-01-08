// lib/features/land_search/domain/entities/original_coords.dart
class OriginalCoords {
  double x;
  double y;
  bool refPoint;

  OriginalCoords({
    this.x = 0,
    this.y = 0,
    this.refPoint = false,
  });

  factory OriginalCoords.fromJson(Map<String, dynamic> json) {
    return OriginalCoords(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      refPoint: json['ref_point'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'ref_point': refPoint,
      };
}

// lib/features/land_search/domain/entities/converted_coords.dart
class ConvertedCoords {
  double latitude;
  double longitude;
  bool refPoint;

  ConvertedCoords({
    this.latitude = 0,
    this.longitude = 0,
    this.refPoint = false,
  });

  factory ConvertedCoords.fromJson(Map<String, dynamic> json) {
    return ConvertedCoords(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      refPoint: json['ref_point'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'ref_point': refPoint,
      };
}

// lib/features/land_search/domain/entities/next_point.dart
class NextPoint {
  String? name;
  String? bearing;
  double? bearingDecimal;
  double? distance;

  NextPoint({
    this.name,
    this.bearing,
    this.bearingDecimal,
    this.distance,
  });

  factory NextPoint.fromJson(Map<String, dynamic> json) {
    return NextPoint(
      name: json['name'],
      bearing: json['bearing'],
      bearingDecimal: json['bearing_decimal']?.toDouble(),
      distance: json['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'bearing': bearing,
        'bearing_decimal': bearingDecimal,
        'distance': distance,
      };
}

// lib/features/land_search/domain/entities/survey_point.dart
class SurveyPoint {
  String? pointName;
  OriginalCoords? originalCoords;
  ConvertedCoords? convertedCoords;
  NextPoint? nextPoint;

  SurveyPoint({
    this.pointName = '',
    this.originalCoords,
    this.convertedCoords,
    this.nextPoint,
  });

  factory SurveyPoint.fromJson(Map<String, dynamic> json) {
    return SurveyPoint(
      pointName: json['point_name'],
      originalCoords: OriginalCoords.fromJson(json['original_coords']),
      convertedCoords: ConvertedCoords.fromJson(json['converted_coords']),
      nextPoint: NextPoint.fromJson(json['next_point']),
    );
  }

  Map<String, dynamic> toJson() => {
        'point_name': pointName,
        'original_coords': originalCoords?.toJson(),
        'converted_coords': convertedCoords?.toJson(),
        'next_point': nextPoint?.toJson(),
      };
}

// lib/features/land_search/domain/entities/boundary_point.dart
class BoundaryPoint {
  String point;
  double northing;
  double easting;
  double latitude;
  double longitude;

  BoundaryPoint({
    this.point = '',
    this.northing = 0,
    this.easting = 0,
    this.latitude = 0,
    this.longitude = 0,
  });

  factory BoundaryPoint.fromJson(Map<String, dynamic> json) {
    return BoundaryPoint(
      point: json['point'],
      northing: json['northing'].toDouble(),
      easting: json['easting'].toDouble(),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'point': point,
        'northing': northing,
        'easting': easting,
        'latitude': latitude,
        'longitude': longitude,
      };
}

// lib/features/land_search/domain/entities/point_list.dart
class PointList {
  double latitude;
  double longitude;
  bool refPoint;

  PointList({
    this.latitude = 0,
    this.longitude = 0,
    this.refPoint = false,
  });

  factory PointList.fromJson(Map<String, dynamic> json) {
    return PointList(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      refPoint: json['ref_point'],
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'ref_point': refPoint,
      };
}

// lib/features/land_search/domain/entities/plot_info.dart
class PlotInfo {
  String? plotNumber;
  double? area;
  String? metric;
  String? locality;
  String? district;
  String? region;
  List<String> owners;
  String? date;
  String? scale;
  String? otherLocationDetails;
  String? surveyorsName;
  String? surveyorsLocation;
  String? surveyorsRegNumber;
  String? regionalNumber;
  String? referenceNumber;

  PlotInfo({
    this.plotNumber = "",
    this.area,
    this.metric,
    this.locality,
    this.district,
    this.region,
    this.owners = const [],
    this.date,
    this.scale,
    this.otherLocationDetails,
    this.surveyorsName,
    this.surveyorsLocation,
    this.surveyorsRegNumber,
    this.regionalNumber,
    this.referenceNumber,
  });

  factory PlotInfo.fromJson(Map<String, dynamic> json) {
    return PlotInfo(
      plotNumber: json['plot_number'] ?? "",
      area: json['area']?.toDouble(),
      metric: json['metric'],
      locality: json['locality'],
      district: json['district'],
      region: json['region'],
      owners: List<String>.from(json['owners'] ?? []),
      date: json['date'],
      scale: json['scale'],
      otherLocationDetails: json['other_location_details'],
      surveyorsName: json['surveyors_name'],
      surveyorsLocation: json['surveyors_location'],
      surveyorsRegNumber: json['surveyors_reg_number'],
      regionalNumber: json['regional_number'],
      referenceNumber: json['reference_number'],
    );
  }

  Map<String, dynamic> toJson() => {
        'plot_number': plotNumber,
        'area': area,
        'metric': metric,
        'locality': locality,
        'district': district,
        'region': region,
        'owners': owners,
        'date': date,
        'scale': scale,
        'other_location_details': otherLocationDetails,
        'surveyors_name': surveyorsName,
        'surveyors_location': surveyorsLocation,
        'surveyors_reg_number': surveyorsRegNumber,
        'regional_number': regionalNumber,
        'reference_number': referenceNumber,
      };
}

// lib/features/land_search/domain/entities/processed_land_data.dart
class ProcessedLandData {
  String? id;
  PlotInfo plotInfo;
  List<SurveyPoint> surveyPoints;
  List<BoundaryPoint> boundaryPoints;
  List<PointList> pointList;

  ProcessedLandData({
    this.id,
    required this.plotInfo,
    required this.surveyPoints,
    required this.boundaryPoints,
    required this.pointList,
  });

  factory ProcessedLandData.fromJson(Map<String, dynamic> json) {
    return ProcessedLandData(
      id: json['id'],
      plotInfo: PlotInfo.fromJson(json['plot_info']),
      surveyPoints: (json['survey_points'] as List)
          .map((e) => SurveyPoint.fromJson(e))
          .toList(),
      boundaryPoints: (json['boundary_points'] as List)
          .map((e) => BoundaryPoint.fromJson(e))
          .toList(),
      pointList: (json['point_list'] as List)
          .map((e) => PointList.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plot_info': plotInfo.toJson(),
        'survey_points': surveyPoints.map((e) => e.toJson()).toList(),
        'boundary_points': boundaryPoints.map((e) => e.toJson()).toList(),
        'point_list': pointList.map((e) => e.toJson()).toList(),
      };

  // Helper method to round double values to 6 decimal places
  static double? _round(double? value) {
    if (value == null) return null;
    return double.parse(value.toStringAsFixed(6));
  }
}

// Sample Data
class RegionData {
  final String name;
  final String image;
  final int activePlots;

  const RegionData({
    required this.name,
    required this.image,
    required this.activePlots,
  });
}

// Map Style
const String mapStyle = '''
[
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "transit",
    "stylers": [{"visibility": "off"}]
  }
]
''';
