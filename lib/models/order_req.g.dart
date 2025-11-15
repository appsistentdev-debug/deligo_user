// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderReq _$OrderReqFromJson(Map<String, dynamic> json) => OrderReq()
  ..address_id = (json['address_id'] as num?)?.toInt()
  ..products = (json['products'] as List<dynamic>?)
      ?.map((e) => OrderReqProduct.fromJson(e as Map<String, dynamic>))
      .toList()
  ..type = json['type'] as String?
  ..notes = json['notes'] as String?
  ..order_type = json['order_type'] as String?
  ..source_formatted_address = json['source_formatted_address'] as String?
  ..source_address_1 = json['source_address_1'] as String?
  ..source_contact_name = json['source_contact_name'] as String?
  ..source_contact_number = json['source_contact_number'] as String?
  ..destination_formatted_address =
      json['destination_formatted_address'] as String?
  ..destination_address_1 = json['destination_address_1'] as String?
  ..destination_contact_name = json['destination_contact_name'] as String?
  ..destination_contact_number = json['destination_contact_number'] as String?
  ..meta = json['meta'] as String?
  ..payment_method_slug = json['payment_method_slug'] as String?
  ..coupon_code = json['coupon_code'] as String?
  ..scheduled_on = json['scheduled_on'] as String?
  ..customer_name = json['customer_name'] as String?
  ..customer_email = json['customer_email'] as String?
  ..customer_mobile = json['customer_mobile'] as String?
  ..source_longitude = (json['source_longitude'] as num?)?.toDouble()
  ..source_latitude = (json['source_latitude'] as num?)?.toDouble()
  ..destination_longitude = (json['destination_longitude'] as num?)?.toDouble()
  ..destination_latitude = (json['destination_latitude'] as num?)?.toDouble();

Map<String, dynamic> _$OrderReqToJson(OrderReq instance) => <String, dynamic>{
      'address_id': instance.address_id,
      'products': instance.products,
      'type': instance.type,
      'notes': instance.notes,
      'order_type': instance.order_type,
      'source_formatted_address': instance.source_formatted_address,
      'source_address_1': instance.source_address_1,
      'source_contact_name': instance.source_contact_name,
      'source_contact_number': instance.source_contact_number,
      'destination_formatted_address': instance.destination_formatted_address,
      'destination_address_1': instance.destination_address_1,
      'destination_contact_name': instance.destination_contact_name,
      'destination_contact_number': instance.destination_contact_number,
      'meta': instance.meta,
      'payment_method_slug': instance.payment_method_slug,
      'coupon_code': instance.coupon_code,
      'scheduled_on': instance.scheduled_on,
      'customer_name': instance.customer_name,
      'customer_email': instance.customer_email,
      'customer_mobile': instance.customer_mobile,
      'source_longitude': instance.source_longitude,
      'source_latitude': instance.source_latitude,
      'destination_longitude': instance.destination_longitude,
      'destination_latitude': instance.destination_latitude,
    };
