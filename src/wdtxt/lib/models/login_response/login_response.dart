import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required bool success,
    required String notification,
    required String token,
    required Object events,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, Object?> json) =>
    _$LoginResponseFromJson(json);
}