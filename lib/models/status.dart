// ignore_for_file: non_constant_identifier_names
import 'package:deligo/utility/helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'status.g.dart';

@JsonSerializable()
class Status {
  final int id;
  final String name;
  final String created_at;
  final String updated_at;
  final String? reason;

  String? created_at_formatted;

  Status(this.id, this.name, this.created_at, this.updated_at, this.reason);

  void setup() {
    created_at_formatted = Helper.setupDateTime(created_at, false, true);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Status && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory Status.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);

  Map<String, dynamic> toJson() => _$StatusToJson(this);
}
