// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_provider_availability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceProviderAvailability _$ServiceProviderAvailabilityFromJson(
        Map<String, dynamic> json) =>
    ServiceProviderAvailability(
      (json['id'] as num).toInt(),
      (json['provider_profile_id'] as num).toInt(),
      json['days'] as String,
      json['from'] as String,
      json['to'] as String,
    );

Map<String, dynamic> _$ServiceProviderAvailabilityToJson(
        ServiceProviderAvailability instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider_profile_id': instance.provider_profile_id,
      'days': instance.days,
      'from': instance.from,
      'to': instance.to,
    };
