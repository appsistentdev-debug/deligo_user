import 'package:json_annotation/json_annotation.dart';

part 'order_req_addons.g.dart';

@JsonSerializable()
class OrderReqAddOns {
  final int choice_id;

  OrderReqAddOns(this.choice_id);

  factory OrderReqAddOns.fromJson(Map<String, dynamic> json) =>
      _$OrderReqAddOnsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderReqAddOnsToJson(this);
}
