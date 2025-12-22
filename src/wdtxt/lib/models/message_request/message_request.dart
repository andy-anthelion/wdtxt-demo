import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_request.freezed.dart';
part 'message_request.g.dart';

@freezed
abstract class MessageRequest with _$MessageRequest{
  const factory MessageRequest({
    required String to,
    required String nonce,
    required String message,
  }) = _MessageRequest;

  factory MessageRequest.fromJson(Map<String, Object?> json) => 
    _$MessageRequestFromJson(json);
}