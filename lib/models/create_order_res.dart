import 'package:json_annotation/json_annotation.dart';

import 'order.dart';
import 'payment.dart';

part 'create_order_res.g.dart';

@JsonSerializable()
class CreateOrderRes {
  final Payment? payment;
  final Order order;

  CreateOrderRes(this.payment, this.order);

  /// A necessary factory constructor for creating a new CreateOrderRes instance
  /// from a map. Pass the map to the generated `_$CreateOrderResFromJson()` constructor.
  /// The constructor is named after the source class, in this case, CreateOrderRes.
  factory CreateOrderRes.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderResFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$CreateOrderResToJson`.
  Map<String, dynamic> toJson() => _$CreateOrderResToJson(this);
}
