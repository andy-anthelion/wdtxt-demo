import 'dart:async';

import 'package:async/async.dart';

import 'package:wdtxt/models/contact/contact.dart';
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

  final Map<Contact,int> _cachedUnread = {};
  
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
        // tbd
      case UserEvent():
        // _apiService.synchronize();
        print("UnreadRepo : nothing to do");
      default:
        print("UnreadRepo : no handler for event");
    }
  }

  int getUnreadCountOf(Contact contact) {
    return _cachedUnread[contact] ?? 0;
  }

}