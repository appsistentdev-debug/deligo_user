import 'package:json_annotation/json_annotation.dart';

import 'order_req_addons.dart';

part 'order_req_product.g.dart';

@JsonSerializable()
class OrderReqProduct {
  final int id;
  final int quantity;
  final List<OrderReqAddOns> addons;

  OrderReqProduct(this.id, this.quantity, this.addons);

  factory OrderReqProduct.fromJson(Map<String, dynamic> json) =>
      _$OrderReqProductFromJson(json);

  Map<String, dynamic> toJson() => _$OrderReqProductToJson(this);
}
