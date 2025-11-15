import 'package:deligo/models/category.dart' as my_category;
import 'package:deligo/models/service_provider_availability.dart';
import 'package:deligo/models/service_provider_category.dart';
import 'package:deligo/models/user_data.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service_provider.g.dart';

@JsonSerializable()
class ServiceProvider {
  final int id;
  final int user_id;
  final int ratings_count;
  final int favourite_count;
  final bool is_favourite;
  final String? name;
  final String? details;
  final String? address;
  final double fee;
  final double latitude;
  final double longitude;
  final double ratings;
  final List<ServiceProviderCategory> categories;
  final List<ServiceProviderCategory> subcategories;
  final List<ServiceProviderAvailability>? availability;
  final UserData? user;
  final dynamic distance;
  final dynamic mediaurls;
  final dynamic meta;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? imageUrl;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? distanceFormattedKm;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? distanceFormattedMi;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? feeMinString;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? feeMaxString;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? feeMinMaxString;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? aboutService;
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? feeMin;
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? feeMax;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String>? portfolios;

  ServiceProvider(
      this.id,
      this.user_id,
      this.ratings_count,
      this.favourite_count,
      this.is_favourite,
      this.name,
      this.details,
      this.address,
      this.fee,
      this.latitude,
      this.longitude,
      this.ratings,
      this.categories,
      this.subcategories,
      this.availability,
      this.user,
      this.distance,
      this.mediaurls,
      this.meta);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServiceProvider && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory ServiceProvider.fromJson(Map<String, dynamic> json) =>
      _$ServiceProviderFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceProviderToJson(this);

  static ServiceProvider get placeholder => ServiceProvider(
      -1,
      -1,
      -1,
      -1,
      false,
      null,
      null,
      null,
      0.0,
      0.0,
      0.0,
      0.0,
      [],
      [],
      null,
      null,
      null,
      null,
      null);

  String get ratingsString => ratings.toStringAsFixed(1);

  String get feeString => fee.toStringAsFixed(2);

  String get categoriesParentString =>
      categories.isNotEmpty ? categories.first.category.title : "";

  String get categoriesChildrenString =>
      subcategories.isEmpty ? "" : _commaSeperatedCategoryNames(subcategories);

  String get categoriesAllString =>
      (categories.isNotEmpty ? categories.first.category.title : "") +
      (subcategories.isEmpty
          ? ""
          : " (${_commaSeperatedCategoryNames(subcategories)})");

  String _commaSeperatedCategoryNames(List<ServiceProviderCategory> cats) {
    String toReturn = "";
    for (int i = 0; i < cats.length; i++) {
      toReturn = toReturn + cats[i].category.title;
      if (i != cats.length - 1) toReturn = "$toReturn, ";
    }
    return toReturn;
  }

  void setup() {
    imageUrl = Helper.getMediaUrl(mediaurls);
    distanceFormattedKm =
        (distance == null ? 0.0 : (double.tryParse("$distance") ?? 0.0) / 1000)
            .toStringAsFixed(1);
    distanceFormattedMi =
        ((double.tryParse("$distance") ?? 0.0) / 1609.34).toStringAsFixed(1);
    aboutService = meta != null &&
            meta is Map &&
            (meta as Map).containsKey("about_service")
        ? (meta as Map)['about_service']
        : null;
    for (ServiceProviderCategory spc in subcategories) {
      spc.setup();
    }
    if (subcategories.isNotEmpty) {
      feeMin = subcategories.first.fee;
      feeMax = subcategories.first.fee;
    }
    for (ServiceProviderCategory spc in subcategories) {
      if (spc.fee > (feeMax ?? 0)) {
        feeMax = spc.fee;
      }
      if (spc.fee < (feeMin ?? 0)) {
        feeMin = spc.fee;
      }
    }
    feeMinString =
        "${AppSettings.currencyIcon}${Helper.formatNumber(feeMin ?? 0)}";
    feeMaxString =
        "${AppSettings.currencyIcon}${Helper.formatNumber(feeMax ?? 0)}";
    feeMinMaxString = feeMinString == feeMaxString
        ? "$feeMinString"
        : "$feeMinString - $feeMaxString";

    try {
      portfolios ??= [];
      for (int i = 0; i < ((meta as Map)["portfolios"] as List).length; i++) {
        portfolios!.add(((meta as Map)["portfolios"] as List)[i]);
      }
      //portfolios!.add("${((meta as Map)["portfolios"] as List)[i]}");
    } catch (e) {
      if (kDebugMode) {
        print("setup.portfolios: $e");
      }
    }
  }

  double? feeFor(my_category.Category cat) {
    for (ServiceProviderCategory spc in subcategories) {
      if (spc.category == cat) {
        return spc.fee;
      }
    }
    return null;
  }
}
