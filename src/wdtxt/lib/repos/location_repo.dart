import 'package:result_dart/result_dart.dart';

import 'package:wdtxt/services/location_service.dart';

class LocationRepo {

  LocationRepo({
    required LocationService locationService
  }):_locationService = locationService;

  Map<String, String>? _cachedLocations;

  final LocationService _locationService;

  Future<Result<String>> getLocationName(String locCode) async {
    
    try {
      _cachedLocations ??= (await _locationService.getLocations()).getOrThrow();
      String? name = _cachedLocations![locCode];
      return name != null ? Success(name) : Failure(Exception("not found"));
    } on Exception catch(e) {
      return Failure(e);
    }
  }

  
}