import 'package:json_annotation/json_annotation.dart';

import 'user_data.dart';

part 'delivery.g.dart';

@JsonSerializable()
class Delivery {
  final int id;
  final dynamic meta;
  final int is_verified;
  final int is_online;
  final int assigned;
  final double longitude;
  final double latitude;
  final UserData user;
  final double? ratings;
  final int? ratings_count;

  Delivery(
      this.id,
      this.meta,
      this.is_verified,
      this.is_online,
      this.assigned,
      this.longitude,
      this.latitude,
      this.user,
      this.ratings,
      this.ratings_count);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Delivery && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory Delivery.fromJson(Map<String, dynamic> json) =>
      _$DeliveryFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryToJson(this);
}
