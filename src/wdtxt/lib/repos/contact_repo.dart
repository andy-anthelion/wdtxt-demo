import 'dart:async';

import 'package:async/async.dart';

import 'package:wdtxt/models/contact/contact.dart';
import 'package:wdtxt/models/events/events.dart';
import 'package:wdtxt/services/api_service.dart';

class ContactRepo {

  //tbd make sure you add all event types here
  static const List<Type> CONTACT_EVENT_TYPES = [
    ServerEventContactOnline,
    ServerEventContactOffline,
  ];

  ContactRepo({
    required ApiService apiService,
  }): _apiService = apiService {

    _contactController.stream.listen(_handleContactEvents);
    _contactController.add(_contactSES);
    _contactController.add(_contactUEC.stream);
    
  }

  final ApiService _apiService;

  final Map<Contact, bool> _cachedContacts = {};
  List<Contact>Function() get contacts => _cachedContacts.keys.toList;

  final StreamController<UserEvent> _contactUEC = StreamController<UserEvent>();
  Function(UserEvent) get contactSendEvent => _contactUEC.sink.add;

  late final Stream<ServerEvent> _contactSES = _apiService.serverEvents.where(
    (e) => CONTACT_EVENT_TYPES.contains(e.runtimeType)
  );
  Stream<ServerEvent> get contactEvents => _contactSES;

  final StreamGroup<Event> _contactController = StreamGroup<Event>();

  Future<void> _handleContactEvents(Event event) async {
    // print("handle contact events called in Contact repo ... $event ");
    switch(event) 
    {
      case ServerEventContactOnline():
        var contact = Contact(id: event.id);
        _cachedContacts.putIfAbsent(contact, () => true);
        _cachedContacts[contact] = true;
        // print("Contacts length : ${_cachedContacts.length}");
      case ServerEventContactOffline():
        var contact = Contact(id: event.id);
        _cachedContacts.putIfAbsent(contact, () => false);
        _cachedContacts[contact] = false;
        // print("Contacts length : ${_cachedContacts.length}");
      case SyncUserEvent():
        await _apiService.synchronize();
      default:
        print("ContactRepo : no handler for event");
    }
  }
}