import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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
    String? baseUrl,
    StreamTransformer<Object, ServerEvent>? eventTransformer
  }):
  _host = host ?? "localhost",
  _port = port ?? 10000,
  _clientFactory = clientFactory ?? HttpClient.new,
  _baseUrl = baseUrl ?? "http://localhost:10000",
  _eventTransformer = eventTransformer ?? 
    StreamTransformer<Object, ServerEvent>.fromHandlers(
      handleData: (data, sink) { print("Error! event translator not provided! "); }
    );

  final String _host;
  final int _port;
  final HttpClient Function() _clientFactory;
  final _baseUrl;
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
    final client = Dio(BaseOptions(
      baseUrl: _baseUrl,
      followRedirects: true,
      maxRedirects: 3,
    ));
    try {
      final response = await client.post('/api/login', data: jsonEncode(loginRequest));
      final LoginResponse lr = LoginResponse.fromJson(response.data);
      if(response.statusCode == 200) {
        _serverEventSource.sink.add(lr.events);
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
    final client = Dio(BaseOptions(
      baseUrl: _baseUrl,
      followRedirects: true,
      maxRedirects: 3,
      headers: {
        HttpHeaders.authorizationHeader: _authHeaderProvider?.call() ?? "",
      },
    ));
    try {
      final response = await client.post('/api/sync');
      final SyncResponse sr = SyncResponse.fromJson(response.data);
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
    final client = Dio(BaseOptions(
      baseUrl: _baseUrl,
      followRedirects: true,
      maxRedirects: 3,
      headers: {
        HttpHeaders.authorizationHeader: _authHeaderProvider?.call() ?? "",
      },
    ));
    try {

      final response = await client.post('/api/message', data: jsonEncode(messageRequest));
      final SyncResponse sr = SyncResponse.fromJson(response.data);
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
