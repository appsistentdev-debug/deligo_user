// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceProvider _$ServiceProviderFromJson(Map<String, dynamic> json) =>
    ServiceProvider(
      (json['id'] as num).toInt(),
      (json['user_id'] as num).toInt(),
      (json['ratings_count'] as num).toInt(),
      (json['favourite_count'] as num).toInt(),
      json['is_favourite'] as bool,
      json['name'] as String?,
      json['details'] as String?,
      json['address'] as String?,
      (json['fee'] as num).toDouble(),
      (json['latitude'] as num).toDouble(),
      (json['longitude'] as num).toDouble(),
      (json['ratings'] as num).toDouble(),
      (json['categories'] as List<dynamic>)
          .map((e) =>
              ServiceProviderCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['subcategories'] as List<dynamic>)
          .map((e) =>
              ServiceProviderCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['availability'] as List<dynamic>?)
          ?.map((e) =>
              ServiceProviderAvailability.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['user'] == null
          ? null
          : UserData.fromJson(json['user'] as Map<String, dynamic>),
      json['distance'],
      json['mediaurls'],
      json['meta'],
    );

Map<String, dynamic> _$ServiceProviderToJson(ServiceProvider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.user_id,
      'ratings_count': instance.ratings_count,
      'favourite_count': instance.favourite_count,
      'is_favourite': instance.is_favourite,
      'name': instance.name,
      'details': instance.details,
      'address': instance.address,
      'fee': instance.fee,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'ratings': instance.ratings,
      'categories': instance.categories,
      'subcategories': instance.subcategories,
      'availability': instance.availability,
      'user': instance.user,
      'distance': instance.distance,
      'mediaurls': instance.mediaurls,
      'meta': instance.meta,
    };
