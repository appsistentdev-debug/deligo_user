// ignore_for_file: non_constant_identifier_names
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final int? parent_id;
  final String? slug;
  final String title;
  final dynamic mediaurls;
  final dynamic meta;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? imageUrl;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? imageBannerUrl;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? vendorType;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool? hasTakeaway;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool? isEnabled;

  Category(this.id, this.parent_id, this.slug, this.title, this.mediaurls,
      this.meta);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  void setup() {
    imageUrl = Helper.getMediaUrl(mediaurls);
    imageBannerUrl = Helper.getMediaUrl(mediaurls, mediaUrlKey: "banners");
    List<String> vts =
        AppSettings.vendorType.split(",").map((e) => e.trim()).toList();
    vts.removeWhere((element) => element.isEmpty);
    for (String vt in vts) {
      if ((slug ?? "").contains("-$vt")) {
        vendorType = vt;
        break;
      }
    }
    try {
      hasTakeaway = bool.tryParse("${(meta as Map)["has_takeaway"]}");
    } catch (e) {
      hasTakeaway = false;
    }
    try {
      isEnabled = bool.tryParse("${(meta as Map)["is_enabled"]}");
    } catch (e) {
      isEnabled = false;
    }
  }

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
