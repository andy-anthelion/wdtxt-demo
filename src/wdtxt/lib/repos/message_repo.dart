import 'dart:async';

import 'package:async/async.dart';

import 'package:wdtxt/models/conversation/conversation.dart';
import 'package:wdtxt/models/events/events.dart';
import 'package:wdtxt/models/message/message.dart';
import 'package:wdtxt/services/api_service.dart';

class MessageRepo {

  static const List<Type> MESSAGE_EVENT_TYPES = [
    ServerEventMessageDelivery,
  ];

  MessageRepo({
    required ApiService apiService
  }): _apiService = apiService {

    _messageController.stream.listen(_handleMessageEvents);
    _messageController.add(_messageSES);
    _messageController.add(_messageUEC.stream);

  }

  final ApiService _apiService;

  final Map<Conversation,List<Message>> _cachedMessage = {};
  
  final StreamController<UserEvent> _messageUEC = StreamController<UserEvent>();
  Function(UserEvent) get messageSendEvent => _messageUEC.sink.add;

  late final Stream<ServerEvent> _messageSES = _apiService.serverEvents.where(
    (e) => MESSAGE_EVENT_TYPES.contains(e.runtimeType)
  );
  Stream<ServerEvent> get messageEvents => _messageSES;

  final StreamGroup<Event> _messageController = StreamGroup<Event>();

  void _handleMessageEvents(Event event) {
    
    switch(event) {
      case ServerEventMessageDelivery():
        var convo = Conversation(id1: event.from, id2: event.to);
        _cachedMessage.putIfAbsent(convo, () => []);
        _cachedMessage[convo]!.add(Message(
          from: event.from,
          message: event.message,
          nonce: event.nonce,
          to: event.to,
          timestamp: event.timestamp,
        ));
      case UserEvent():
        // _apiService.synchronize();
        print("MessageRepo : nothing to do");
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

}