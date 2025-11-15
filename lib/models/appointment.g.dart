// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      (json['id'] as num).toInt(),
      (json['amount'] as num).toDouble(),
      (json['latitude'] as num?)?.toDouble(),
      (json['longitude'] as num?)?.toDouble(),
      json['address'] as String?,
      json['date'] as String,
      json['time_to'] as String,
      json['time_from'] as String,
      json['status'] as String,
      json['created_at'] as String,
      json['updated_at'] as String,
      json['user'] == null
          ? null
          : UserData.fromJson(json['user'] as Map<String, dynamic>),
      json['provider'] == null
          ? null
          : ServiceProvider.fromJson(json['provider'] as Map<String, dynamic>),
      (json['statuses'] as List<dynamic>)
          .map((e) => Status.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['payment'] == null
          ? null
          : Payment.fromJson(json['payment'] as Map<String, dynamic>),
      json['meta'],
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'date': instance.date,
      'time_to': instance.time_to,
      'time_from': instance.time_from,
      'status': instance.status,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'user': instance.user,
      'provider': instance.provider,
      'statuses': instance.statuses,
      'payment': instance.payment,
      'meta': instance.meta,
    };
