// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'coupon.g.dart';

@JsonSerializable()
class Coupon {
  final int id;
  final String title;
  final String detail;
  final String code;
  final double reward;
  final String type;
  final String expires_at;
  final dynamic meta;

  Coupon(this.id, this.title, this.detail, this.code, this.reward, this.type,
      this.expires_at, this.meta);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coupon && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);

  Map<String, dynamic> toJson() => _$CouponToJson(this);
}
