import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:result_dart/result_dart.dart';

import 'package:wdtxt/models/login_request/login_request.dart';
import 'package:wdtxt/models/login_response/login_response.dart';
import 'package:wdtxt/models/message_request/message_request.dart';
import 'package:wdtxt/models/sync_response/sync_response.dart';
import 'package:wdtxt/models/events/events.dart';

class ApiService {

  ApiService({
    String? host,
    int? port,
    HttpClient Function()? clientFactory,
    StreamTransformer<Object, ServerEvent>? eventTransformer
  }):
  _host = host ?? "localhost",
  _port = port ?? 10000,
  _clientFactory = clientFactory ?? HttpClient.new,
  _eventTransformer = eventTransformer ?? 
    StreamTransformer<Object, ServerEvent>.fromHandlers(
      handleData: (data, sink) { print("Error! event translator not provided! "); }
    );

  final String _host;
  final int _port;
  final HttpClient Function() _clientFactory;
  final StreamTransformer<Object, ServerEvent> _eventTransformer;
  
  final StreamController<Object> _serverEventSource = StreamController<Object>.broadcast();
  Stream<ServerEvent> get serverEvents  => _serverEventSource.stream.transform(_eventTransformer);

  String? Function()? _authHeaderProvider;
  set authHeaderProvider(String? Function() authHeaderProvider) {
    _authHeaderProvider = authHeaderProvider;
  }

  Future<void> _addHeaders(HttpHeaders headers) async {
    final header = _authHeaderProvider?.call();
    if(header != null) {
      headers.add(HttpHeaders.authorizationHeader, header);
    }
  }

  Future<Result<String>> login(LoginRequest loginRequest) async {
    final client = _clientFactory();
    try {

      final request = await client.post(_host, _port, '/api/login');
      request.write(jsonEncode(loginRequest));
      final response = await request.close();
      final stringInfo = await response.transform(utf8.decoder).join();
      // print(stringInfo);
      final LoginResponse lr = LoginResponse.fromJson(jsonDecode(stringInfo));
      if(response.statusCode == 200) {
        // print("Has listeners : ${_serverEventSource.hasListener}");
        // print("Adding events ... ");
        _serverEventSource.sink.add(lr.events);
        // print("Done adding events! ");
        return Success(lr.token);
      } else {
        return Failure(Exception(lr.notification));
      }
    } on Exception catch (error) {
      return Failure(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> synchronize() async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/sync');
      _addHeaders(request.headers);
      final response = await request.close();
      final stringInfo = await response.transform(utf8.decoder).join();
      final SyncResponse sr = SyncResponse.fromJson(jsonDecode(stringInfo));
      if(response.statusCode == 200) {
        _serverEventSource.sink.add(sr.events);
        return Success(());
      } else {
        return Failure(Exception(sr.notification));
      }
    } on Exception catch (error) {
      return Failure(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> message(MessageRequest messageRequest) async {
    final client = _clientFactory();
    try {

      final request = await client.post(_host, _port, '/api/message');
      request.write(jsonEncode(messageRequest));
      _addHeaders(request.headers);
      final response = await request.close();
      final stringInfo = await response.transform(utf8.decoder).join();
      // print(stringInfo);
      final SyncResponse sr = SyncResponse.fromJson(jsonDecode(stringInfo));
      if(response.statusCode == 200) {
        _serverEventSource.sink.add(sr.events);
        return Success(());
      } else {
        return Failure(Exception(sr.notification));
      }
    } on Exception catch (error) {
      return Failure(error);
    } finally {
      client.close();
    }
  }
}


