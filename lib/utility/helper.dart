import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:deligo/models/media_image.dart';

import 'locale_data_layer.dart';

class Helper {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static final Map<String, dynamic> _xDeviceInfo = {};

  static dynamic setHeadersBase(String key, dynamic value) =>
      _xDeviceInfo[key] = value;

  static Future<Map<String, dynamic>> getHeadersBase() async {
    _xDeviceInfo["Accept"] = "application/json";
    _xDeviceInfo["Content-Type"] = "application/json";
    if (!_xDeviceInfo.containsKey("X-Localization")) {
      String currLang = await LocalDataLayer().getCurrentLanguage();
      _xDeviceInfo["X-Localization"] = currLang;
    }
    if (!_xDeviceInfo.containsKey("X-Device-Type")) {
      _xDeviceInfo["X-Device-Type"] = Platform.isAndroid ? "android" : "ios";
    }
    if (!_xDeviceInfo.containsKey("X-Device-Id")) {
      if (Platform.isAndroid) {
        AndroidDeviceInfo deviceInfo = await _deviceInfoPlugin.androidInfo;
        _xDeviceInfo["X-Device-Id"] = deviceInfo.id;
      } else {
        IosDeviceInfo deviceInfo = await _deviceInfoPlugin.iosInfo;
        _xDeviceInfo["X-Device-Id"] = deviceInfo.identifierForVendor ?? "xxx";
      }
    }
    return _xDeviceInfo;
  }

  static String getMediaUrl(dynamic mediaUrlIn,
      {MediaImageSize? preferredSize,
      int? index,
      String mediaUrlKey = "images"}) {
    String toReturn = "";

    List<MediaImage>? images;
    try {
      images = ((mediaUrlIn as Map)[mediaUrlKey] as List<dynamic>?)
          ?.map((e) => MediaImage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("MediaImageParse: $e");
      }
    }

    if (images?.isNotEmpty ?? false) {
      MediaImage? imgObj = index != null
          ? (images!.length > index ? images[index] : null)
          : images!.first;
      if (imgObj != null) {
        if (imgObj.defaultImage != null && imgObj.defaultImage!.isNotEmpty) {
          toReturn = imgObj.defaultImage!;
        }
        if (preferredSize != null) {
          if (preferredSize == MediaImageSize.thumb) {
            if (imgObj.thumb != null && imgObj.thumb!.isNotEmpty) {
              toReturn = imgObj.thumb!;
            }
          }
          if (preferredSize == MediaImageSize.small) {
            if (imgObj.small != null && imgObj.small!.isNotEmpty) {
              toReturn = imgObj.small!;
            }
          }
          if (preferredSize == MediaImageSize.medium) {
            if (imgObj.medium != null && imgObj.medium!.isNotEmpty) {
              toReturn = imgObj.medium!;
            }
          }
          if (preferredSize == MediaImageSize.large) {
            if (imgObj.large != null && imgObj.large!.isNotEmpty) {
              toReturn = imgObj.large!;
            }
          }
        }
      }
    }
    return toReturn;
  }

  static List<String> getMediaUrls(dynamic mediaUrlIn,
      {MediaImageSize? preferredSize,
      int? index,
      String mediaUrlKey = "images"}) {
    List<String> toReturn = [];
    List<MediaImage>? images;
    try {
      images = ((mediaUrlIn as Map)[mediaUrlKey] as List<dynamic>?)
          ?.map((e) => MediaImage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("MediaImageParse: $e");
      }
    }
    if (images?.isNotEmpty ?? false) {
      for (MediaImage imgObj in images!) {
        if (imgObj.defaultImage != null && imgObj.defaultImage!.isNotEmpty) {
          toReturn.add(imgObj.defaultImage!);
        }
        if (preferredSize != null) {
          if (preferredSize == MediaImageSize.thumb) {
            if (imgObj.thumb != null && imgObj.thumb!.isNotEmpty) {
              toReturn.add(imgObj.thumb!);
            }
          }
          if (preferredSize == MediaImageSize.small) {
            if (imgObj.small != null && imgObj.small!.isNotEmpty) {
              toReturn.add(imgObj.small!);
            }
          }
          if (preferredSize == MediaImageSize.medium) {
            if (imgObj.medium != null && imgObj.medium!.isNotEmpty) {
              toReturn.add(imgObj.medium!);
            }
          }
          if (preferredSize == MediaImageSize.large) {
            if (imgObj.large != null && imgObj.large!.isNotEmpty) {
              toReturn.add(imgObj.large!);
            }
          }
        }
      }
    }
    return toReturn;
  }

  static String formatDuration(Duration d) {
    var seconds = d.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('${minutes}m');
    }

    if (tokens.isEmpty) {
      tokens.add('${seconds}s');
    }

    return tokens.join(' ');
  }

  static String setupDate(String createdAt, bool fullDate,
      [bool checkUtc = true]) {
    DateTime dateTime = checkUtc
        ? Helper.dateUtcCheckParse(createdAt)
        : DateTime.parse(createdAt);
    return DateFormat(fullDate
            ? "d'${Helper._dateSuffix(dateTime.day)}' MMM yyyy"
            : "dd MMM")
        .format(dateTime);
  }

  static String setupTime(String timeStamp, bool amPm,
          [bool checkUtc = true]) =>
      DateFormat(amPm ? "h:mm a" : "HH:mm").format(checkUtc
          ? Helper.dateUtcCheckParse(timeStamp)
          : DateTime.parse(timeStamp));

  static String setupDateTime(String createdAt, bool fullDate, bool amPm,
      [bool checkUtc = true]) {
    DateTime dateTime = checkUtc
        ? Helper.dateUtcCheckParse(createdAt)
        : DateTime.parse(createdAt);
    return DateFormat(fullDate
            ? "d'${Helper._dateSuffix(dateTime.day)}' MMM yyyy, ${amPm ? 'h:mm a' : 'HH:mm'}"
            : "d'${Helper._dateSuffix(dateTime.day)}' MMM, ${amPm ? 'h:mm a' : 'HH:mm'}")
        .format(dateTime);
  }

  static String setupDateFromMillis(int millis, bool fullDate) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat(fullDate
            ? "d'${Helper._dateSuffix(dateTime.day)}' MMM yyyy"
            : "d'${Helper._dateSuffix(dateTime.day)}' MMM")
        .format(dateTime);
  }

  static String setupTimeFromMillis(int millis, bool amPm) =>
      DateFormat(amPm ? "h:mm a" : "HH:mm")
          .format(DateTime.fromMillisecondsSinceEpoch(millis));

  static String setupDateTimeFromMillis(int millis, bool fullDate, bool amPm) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat(fullDate
            ? "d'${Helper._dateSuffix(dateTime.day)}' MMM yyyy, ${amPm ? 'h:mm a' : 'HH:mm'}"
            : "d'${Helper._dateSuffix(dateTime.day)}' MMM, ${amPm ? 'h:mm a' : 'HH:mm'}")
        .format(dateTime);
  }

  static String _dateSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
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

  static DateTime dateUtcCheckParse(String toCheck) {
    String createdAt = DateTime.parse(toCheck).toString();
    bool isUtc = createdAt.endsWith("000") || createdAt.endsWith("000Z");
    if (kDebugMode) {
      print("isUtc: $isUtc");
    }
    DateTime dateTime = isUtc
        ? DateFormat("yyyy-MM-dd HH:mm:ss").parse(createdAt, true)
        : DateTime.parse(createdAt);
    if (isUtc || toCheck.endsWith("Z")) {
      dateTime = dateTime.toLocal();
    }
    return dateTime;
  }

  // static openShareIntent(BuildContext context, String text) {
  //   Share.share(text);
  //   // Share.share(
  //   //   'Hey, I found' +
  //   //       " " +
  //   //       text +
  //   //       " " +
  //   //       'on' +
  //   //       " " +
  //   //       AppConfig.appName +
  //   //       "\n" +
  //   //       "https://play.google.com/store/apps/details?id=" +
  //   //       AppConfig.packageName,
  //   // );
  // }

  static String getCollectionName(int sender, int receiver) {
    int value = sender.compareTo(receiver);
    if (value < 0) {
      return '$sender-$receiver';
    } else {
      return '$receiver-$sender';
    }
  }

  static void launchURL(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static void clearFocus(BuildContext context) {
    try {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        currentFocus.focusedChild!.unfocus();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static double formatDistance(double distance, String distanceMetric) {
    double divider = (distanceMetric.toLowerCase() == "km") ? 1000 : 1609.34;
    return distance / divider;
  }

  static String formatDistanceString(double distance, String distanceMetric) {
    double formatedDistance = Helper.formatDistance(distance, distanceMetric);
    return "${formatedDistance.toStringAsFixed(2)} $distanceMetric";
  }

  static bool isInteger(num value) => (value % 1) == 0;

  static String formatNumber(num value, [bool abs = false]) =>
      "${Helper.isInteger(value) ? (abs ? value.abs() : value.toInt()) : (abs ? value.abs() : value).toStringAsFixed(1)}";

  static int getRandomOtp() {
    int min = 100000;
    int max = 999999;
    return Random().nextInt(max - min + 1) + min;
  }

  // static String readTimestamp(int timestamp) {
  //   var now = DateTime.now();
  //   var format = DateFormat('HH:mm a');
  //   var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  //   var diff = now.difference(date);
  //   var time = '';
  //
  //   if (diff.inSeconds <= 0 ||
  //       diff.inSeconds > 0 && diff.inMinutes == 0 ||
  //       diff.inMinutes > 0 && diff.inHours == 0 ||
  //       diff.inHours > 0 && diff.inDays == 0) {
  //     time = format.format(date);
  //   } else if (diff.inDays > 0 && diff.inDays < 7) {
  //     if (diff.inDays == 1) {
  //       time = diff.inDays.toString() + ' DAY AGO';
  //     } else {
  //       time = diff.inDays.toString() + ' DAYS AGO';
  //     }
  //   } else {
  //     if (diff.inDays == 7) {
  //       time = (diff.inDays / 7).toString() + ' WEEK AGO';
  //     } else {
  //       time = (diff.inDays / 7).ceil().toString() + ' WEEKS AGO';
  //     }
  //   }
  //
  //   return time;
  // }
}
