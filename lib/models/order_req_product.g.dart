// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_req_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderReqProduct _$OrderReqProductFromJson(Map<String, dynamic> json) =>
    OrderReqProduct(
      (json['id'] as num).toInt(),
      (json['quantity'] as num).toInt(),
      (json['addons'] as List<dynamic>)
          .map((e) => OrderReqAddOns.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderReqProductToJson(OrderReqProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quantity': instance.quantity,
      'addons': instance.addons,
    };
