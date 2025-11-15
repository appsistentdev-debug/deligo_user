import 'package:json_annotation/json_annotation.dart';

part 'ride_request.g.dart';

@JsonSerializable()
class RideRequest {
  final int vehicle_type_id;
  final int is_scheduled;
  final String type;
  final String ride_on; //"2024-12-18 19:00"
  final String address_from;
  final String latitude_from;
  final String longitude_from;
  final String? from_city;
  final String address_to;
  final String latitude_to;
  final String longitude_to;
  final String? to_city;
  final String payment_method_slug;
  final String? meta;
  final String? coupon_code;

  RideRequest({
    required this.vehicle_type_id,
    required this.is_scheduled,
    required this.type,
    required this.ride_on,
    required this.address_from,
    required this.latitude_from,
    required this.longitude_from,
    required this.address_to,
    required this.latitude_to,
    required this.longitude_to,
    required this.payment_method_slug,
    this.from_city,
    this.to_city,
    this.meta,
    this.coupon_code,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) =>
      _$RideRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RideRequestToJson(this);
}
