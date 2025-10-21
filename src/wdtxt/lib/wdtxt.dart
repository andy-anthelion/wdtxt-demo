import 'dart:async';

import 'package:args/args.dart';

// import 'package:result_dart/result_dart.dart';

import 'package:wdtxt/models/contact/contact.dart';
import 'package:wdtxt/models/conversation/conversation.dart';

import 'package:wdtxt/repos/auth_repo.dart';
import 'package:wdtxt/repos/location_repo.dart';
import 'package:wdtxt/repos/contact_repo.dart';
import 'package:wdtxt/services/api_service.dart';
import 'package:wdtxt/services/event_service.dart';
import 'package:wdtxt/services/location_service.dart';

class WDTXT {
  
  WDTXT._();

  static Future<void> run(List<String> arguments) async {
    
    //
    // services
    //
    EventService eventService = WDEventService();
    LocationService locationService = LocationService();
    ApiService apiService = ApiService(
      eventTransformer: StreamTransformer.fromHandlers(
        handleData: eventService.handleData,
        handleError: eventService.handleError,
        handleDone: eventService.handleDone
      )
    );

    //
    // repos
    //
    AuthRepo auth = AuthRepo(
      apiService: apiService,
    );

    LocationRepo locs = LocationRepo(
      locationService: locationService
    );

    ContactRepo contact = ContactRepo(
      apiService: apiService
    );
    

    Conversation bothAB = Conversation(id1: "+23USCA.MaryJane....", id2: "-25USNY.JohnDoe.....");
    Conversation bothBA = Conversation(id1: "-25USNY.JohnDoe.....", id2: "+23USCA.MaryJane....");
    print("AB : ${bothAB.alpha} ,${bothAB.beta} ");
    print("BA : ${bothBA.alpha} ,${bothBA.beta} ");



    var parser = ArgParser();
    
    parser.addFlag('help',
      abbr: 'h',
      negatable: false,
      help: 'Display this help message');
      
    parser.addOption('name',
      help: 'Your name');
    parser.addOption('age',
      help: 'Your age',
      valueHelp: 'number');
    parser.addOption('gender',
      help: 'Your gender (single character)',
      valueHelp: 'character');
    parser.addOption('location',
      help: 'Your location');

    var results = parser.parse(arguments);

    if (results['help']) {
      print('Usage: wdtxt [options]');
      print(parser.usage);
      return;
    }

    print('Name: ${results['name']}');
    print('Age: ${results['age']}');
    print('Gender: ${results['gender']}');
    print('Location: ${results['location']}');

    // infinte input loop to handle users and messages

    await auth.login(
      age: 25, 
      gender: 'M', 
      location: 'US...', 
      name: 'JohnDoe'
    );
    
    Contact user = Contact(id: auth.info!['galn']);
  
    String locationName = (await locs.getLocationName(user.loc)).getOrDefault("");
    print("${user.gender}, ${user.age}, $locationName, ${user.name}");
    print(user.id);

    print(contact.contacts());

    return;
  }

}