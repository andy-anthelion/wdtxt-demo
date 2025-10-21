// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      location: json['location'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'age': instance.age,
      'gender': instance.gender,
      'location': instance.location,
      'name': instance.name,
    };
