// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

part 'rating_summary.g.dart';

@JsonSerializable()
class RatingSummary {
  @JsonKey(name: 'total')
  dynamic dynamicTotal;
  @JsonKey(name: 'rounded_rating')
  final dynamic dynamicRoundedRating;
  double? percent;

  RatingSummary(this.dynamicTotal, this.dynamicRoundedRating);

  static List<RatingSummary> defaultArray() {
    List<RatingSummary> ratingSummaries = [];
    for (int i = 0; i < 5; i++) {
      var rs = RatingSummary(0, i);
      rs.percent = 0;
      ratingSummaries.add(rs);
    }
    return ratingSummaries;
  }

  factory RatingSummary.fromJson(Map<String, dynamic> json) =>
      _$RatingSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$RatingSummaryToJson(this);

  int get total => int.tryParse("$dynamicTotal") ?? 0;

  int get rounded_rating => int.tryParse("$dynamicRoundedRating") ?? 0;

  @override
  String toString() {
    return 'RatingSummary{total: $total, rounded_rating: $rounded_rating, percent: $percent}';
  }
}
