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
        case "201": //_sendMessageEvents(events[eventCode]!.cast<Object>(), eventSink);
        default:
      }
    }
  }

  @override
  void handleError(Object error, StackTrace stackTrace, EventSink<ServerEvent> eventSink) {}

  @override
  void handleDone(EventSink<ServerEvent> eventSink) {}

}