import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact.freezed.dart';

@freezed
abstract class Contact with _$Contact {
  
  const Contact._();

  const factory Contact({
    required String id
  }) = _Contact;

  String get gender => id[0] == '-' ? 'M' : 'F';
  int get age => int.parse(id.substring(1,3));
  String get loc => id.substring(3,8);
  String get name {
    int end = id.substring(8).indexOf('.') + 8;
    end = end != -1 ? end : id.length;
    return id.substring(8, end);
  }
}
