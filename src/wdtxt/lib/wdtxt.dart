import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

import 'package:wdtxt/models/contact/contact.dart';
import 'package:wdtxt/models/events/events.dart';

import 'package:wdtxt/repos/auth_repo.dart';
import 'package:wdtxt/repos/contact_repo.dart';
import 'package:wdtxt/repos/location_repo.dart';
import 'package:wdtxt/repos/message_repo.dart';
import 'package:wdtxt/repos/unread_repo.dart';
import 'package:wdtxt/services/api_service.dart';
import 'package:wdtxt/services/event_service.dart';
import 'package:wdtxt/services/location_service.dart';

class WDTXT {

  WDTXT._();

  static const int DELAY_MS = 200;

  static Future<void> handleUser({
    required AuthRepo auth,
    required LocationRepo location,
  }) async {
    Contact user = Contact(id: auth.info!['galn']);
    String place = (await location.getLocationName(user.loc)).getOrDefault("");

    print("\n=== User ===");
    print("${user.name}, ${user.age} ${user.gender}");
    print(place);
    print("\npress enter key to continue...");
    stdin.readLineSync();
  }

  static Future<void> handleContacts({
    required AuthRepo auth,
    required ContactRepo contact,
    required LocationRepo location
  }) async {

    Contact user = Contact(id: auth.info!['galn']);
    contact.contactSendEvent(SyncUserEvent());
    await Future.delayed(const Duration(milliseconds: DELAY_MS));
    for(final (i, c) in contact.contacts().indexed) {
      if (c == user) { continue; }
      var place = (await location.getLocationName(c.loc)).getOrDefault("");
      print("${i+1}) ${c.name} ${c.age} ${c.gender} - $place");
    }

    print("\npress enter key to continue...");
    stdin.readLineSync();
  }

  static void handleInbox({
    required AuthRepo auth,
    required UnreadRepo unread,
  }) {

    var user = Contact(id: auth.info!['galn']);
    var total = 0;
    unread.getAllUnread(user).forEach((contact, count) {
      print("${contact.name} ($count)");
      total += count;
    });
    print("\n Total Unread : $total");

  }

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
        handleDone: eventService.handleDone,
      ),
    );

    //
    // repos
    //
    AuthRepo auth = AuthRepo(apiService: apiService);

    LocationRepo locs = LocationRepo(locationService: locationService);

    ContactRepo contact = ContactRepo(apiService: apiService);

    MessageRepo message = MessageRepo(apiService: apiService);

    UnreadRepo unread = UnreadRepo(apiService: apiService);

    var parser = ArgParser();

    parser.addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Display this help message',
    );

    parser.addOption('name', defaultsTo: 'JohnDoe', help: 'Your name');
    parser.addOption(
      'age',
      defaultsTo: '25',
      help: 'Your age',
      valueHelp: 'number',
    );
    parser.addOption(
      'gender',
      defaultsTo: 'M',
      help: 'Your gender (single character)',
      valueHelp: 'character',
    );
    parser.addOption('location', defaultsTo: 'US...', help: 'Your location');

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

    var loginResult = await auth.login(
      age: int.parse(results['age']),
      gender: results['gender'],
      location: results['location'],
      name: results['name'],
    );

    if (loginResult.isError()) {
      print("Unable to login: ${loginResult.exceptionOrNull()!.toString()} ");
      return;
    }

    bool stillRunning = true;
    // infinte input loop to handle users and messages
    while (stillRunning) {
      print('\n=== Main Menu ===');
      print('1) User');
      print('2) Contacts');
      print('3) Inbox');
      print('\nEnter your choice (1-3) or (q)uit: ');

      String? choice = stdin.readLineSync()?.toLowerCase();

      switch (choice) {
        case '1':
          await handleUser(auth: auth, location: locs);
          break;
        case '2':
          await handleContacts(auth: auth, contact: contact, location: locs);
          break;
        case '3':
          handleInbox(auth: auth, unread: unread);
          break;
        case 'q':
          stillRunning = false;
          break;
        default:
          print('Invalid Option!');
      }
    }

    return;
  }
}
