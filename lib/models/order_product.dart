import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/helper.dart';
import 'package:json_annotation/json_annotation.dart';

import 'order_group_choice.dart';
import 'vendor_product.dart';

part 'order_product.g.dart';

@JsonSerializable()
class OrderProduct {
  final int id;
  final int quantity;
  final double total;
  final double? subtotal;
  final int order_id;
  final int? vendor_product_id;
  final VendorProduct vendor_product;
  final List<OrderGroupChoice>? addon_choices;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? totalFormatted;

  OrderProduct(this.id, this.quantity, this.total, this.subtotal, this.order_id,
      this.vendor_product_id, this.vendor_product, this.addon_choices);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory OrderProduct.fromJson(Map<String, dynamic> json) =>
      _$OrderProductFromJson(json);

  Map<String, dynamic> toJson() => _$OrderProductToJson(this);

  void setup() {
    totalFormatted =
        "${AppSettings.currencyIcon} ${Helper.formatNumber(num.tryParse("$total") ?? 0)}";
  }
}
