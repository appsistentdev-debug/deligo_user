// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderRes _$CreateOrderResFromJson(Map<String, dynamic> json) =>
    CreateOrderRes(
      json['payment'] == null
          ? null
          : Payment.fromJson(json['payment'] as Map<String, dynamic>),
      Order.fromJson(json['order'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateOrderResToJson(CreateOrderRes instance) =>
    <String, dynamic>{
      'payment': instance.payment,
      'order': instance.order,
    };
