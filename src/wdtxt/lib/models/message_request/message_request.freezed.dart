// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageRequest {

 String get id; String get nonce; String get message;
/// Create a copy of MessageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageRequestCopyWith<MessageRequest> get copyWith => _$MessageRequestCopyWithImpl<MessageRequest>(this as MessageRequest, _$identity);

  /// Serializes this MessageRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nonce,message);

@override
String toString() {
  return 'MessageRequest(id: $id, nonce: $nonce, message: $message)';
}


}

/// @nodoc
abstract mixin class $MessageRequestCopyWith<$Res>  {
  factory $MessageRequestCopyWith(MessageRequest value, $Res Function(MessageRequest) _then) = _$MessageRequestCopyWithImpl;
@useResult
$Res call({
 String id, String nonce, String message
});




}
/// @nodoc
class _$MessageRequestCopyWithImpl<$Res>
    implements $MessageRequestCopyWith<$Res> {
  _$MessageRequestCopyWithImpl(this._self, this._then);

  final MessageRequest _self;
  final $Res Function(MessageRequest) _then;

/// Create a copy of MessageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nonce = null,Object? message = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nonce: null == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageRequest].
extension MessageRequestPatterns on MessageRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageRequest value)  $default,){
final _that = this;
switch (_that) {
case _MessageRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MessageRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nonce,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageRequest() when $default != null:
return $default(_that.id,_that.nonce,_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nonce,  String message)  $default,) {final _that = this;
switch (_that) {
case _MessageRequest():
return $default(_that.id,_that.nonce,_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nonce,  String message)?  $default,) {final _that = this;
switch (_that) {
case _MessageRequest() when $default != null:
return $default(_that.id,_that.nonce,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageRequest implements MessageRequest {
  const _MessageRequest({required this.id, required this.nonce, required this.message});
  factory _MessageRequest.fromJson(Map<String, dynamic> json) => _$MessageRequestFromJson(json);

@override final  String id;
@override final  String nonce;
@override final  String message;

/// Create a copy of MessageRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageRequestCopyWith<_MessageRequest> get copyWith => __$MessageRequestCopyWithImpl<_MessageRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nonce,message);

@override
String toString() {
  return 'MessageRequest(id: $id, nonce: $nonce, message: $message)';
}


}

/// @nodoc
abstract mixin class _$MessageRequestCopyWith<$Res> implements $MessageRequestCopyWith<$Res> {
  factory _$MessageRequestCopyWith(_MessageRequest value, $Res Function(_MessageRequest) _then) = __$MessageRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String nonce, String message
});




}
/// @nodoc
class __$MessageRequestCopyWithImpl<$Res>
    implements _$MessageRequestCopyWith<$Res> {
  __$MessageRequestCopyWithImpl(this._self, this._then);

  final _MessageRequest _self;
  final $Res Function(_MessageRequest) _then;

/// Create a copy of MessageRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nonce = null,Object? message = null,}) {
  return _then(_MessageRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nonce: null == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
