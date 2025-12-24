import 'dart:async';

import 'package:result_dart/result_dart.dart' as result_pkg;
import 'package:async/async.dart' as async_pkg;

import 'package:wdtxt/models/conversation/conversation.dart';
import 'package:wdtxt/models/events/events.dart';
import 'package:wdtxt/models/message/message.dart';
import 'package:wdtxt/models/message_request/message_request.dart';
import 'package:wdtxt/services/api_service.dart';
import 'package:wdtxt/services/random_service.dart';

class MessageRepo {

  static const List<Type> MESSAGE_EVENT_TYPES = [
    ServerEventMessageDelivery,
  ];

  MessageRepo({
    required ApiService apiService,
    required RandomService randomService
  }):
    _apiService = apiService,
    _randomService = randomService
  {

    _messageController.stream.listen(_handleMessageEvents);
    _messageController.add(_messageSES);
    _messageController.add(_messageUEC.stream);

  }

  final ApiService _apiService;
  final RandomService _randomService;

  final Map<Conversation,List<Message>> _cachedMessage = {};
  
  final StreamController<UserEvent> _messageUEC = StreamController<UserEvent>();
  Function(UserEvent) get messageSendEvent => _messageUEC.sink.add;

  late final Stream<ServerEvent> _messageSES = _apiService.serverEvents.where(
    (e) => MESSAGE_EVENT_TYPES.contains(e.runtimeType)
  );
  Stream<ServerEvent> get messageEvents => _messageSES;

  final async_pkg.StreamGroup<Event> _messageController = async_pkg.StreamGroup<Event>();

  Future<void> _handleMessageEvents(Event event) async {
    
    switch(event) {
      case ServerEventMessageDelivery():
        var convo = Conversation(id1: event.from, id2: event.to);
        _cachedMessage.putIfAbsent(convo, () => []);
        _cachedMessage[convo]!.add(Message(
          from: event.from,
          message: event.message,
          nonce: event.nonce,
          to: event.to,
          timestamp: event.timestamp.round(),
        ));
      case UserEventSync():
        await _apiService.synchronize();
      default:
        print("MessageRepo : no handler for event");
    }
  }

  List<Message> getAllMessagesOf(Conversation convo) {
    return _cachedMessage[convo] ?? [];
  }

  Message? getLatestMessageOf(Conversation convo) {
    return _cachedMessage[convo]!.last;
  }

  Future<result_pkg.Result<void>> sendMessage({
    required String from,
    required String to,
    required String message,
  }) async {
    try {
      String nonce = await _randomService.generateNonce();
      final result_pkg.Result<void> result = await _apiService.message(MessageRequest(
        to: to, 
        nonce: nonce, 
        message: message
      )); 
      if(result.isError()) {
        return result;
      }
      //TBD add message to waiting
      return result_pkg.Success(());
    } on Exception catch(e) {
      return result_pkg.Failure(e);
    } 
  }

}