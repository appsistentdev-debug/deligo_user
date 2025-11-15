// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverProfile _$DriverProfileFromJson(Map<String, dynamic> json) =>
    DriverProfile(
      (json['id'] as num).toInt(),
      (json['is_verified'] as num).toInt(),
      (json['is_online'] as num).toInt(),
      (json['is_riding'] as num).toInt(),
      (json['ratings_count'] as num?)?.toInt(),
      (json['current_latitude'] as num?)?.toDouble(),
      (json['current_longitude'] as num?)?.toDouble(),
      (json['distance_remaining'] as num?)?.toDouble(),
      (json['ratings'] as num?)?.toDouble(),
      json['vehicle_type'] == null
          ? null
          : VehicleType.fromJson(json['vehicle_type'] as Map<String, dynamic>),
      json['user'] == null
          ? null
          : UserData.fromJson(json['user'] as Map<String, dynamic>),
      json['meta'],
    )..vehicle_number = json['vehicle_number'] as String?;

Map<String, dynamic> _$DriverProfileToJson(DriverProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_verified': instance.is_verified,
      'is_online': instance.is_online,
      'is_riding': instance.is_riding,
      'ratings_count': instance.ratings_count,
      'current_latitude': instance.current_latitude,
      'current_longitude': instance.current_longitude,
      'distance_remaining': instance.distance_remaining,
      'ratings': instance.ratings,
      'vehicle_type': instance.vehicle_type,
      'user': instance.user,
      'meta': instance.meta,
      'vehicle_number': instance.vehicle_number,
    };
