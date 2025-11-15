import 'package:deligo/models/setting.dart';
import 'package:flutter/foundation.dart';

class AppSettings {
  static late String currencyIcon,
      supportPhone,
      supportEmail,
      privacyPolicy,
      terms,
      taxInPercent,
      deliveryFee,
      deliveryDistance,
      vendorType;

  static bool setupWith(List<Setting> settings) {
    currencyIcon = _getSettingValue(settings, "currency_icon");
    supportPhone = _getSettingValue(settings, "support_phone");
    supportEmail = _getSettingValue(settings, "support_email");
    privacyPolicy = _getSettingValue(settings, "privacy_policy");
    terms = _getSettingValue(settings, "terms");
    taxInPercent = _getSettingValue(settings, "tax_in_percent");
    deliveryFee = _getSettingValue(settings, "delivery_fee");
    vendorType = _getSettingValue(settings, "vendor_type");

    //for testing
    //currencyIcon = "\$";
    return currencyIcon.isNotEmpty;
  }

  static String _getSettingValue(List<Setting> settings, String forKey) {
    String toReturn = "";
    for (Setting setting in settings) {
      if (setting.key == forKey) {
        toReturn = setting.value;
        break;
      }
    }
    if (toReturn.isEmpty) {
      if (kDebugMode) {
        print(
            "getSettingValue returned empty value for: $forKey, when settings were: $settings");
      }
    }
    return toReturn;
  }
}
