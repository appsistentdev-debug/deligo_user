import 'package:json_annotation/json_annotation.dart';

part 'delivery_fee.g.dart';

@JsonSerializable()
class DeliveryFee {
  final dynamic delivery_fee;

  DeliveryFee(this.delivery_fee);

  double get deliveryFee => double.tryParse("$delivery_fee") ?? 0;

  factory DeliveryFee.fromJson(Map<String, dynamic> json) =>
      _$DeliveryFeeFromJson(json);

  Map toJson() => _$DeliveryFeeToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeliveryFee && other.delivery_fee == delivery_fee;
  }

  @override
  int get hashCode => delivery_fee.hashCode;
}
