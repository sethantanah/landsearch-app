// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConvertedCoordsSearch _$ConvertedCoordsSearchFromJson(
        Map<String, dynamic> json) =>
    ConvertedCoordsSearch(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      refPoint: json['ref_point'] as bool? ?? false,
    );

Map<String, dynamic> _$ConvertedCoordsSearchToJson(
        ConvertedCoordsSearch instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'ref_point': instance.refPoint,
    };

LandSearchParams _$LandSearchParamsFromJson(Map<String, dynamic> json) =>
    LandSearchParams(
      country: json['country'] as String?,
      locality: json['locality'] as String?,
      district: json['district'] as String?,
      searchRadius: (json['search_radius'] as num?)?.toInt(),
      user: json['user'] as String?,
      match: json['match'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => e == null
                  ? null
                  : PointList.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LandSearchParamsToJson(LandSearchParams instance) =>
    <String, dynamic>{
      'country': instance.country,
      'locality': instance.locality,
      'district': instance.district,
      'user': instance.user,
      'search_radius': instance.searchRadius,
      'match': instance.match,
      'coordinates': instance.coordinates,
    };

UnApprovedSitePlansParams _$UnApprovedSitePlansParamsFromJson(
        Map<String, dynamic> json) =>
    UnApprovedSitePlansParams(
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$UnApprovedSitePlansParamsToJson(
        UnApprovedSitePlansParams instance) =>
    <String, dynamic>{
      'userId': instance.userId,
    };
