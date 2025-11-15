import 'package:json_annotation/json_annotation.dart';

part 'service_provider_availability.g.dart';

@JsonSerializable()
class ServiceProviderAvailability {
  final int id;
  final int provider_profile_id;
  final String days;
  final String from;
  final String to;

  ServiceProviderAvailability(
      this.id, this.provider_profile_id, this.days, this.from, this.to);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServiceProviderAvailability && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory ServiceProviderAvailability.fromJson(Map<String, dynamic> json) =>
      _$ServiceProviderAvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceProviderAvailabilityToJson(this);
}
