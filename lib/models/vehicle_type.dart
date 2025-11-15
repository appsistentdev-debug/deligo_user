// ignore_for_file: non_constant_identifier_names
import 'package:deligo/utility/helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vehicle_type.g.dart';

@JsonSerializable()
class VehicleType {
  final int id;
  final String title;
  final double? base_fare;
  final double? distance_charges_per_unit;
  final double? time_charges_per_minute;
  final double? other_charges;
  final String? estimated_time;
  final int seats;
  final dynamic meta;
  final dynamic mediaurls;

  @JsonKey(includeFromJson: false, includeToJson: false)
  double? estimated_fare_subtotal;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? image_url;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? weightCapacity;

  VehicleType(
    this.id,
    this.title,
    this.base_fare,
    this.distance_charges_per_unit,
    this.time_charges_per_minute,
    this.other_charges,
    this.seats,
    this.meta,
    this.mediaurls,
    this.estimated_time,
  );

  double get fare => estimated_fare_subtotal ?? base_fare ?? 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VehicleType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  void setupImageUrl() {
    image_url = Helper.getMediaUrl(mediaurls);
    try {
      weightCapacity ??= (meta as Map)["weight_capacity"];
    } catch (e) {
      // ignore: avoid_print
      print("orderImageInnerSetup: $e");
    }
  }

  factory VehicleType.fromJson(Map<String, dynamic> json) =>
      _$VehicleTypeFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleTypeToJson(this);
}
