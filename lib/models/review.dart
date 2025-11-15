// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'category.dart' as my_category;
import 'user_data.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int? id;
  final int? rating;
  final String? review;
  final UserData user;
  final String? created_at;
  final dynamic meta;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? created_at_formatted;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<my_category.Category>? categories;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? categoryText;

  Review(
      this.id, this.rating, this.review, this.user, this.created_at, this.meta);

  void setup() {
    user.setup();

    try {
      categories = (jsonDecode(jsonEncode(meta["categories"])) as List)
          .map((e) => my_category.Category.fromJson(e as Map<String, dynamic>))
          .toList();
      categoryText = _commaSeperatedCategoryNames(categories!);
    } catch (e) {
      if (kDebugMode) {
        print("Appointment-categoryText: $e");
      }
    }

    created_at_formatted = formatDate(created_at!);
  }

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  String _commaSeperatedCategoryNames(List<my_category.Category> cats) {
    String toReturn = "";
    for (int i = 0; i < cats.length; i++) {
      toReturn = toReturn + cats[i].title;
      if (i != cats.length - 1) toReturn = "$toReturn, ";
    }
    return toReturn;
  }

  String formatDate(String isoString) {
    final date = DateTime.parse(isoString);

    String daySuffix(int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$day${daySuffix(day)} $month, $year';
  }
}
