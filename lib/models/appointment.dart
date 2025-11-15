// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:deligo/config/colors.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'category.dart' as my_category;
import 'payment.dart';
import 'service_provider.dart';
import 'status.dart';
import 'user_data.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  final int id;
  final double amount;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String date;
  final String time_to;
  final String time_from;
  final String status;
  final String created_at;
  final String updated_at;
  final UserData? user;
  final ServiceProvider? provider;
  final List<Status> statuses;
  final Payment? payment;
  final dynamic meta;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? amountFormatted;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? created_at_formatted;
  @JsonKey(includeFromJson: false, includeToJson: false)
  DateTime? scheduled_at;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? scheduled_at_formatted;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? scheduled_at_date_formatted;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? scheduled_at_time_formatted;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? notes;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<my_category.Category>? categories;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? categoryText;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color? color;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color? colorLight;

  Appointment(
    this.id,
    this.amount,
    this.latitude,
    this.longitude,
    this.address,
    this.date,
    this.time_to,
    this.time_from,
    this.status,
    this.created_at,
    this.updated_at,
    this.user,
    this.provider,
    this.statuses,
    this.payment,
    this.meta,
  );

  bool get isPast => ["cancelled", "rejected", "complete"].contains(status);

  void setup() {
    user?.setup();
    provider?.setup();
    for (Status status in statuses) {
      status.setup();
    }

    amountFormatted =
        "${AppSettings.currencyIcon} ${Helper.formatNumber(num.tryParse("$amount") ?? 0)}";

    try {
      notes = (meta as Map)["notes"];
    } catch (e) {
      if (kDebugMode) {
        print("Appointment-notes: $e");
      }
    }

    try {
      categories = (jsonDecode(jsonEncode(meta["categories"])) as List)
          .map((e) => my_category.Category.fromJson(e as Map<String, dynamic>))
          .toList();
      categoryText = _commaSeperatedCategoryNames(categories!);
    } catch (e) {
      if (kDebugMode) {
        print("Appointment-categoryText: $e");
      }
      categories = provider?.subcategories.map((e) => e.category).toList();
      categoryText =
          categories != null ? _commaSeperatedCategoryNames(categories!) : "";
    }

    created_at_formatted = Helper.setupDateTime(created_at, false, true);
    scheduled_at = DateTime.parse("$date $time_from");
    scheduled_at_formatted = Helper.setupDateTimeFromMillis(
        scheduled_at!.millisecondsSinceEpoch, false, true);
    scheduled_at_date_formatted =
        Helper.setupDateFromMillis(scheduled_at!.millisecondsSinceEpoch, false);
    scheduled_at_time_formatted =
        Helper.setupTimeFromMillis(scheduled_at!.millisecondsSinceEpoch, true);

    switch (status) {
      case "new":
      case "pending":
        color = orderGreen;
        colorLight = orderGreenLight;
        break;
      case "complete":
      case "failed":
      case "cancelled":
      case "rejected":
        color = orderBlack;
        colorLight = orderBlackLight;
        break;
      default:
        color = orderOrange;
        colorLight = orderOrangeLight;
        break;
    }
  }

  int appointmentStage() {
    switch (status) {
      case "pending":
        return 1;
      case "accepted":
        return 2;
      case "onway":
      case "ongoing":
        return 3;
      case "complete":
        return 4;
      default:
        return 0;
    }
  }

  String appointmentStageStatus(int stage) => stage == 1
      ? "pending"
      : stage == 2
          ? "accepted"
          : stage == 3
              ? "ongoing"
              : "complete";

  String appointmentStageTimestamp(String forStatus) {
    String toReturn = "--";
    for (Status status in statuses) {
      if (status.name == forStatus) {
        toReturn = status.created_at_formatted!;
        break;
      }
    }
    return toReturn;
  }

  String _commaSeperatedCategoryNames(List<my_category.Category> cats) {
    String toReturn = "";
    for (int i = 0; i < cats.length; i++) {
      toReturn = toReturn + cats[i].title;
      if (i != cats.length - 1) toReturn = "$toReturn, ";
    }
    return toReturn;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);

  // void addStatus(String statusToAdd, Duration durationLater) {
  //   statuses.add(Status(statuses[statuses.length - 1].id + 1, statusToAdd,
  //       created_at, updated_at, null));
  //   statuses[statuses.length - 1].created_at_formatted =
  //       Helper.setupDateTimeFromMillis(
  //           DateTime.parse(statuses[0].created_at)
  //               .add(durationLater)
  //               .millisecondsSinceEpoch,
  //           false,
  //           true);
  // }
}
