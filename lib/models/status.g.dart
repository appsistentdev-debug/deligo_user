// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Status _$StatusFromJson(Map<String, dynamic> json) => Status(
      (json['id'] as num).toInt(),
      json['name'] as String,
      json['created_at'] as String,
      json['updated_at'] as String,
      json['reason'] as String?,
    )..created_at_formatted = json['created_at_formatted'] as String?;

Map<String, dynamic> _$StatusToJson(Status instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'reason': instance.reason,
      'created_at_formatted': instance.created_at_formatted,
    };
