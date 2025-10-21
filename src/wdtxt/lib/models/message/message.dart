import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
abstract class Message with _$Message {
  
  const Message._();

  const factory Message({
    required String from,
    required String message,
    required String nonce,
    required String to,
    required int timestamp,
  }) = _Message;
}
