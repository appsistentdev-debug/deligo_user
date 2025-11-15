import 'package:json_annotation/json_annotation.dart';

import 'delivery.dart';

part 'order_delivery.g.dart';

@JsonSerializable()
class OrderDelivery {
  final int id;
  final String status;
  final int? order_id;
  final Delivery delivery;

  OrderDelivery(this.id, this.status, this.order_id, this.delivery);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderDelivery && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory OrderDelivery.fromJson(Map<String, dynamic> json) =>
      _$OrderDeliveryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDeliveryToJson(this);
}
