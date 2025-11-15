// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rating _$RatingFromJson(Map<String, dynamic> json) => Rating(
      json['average_rating'],
      json['total_ratings'],
      (json['summary'] as List<dynamic>)
          .map((e) => RatingSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RatingToJson(Rating instance) => <String, dynamic>{
      'average_rating': instance.dynamicAverageRating,
      'total_ratings': instance.dynamicTotalRatings,
      'summary': instance.summary,
    };
