// lib/features/land_search/data/models/search_params.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';
part 'search_params.g.dart';

@JsonSerializable()
class ConvertedCoordsSearch {
  final double latitude;
  final double longitude;
  @JsonKey(name: 'ref_point')
  final bool refPoint;

  const ConvertedCoordsSearch({
    required this.latitude,
    required this.longitude,
    this.refPoint = false,
  });

  factory ConvertedCoordsSearch.fromJson(Map<String, dynamic> json) =>
      _$ConvertedCoordsSearchFromJson(json);

  Map<String, dynamic> toJson() => _$ConvertedCoordsSearchToJson(this);

  @override
  String toString() =>
      'ConvertedCoordsSearch(latitude: $latitude, longitude: $longitude, refPoint: $refPoint)';
}

@JsonSerializable()
class LandSearchParams {
  final String? country;
  final String? locality;
  final String? district;
  final String? user;
  @JsonKey(name: 'search_radius')
  final int? searchRadius;
  final String? match;
  final List<PointList?> coordinates;

  const LandSearchParams({
    this.country,
    this.locality,
    this.district,
    this.searchRadius,
    this.user,
    this.match,
    this.coordinates = const [],
  });

  factory LandSearchParams.fromJson(Map<String, dynamic> json) =>
      _$LandSearchParamsFromJson(json);

  Map<String, dynamic> toJson() => _$LandSearchParamsToJson(this);

  LandSearchParams copyWith({
    String? country,
    String? locality,
    String? district,
    String? user,
    int? searchRadius,
    String? match,
    List<PointList?>? coordinates,
  }) {
    return LandSearchParams(
      country: country ?? this.country,
      locality: locality ?? this.locality,
      district: district ?? this.district,
      user: user ?? this.user,
      searchRadius: searchRadius ?? this.searchRadius,
      match: match ?? this.match,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      if (country != null) 'country': country,
      if (locality != null) 'locality': locality,
      if (district != null) 'district': district,
      if (user != null) 'user': user,
      if (searchRadius != null) 'search_radius': searchRadius.toString(),
      if (match != null) 'match': match,
      if (coordinates.isNotEmpty)
        'coordinates': coordinates
            .where((coord) => coord != null)
            .map((coord) => coord!.toJson())
            .toList(),
    };
  }

  @override
  String toString() {
    return 'LandSearchParams(country: $country, locality: $locality, district: $district, '
        'searchRadius: $searchRadius, match: $match, coordinates: $coordinates, user: $user)';
  }
}



@JsonSerializable()
class UnApprovedSitePlansParams {
  final String? userId;

  const UnApprovedSitePlansParams({
    this.userId
  });

  factory UnApprovedSitePlansParams.fromJson(Map<String, dynamic> json) =>
      _$UnApprovedSitePlansParamsFromJson(json);

  Map<String, dynamic> toJson() => _$UnApprovedSitePlansParamsToJson(this);

  UnApprovedSitePlansParams copyWith({
    String? userId
  }) {
    return UnApprovedSitePlansParams(
      userId: userId ?? this.userId
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      if (userId != null) 'user_id': userId,
    };
  }

  @override
  String toString() {
    return 'UnApprovedSitePlansParams(userId: $userId)';
  }
}