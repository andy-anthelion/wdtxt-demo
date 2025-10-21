import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_response.freezed.dart';
part 'sync_response.g.dart';

@freezed
abstract class SyncResponse with _$SyncResponse {
    const factory SyncResponse({
    required bool success,
    required String notification,
    required Object events,
  }) = _SyncResponse;

  factory SyncResponse.fromJson(Map<String, Object?> json) =>
    _$SyncResponseFromJson(json);
}
