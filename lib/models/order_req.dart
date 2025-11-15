import 'package:json_annotation/json_annotation.dart';

import 'order_req_product.dart';

part 'order_req.g.dart';

@JsonSerializable()
class OrderReq {
  int? address_id;
  List<OrderReqProduct>? products;
  String? type,
      notes,
      order_type,
      source_formatted_address,
      source_address_1,
      source_contact_name,
      source_contact_number,
      destination_formatted_address,
      destination_address_1,
      destination_contact_name,
      destination_contact_number,
      meta;
  String? payment_method_slug;
  String? coupon_code;
  String? scheduled_on;
  String? customer_name, customer_email, customer_mobile;

  double? source_longitude,
      source_latitude,
      destination_longitude,
      destination_latitude;

  OrderReq();

  OrderReq.customOrder({
    required this.notes,
    required this.source_formatted_address,
    required this.source_address_1,
    required this.source_contact_name,
    required this.source_contact_number,
    required this.destination_formatted_address,
    required this.destination_address_1,
    required this.destination_contact_name,
    required this.destination_contact_number,
    required this.source_latitude,
    required this.source_longitude,
    required this.destination_latitude,
    required this.destination_longitude,
    this.payment_method_slug,
    required this.meta,
  });

  OrderReq.productsOrder({
    required this.address_id,
    required this.products,
    required this.type,
    this.coupon_code,
    this.scheduled_on,
    required this.notes,
    required this.order_type,
    required this.meta,
    this.payment_method_slug,
    this.customer_name,
    this.customer_email,
    this.customer_mobile,
  });

  factory OrderReq.fromJson(Map<String, dynamic> json) =>
      _$OrderReqFromJson(json);

  Map<String, dynamic> toJson() => _$OrderReqToJson(this);
}
