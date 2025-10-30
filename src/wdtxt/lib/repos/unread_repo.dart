import 'dart:async';

import 'package:async/async.dart';

import 'package:wdtxt/models/contact/contact.dart';
import 'package:wdtxt/models/conversation/conversation.dart';
import 'package:wdtxt/models/events/events.dart';
import 'package:wdtxt/services/api_service.dart';


class UnreadRepo {

  static const List<Type> UNREAD_EVENT_TYPES = [
    ServerEventMessageDelivery,
  ];

  UnreadRepo({
    required ApiService apiService
  }): _apiService = apiService {

    _unreadController.stream.listen(_handleUnreadEvents);
    _unreadController.add(_unreadSES);
    _unreadController.add(_unreadUEC.stream);

  }

  final ApiService _apiService;

  final Map<Conversation,int> _cachedUnread = {};
  
  final StreamController<UserEvent> _unreadUEC = StreamController<UserEvent>();
  Function(UserEvent) get unreadSendEvent => _unreadUEC.sink.add;

  late final Stream<ServerEvent> _unreadSES = _apiService.serverEvents.where(
    (e) => UNREAD_EVENT_TYPES.contains(e.runtimeType)
  );
  Stream<ServerEvent> get unreadEvents => _unreadSES;

  final StreamGroup<Event> _unreadController = StreamGroup<Event>();

  void _handleUnreadEvents(Event event) {
    
    switch(event) {
      case ServerEventMessageDelivery():
        var convo = Conversation(id1: event.from, id2: event.to);
        _cachedUnread.putIfAbsent(convo, () => 0);
        _cachedUnread[convo] = _cachedUnread[convo]! + 1;
      case UserEvent():
        // _apiService.synchronize();
        print("UnreadRepo : nothing to do");
      default:
        print("UnreadRepo : no handler for event");
    }
  }

  int getUnreadCountOf(Conversation convo) {
    return _cachedUnread[convo] ?? 0;
  }

  Map<Contact, int> getAllUnread(Contact self) {
    Map<Contact, int> allUnread = {};
    _cachedUnread.forEach((convo, count) {
      allUnread.putIfAbsent(
        Contact(
          id: convo.getContactID(self.id)
        ), 
        () => count
      );
    });
    return allUnread;
  }

}