// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideRequest _$RideRequestFromJson(Map<String, dynamic> json) => RideRequest(
      vehicle_type_id: (json['vehicle_type_id'] as num).toInt(),
      is_scheduled: (json['is_scheduled'] as num).toInt(),
      type: json['type'] as String,
      ride_on: json['ride_on'] as String,
      address_from: json['address_from'] as String,
      latitude_from: json['latitude_from'] as String,
      longitude_from: json['longitude_from'] as String,
      address_to: json['address_to'] as String,
      latitude_to: json['latitude_to'] as String,
      longitude_to: json['longitude_to'] as String,
      payment_method_slug: json['payment_method_slug'] as String,
      from_city: json['from_city'] as String?,
      to_city: json['to_city'] as String?,
      meta: json['meta'] as String?,
      coupon_code: json['coupon_code'] as String?,
    );

Map<String, dynamic> _$RideRequestToJson(RideRequest instance) =>
    <String, dynamic>{
      'vehicle_type_id': instance.vehicle_type_id,
      'is_scheduled': instance.is_scheduled,
      'type': instance.type,
      'ride_on': instance.ride_on,
      'address_from': instance.address_from,
      'latitude_from': instance.latitude_from,
      'longitude_from': instance.longitude_from,
      'from_city': instance.from_city,
      'address_to': instance.address_to,
      'latitude_to': instance.latitude_to,
      'longitude_to': instance.longitude_to,
      'to_city': instance.to_city,
      'payment_method_slug': instance.payment_method_slug,
      'meta': instance.meta,
      'coupon_code': instance.coupon_code,
    };
