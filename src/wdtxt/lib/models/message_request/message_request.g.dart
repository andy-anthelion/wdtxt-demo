// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageRequest _$MessageRequestFromJson(Map<String, dynamic> json) =>
    _MessageRequest(
      id: json['id'] as String,
      nonce: json['nonce'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$MessageRequestToJson(_MessageRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nonce': instance.nonce,
      'message': instance.message,
    };
