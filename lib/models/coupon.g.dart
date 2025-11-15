// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coupon _$CouponFromJson(Map<String, dynamic> json) => Coupon(
      (json['id'] as num).toInt(),
      json['title'] as String,
      json['detail'] as String,
      json['code'] as String,
      (json['reward'] as num).toDouble(),
      json['type'] as String,
      json['expires_at'] as String,
      json['meta'],
    );

Map<String, dynamic> _$CouponToJson(Coupon instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'detail': instance.detail,
      'code': instance.code,
      'reward': instance.reward,
      'type': instance.type,
      'expires_at': instance.expires_at,
      'meta': instance.meta,
    };
