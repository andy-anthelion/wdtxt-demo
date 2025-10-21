import 'dart:convert';
import 'dart:io';

import 'package:result_dart/result_dart.dart';

import 'package:wdtxt/config/assets.dart';

class LocationService {

  Future<Result<Map<String, String>>> getLocations() async {
    try {
      var fileContent = await File(Assets.locations).readAsString();
      var locations = jsonDecode(fileContent).cast<String,String>();
      return Success(locations);
    } on Exception catch(e) {
      return Failure(e);
    }
  }

}