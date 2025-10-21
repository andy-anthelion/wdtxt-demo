import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:result_dart/result_dart.dart';

import 'package:wdtxt/models/login_request/login_request.dart';
import 'package:wdtxt/services/api_service.dart';


class AuthRepo {
  AuthRepo({
    required ApiService apiService,
  }): 
    _apiService = apiService
  {
    _apiService.authHeaderProvider = _addBearerToHeader;
  }

  final ApiService _apiService;
  
  bool? _isAuthenticated;
  String? _token;
  
  Map<String, dynamic>? get info => 
    _token != null ? JwtDecoder.decode(_token as String) : null;
  
  String? _addBearerToHeader() => 
    _token != null ? 'Bearer $_token' : null; 

  Future<bool> get isAuthenticated async {
    
    if(_isAuthenticated != null) {
      return _isAuthenticated!;
    }

    await _fetch();
    return _isAuthenticated ?? false;
  }

  Future<void> _fetch() async {

    // (await _storageService.fetchToken()).fold(
    //   (success) {
    //     token = success;
    //     _isAuthenticated = true;
    //   },
    //   (error) {
    //     token = null;
    //     _isAuthenticated = false;
    //   }
    // );
  }

  Future<Result<void>> login({
    required String gender,
    required int age,
    required String location,
    required String name
  }) async {
    try {
      return (await _apiService.login(
        LoginRequest(gender: gender, age: age, location: location, name: name),
      )).fold((token) {
        _isAuthenticated = true;
        _token = token;
        //tbd save into shared preferences
        return Success(());
      },(failure) {
        return Failure(failure);
      });
    } finally {
      //notify changes     
    }
  }

  Future<Result<void>> logout() async {
    try {
      //tbd clear token in shared preferences
      _token = null;
      _isAuthenticated = false;
      return Success(());
    } finally {
      // tbd notify changes
    }
  }
}