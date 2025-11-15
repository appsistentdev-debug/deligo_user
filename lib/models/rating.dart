// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

import 'rating_summary.dart';

part 'rating.g.dart';

@JsonSerializable()
class Rating {
  @JsonKey(name: 'average_rating')
  final dynamic dynamicAverageRating;
  @JsonKey(name: 'total_ratings')
  final dynamic dynamicTotalRatings;
  List<RatingSummary> summary;

  Rating(this.dynamicAverageRating, this.dynamicTotalRatings, this.summary);

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);

  Map<String, dynamic> toJson() => _$RatingToJson(this);

  double? get average_rating => double.tryParse("$dynamicAverageRating") ?? 0;

  int? get total_ratings => int.tryParse("$dynamicTotalRatings") ?? 0;
}
