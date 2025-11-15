// ignore_for_file: non_constant_identifier_names

import 'package:deligo/config/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:deligo/config/assets.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/helper.dart';

import 'driver_profile.dart';
import 'payment.dart';
import 'user_data.dart';
import 'vehicle_type.dart';

part 'ride.g.dart';

@JsonSerializable()
class Ride {
  final int id;
  final String address_from;
  final String latitude_from;
  final String longitude_from;
  final String address_to;
  final String latitude_to;
  final String longitude_to;
  final String? ride_start_at;
  final String? ride_ends_at;
  final String ride_on;
  final int? is_scheduled;

  final double? estimated_pickup_distance;
  final double? estimated_pickup_time;
  final double? estimated_distance;
  final double? final_distance;
  final double? estimated_time;
  final double? final_time;
  final double? estimated_fare_subtotal;
  final double? estimated_fare_total;
  final double? discount;
  final double? final_fare_total;

  final String? type; //["ride", "intercity", "courier"]
  final String? cancelled_by;
  final String? cancel_reason;
  final String
      status; //["pending", "accepted", "onway", "ongoing", "complete", "cancelled", "rejected"]

  final VehicleType? vehicle_type;
  final UserData? user;
  final DriverProfile? driver;
  final Payment? payment;

  final dynamic meta;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? ride_on_formatted;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? fareFormatted;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color? color;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color? colorLight;

  bool get isOngoing =>
      ["accepted", "onway", "ongoing"].contains(status.toLowerCase());

  bool get isRequest => ["pending"].contains(status.toLowerCase());

  bool get isPast =>
      ["cancelled", "rejected", "complete"].contains(status.toLowerCase());

  String? getMetaValue(String metaKey) {
    try {
      if (meta == null) return null;
      return (meta as Map)[metaKey];
    } catch (e) {
      if (kDebugMode) {
        print("getMetaValue: $e");
      }
      return null;
    }
  }

  Ride(
      this.id,
      this.address_from,
      this.latitude_from,
      this.longitude_from,
      this.address_to,
      this.latitude_to,
      this.longitude_to,
      this.ride_start_at,
      this.ride_ends_at,
      this.ride_on,
      this.is_scheduled,
      this.estimated_pickup_distance,
      this.estimated_pickup_time,
      this.estimated_distance,
      this.final_distance,
      this.estimated_time,
      this.final_time,
      this.estimated_fare_subtotal,
      this.discount,
      this.estimated_fare_total,
      this.final_fare_total,
      this.type,
      this.cancelled_by,
      this.cancel_reason,
      this.status,
      this.vehicle_type,
      this.user,
      this.driver,
      this.payment,
      this.meta);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Ride && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => _$RideToJson(this);

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);

  void setup() {
    ride_on_formatted = Helper.setupDateTime(ride_on, false, true);
    fareFormatted =
        "${AppSettings.currencyIcon} ${Helper.formatNumber(num.tryParse("${(final_fare_total ?? estimated_fare_total ?? 0)}") ?? 0)}";
    user?.setup();
    driver?.setup();
    vehicle_type?.setupImageUrl();
    switch (status) {
      case "pending":
      case "accepted":
        color = orderGreen;
        colorLight = orderGreenLight;
        break;
      case "complete":
      case "cancelled":
      case "rejected":
        color = orderBlack;
        colorLight = orderBlackLight;
        break;
      default:
        color = orderOrange;
        colorLight = orderOrangeLight;
        break;
    }
  }
}

enum RideType {
  ride(Assets.mainCategoryRide),
  intercity(Assets.mainCategoryIntercity),
  courier(Assets.mainCategoryPackage);

  final String image;

  const RideType(this.image);
}
