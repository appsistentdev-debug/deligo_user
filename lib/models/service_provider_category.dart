import 'package:deligo/models/category.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service_provider_category.g.dart';

@JsonSerializable()
class ServiceProviderCategory {
  final int category_id;
  final int provider_profile_id;
  final Category category;
  @JsonKey(name: 'fee')
  final dynamic dynamicFee;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? feeFormatted;

  double get fee => double.tryParse("$dynamicFee") ?? 0;

  ServiceProviderCategory(this.category_id, this.provider_profile_id,
      this.category, this.dynamicFee);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServiceProviderCategory &&
        other.category_id == category_id &&
        other.provider_profile_id == provider_profile_id;
  }

  @override
  int get hashCode => category_id.hashCode ^ provider_profile_id.hashCode;

  factory ServiceProviderCategory.fromJson(Map<String, dynamic> json) =>
      _$ServiceProviderCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceProviderCategoryToJson(this);

  void setup() {
    feeFormatted = "${AppSettings.currencyIcon} ${Helper.formatNumber(fee)}";
  }
}
