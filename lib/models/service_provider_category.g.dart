// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_provider_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceProviderCategory _$ServiceProviderCategoryFromJson(
        Map<String, dynamic> json) =>
    ServiceProviderCategory(
      (json['category_id'] as num).toInt(),
      (json['provider_profile_id'] as num).toInt(),
      Category.fromJson(json['category'] as Map<String, dynamic>),
      json['fee'],
    );

Map<String, dynamic> _$ServiceProviderCategoryToJson(
        ServiceProviderCategory instance) =>
    <String, dynamic>{
      'category_id': instance.category_id,
      'provider_profile_id': instance.provider_profile_id,
      'category': instance.category,
      'fee': instance.dynamicFee,
    };
