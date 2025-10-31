import 'dart:async';

import 'package:wdtxt/models/events/events.dart';

abstract class EventService {

  void handleData(Object data, EventSink<ServerEvent> eventSink);
  void handleError(Object error, StackTrace stackTrace, EventSink<ServerEvent> eventSink);
  void handleDone(EventSink<ServerEvent> eventSink);

}

class WDEventService extends EventService{

  void _sendContactEvents
  (
    List<String> contactEvents, 
    EventSink<ServerEvent> eventSink
  ){  
    if(contactEvents.isEmpty) {
      return;
    }

    for(String event in contactEvents) {

      int idx = event.length - 1;
      String id = event.substring(0, idx);
      // print("sendUserEvents $id, ${event[idx]} ");
      switch(event[idx]) {
        case '+' :
          eventSink.add(ServerEventContactOnline(id: id));
        case '-':
          eventSink.add(ServerEventContactOffline(id: id));
        default:
          //nothing
      }
    }

  }

  void _sendMessageEvents
  (
    List<List<Object>> messageEvents,
    EventSink<ServerEvent> eventSink,
  ){
    if(messageEvents.isEmpty) {
      return;
    }

    for(List<Object> message in messageEvents) {
      eventSink.add(
        ServerEventMessageDelivery(
          timestamp: message[0] as int, 
          from: message[1] as String, 
          message: message[2] as String, 
          nonce: message[3] as String, 
          to: message[4] as String, 
          toInbox: message[5] as bool
        )
      );
    }
  }

  @override
  void handleData(Object data, EventSink<ServerEvent> eventSink) {
    
    // print("handleData in WDEventService ... ");
    // print(data);

    Map<String, dynamic> events = data as Map<String, dynamic>;

    if(events.isEmpty) {
      return;
    }

    for(String eventCode in events.keys) {
      switch(eventCode) {
        case "101": _sendContactEvents(events[eventCode]!.cast<String>(), eventSink);
        case "201": _sendMessageEvents(events[eventCode]!.cast<List<List<Object>>>(), eventSink);
        default:
      }
    }
  }

  @override
  void handleError(Object error, StackTrace stackTrace, EventSink<ServerEvent> eventSink) {}

  @override
  void handleDone(EventSink<ServerEvent> eventSink) {}

}