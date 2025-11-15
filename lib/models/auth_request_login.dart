import 'package:deligo/utility/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_request_login.g.dart';

@JsonSerializable()
class AuthRequestLogin {
  late String token;
  late String role;

  AuthRequestLogin(this.token) {
    role = Constants.roleUser;
  }

  /// A necessary factory constructor for creating a new AuthRequestLogin instance
  /// from a map. Pass the map to the generated `_$AuthRequestLoginFromJson()` constructor.
  /// The constructor is named after the source class, in this case, AuthRequestLogin.
  factory AuthRequestLogin.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestLoginFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$AuthRequestLoginToJson`.
  Map<String, dynamic> toJson() => _$AuthRequestLoginToJson(this);
}
