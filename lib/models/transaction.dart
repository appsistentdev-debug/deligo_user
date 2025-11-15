import 'package:deligo/utility/string_extensions.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:deligo/utility/helper.dart';

import 'user_data.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  @JsonKey(name: 'id')
  final dynamic dynamicId;
  @JsonKey(name: 'amount')
  final dynamic dynamicAmount;
  final String? type;
  final dynamic meta;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final UserData user;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? createdAtFormatted;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? metaDescription;

  Transaction(
    this.dynamicId,
    this.dynamicAmount,
    this.type,
    this.meta,
    this.createdAt,
    this.updatedAt,
    this.user,
  );

  int? get id => int.tryParse("$dynamicId");
  double get amount => double.parse("$dynamicAmount");
  // String? getMetaValue(String metaKey) {
  //   try {
  //     return (meta as Map)[metaKey];
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("getMetaValue: $e");
  //     }
  //     return null;
  //   }
  // }

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  void setup() {
    createdAtFormatted = Helper.setupDateTime(createdAt, false, true);
    try {
      metaDescription ??= (meta as Map)["description"];
      String? orderCategoryImage =
          (meta as Map)["source_data"]["meta"]["category_title"];
      if (orderCategoryImage != null) {
        metaDescription =
            "${orderCategoryImage.capitalizeFirst()} $metaDescription";
      }
    } catch (e) {
      // ignore: avoid_print
      print("orderImageInnerSetup: $e");
    }
  }
}
