// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingSummary _$RatingSummaryFromJson(Map<String, dynamic> json) =>
    RatingSummary(
      json['total'],
      json['rounded_rating'],
    )..percent = (json['percent'] as num?)?.toDouble();

Map<String, dynamic> _$RatingSummaryToJson(RatingSummary instance) =>
    <String, dynamic>{
      'total': instance.dynamicTotal,
      'rounded_rating': instance.dynamicRoundedRating,
      'percent': instance.percent,
    };
