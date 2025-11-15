// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

import 'user_data.dart';
import 'vehicle_type.dart';

part 'driver_profile.g.dart';

@JsonSerializable()
class DriverProfile {
  final int id;
  final int is_verified;
  final int is_online;
  final int is_riding;
  final int? ratings_count;
  final double? current_latitude;
  final double? current_longitude;
  final double? distance_remaining;
  final double? ratings;
  final VehicleType? vehicle_type;
  final UserData? user;
  final dynamic meta;

  String? vehicle_number;

  DriverProfile(
      this.id,
      this.is_verified,
      this.is_online,
      this.is_riding,
      this.ratings_count,
      this.current_latitude,
      this.current_longitude,
      this.distance_remaining,
      this.ratings,
      this.vehicle_type,
      this.user,
      this.meta);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DriverProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory DriverProfile.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileFromJson(json);

  Map<String, dynamic> toJson() => _$DriverProfileToJson(this);

  void setup() {
    user?.setup();
    vehicle_type?.setupImageUrl();
    vehicle_number =
        meta != null && meta is Map ? meta["vehicle_number"] : null;
  }
}
