// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Delivery _$DeliveryFromJson(Map<String, dynamic> json) => Delivery(
      (json['id'] as num).toInt(),
      json['meta'],
      (json['is_verified'] as num).toInt(),
      (json['is_online'] as num).toInt(),
      (json['assigned'] as num).toInt(),
      (json['longitude'] as num).toDouble(),
      (json['latitude'] as num).toDouble(),
      UserData.fromJson(json['user'] as Map<String, dynamic>),
      (json['ratings'] as num?)?.toDouble(),
      (json['ratings_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DeliveryToJson(Delivery instance) => <String, dynamic>{
      'id': instance.id,
      'meta': instance.meta,
      'is_verified': instance.is_verified,
      'is_online': instance.is_online,
      'assigned': instance.assigned,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'user': instance.user,
      'ratings': instance.ratings,
      'ratings_count': instance.ratings_count,
    };
