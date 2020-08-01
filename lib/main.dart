// Reference page: https://github.com/parse-community/Parse-SDK-Flutter

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:convert';

import 'models/Channel.dart';
import 'widgets/TabBarDemo.dart';

const String PARSE_APP_ID = 'Fy0qjfqDevGKQPT5XaANnq9EbQ1EbP2OtiQzhwWV';
const String PARSE_APP_URL = 'https://parseapi.back4app.com';
const String MASTER_KEY = 'mPpFoKblASqkm362EhSv6Bw3AsXKTqJqLEBpmps6';
const String LIVE_QUERY_URL = 'wss://qwertydomain.back4app.io';

void main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  //_setTargetPlatformForDesktop();
  // var channels = await getChannels();
  // print(channels);
  initializeNotifications();

  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: TabBarDemo(),
  ));
}

Future<void> initializeNotifications() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid = new AndroidInitializationSettings('icon');

  var initializationSettings =
      InitializationSettings(initializationSettingsAndroid, null);
  
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (payload) => null);

  var vibrationPattern = Int64List(4);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 1000;
  vibrationPattern[2] = 5000;
  vibrationPattern[3] = 2000;

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id_TVCubana',
      'channel_TVCubana',
      'channel_TVCubana_description',
      vibrationPattern: vibrationPattern,
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500);

  var platformChannelSpecifics =
      NotificationDetails(androidPlatformChannelSpecifics, null);

  // flutterLocalNotificationsPlugin.show(
  //     0, 'plain title', 'plain body', platformChannelSpecifics,
  //     payload: 'item x');
 
  var scheduledNotificationDateTime =
      new DateTime.now().add(new Duration(seconds: 10));

  flutterLocalNotificationsPlugin
      .schedule(101, 'scheduled title', 'scheduled body',
          scheduledNotificationDateTime, platformChannelSpecifics,
          androidAllowWhileIdle: true, payload: 'item x')
      .then((value) => print('Notification executed'))
      .catchError((err) => print('Error ' + err));

  flutterLocalNotificationsPlugin.pendingNotificationRequests().then((value) {
    value.forEach((pnr) {
      print([pnr.id, pnr.title, pnr.body, pnr.payload]);
    });
  });
}

void testJsons() {
  // var pi = new ProgramItem('description', 'descriptionLong', 'duration', 'date',
  // 'dateStart', 'dateEnd', 'timeStart', 'timeEnd', 'title', []);
  // var p = new Program('date', [pi]);
  var c = new Channel('id', 'name', 'logo', 'description');

  // var enc = Program.fromJson(json.decode(json.encode(p)));
  var encChn = Channel.fromJson(json.decode(json.encode(c)));

  print(encChn);
}

void _setTargetPlatformForDesktop() async {
  await Parse().initialize(PARSE_APP_ID, PARSE_APP_URL,
      masterKey: MASTER_KEY, debug: true);

  final ParseResponse apiResponse = await ParseObject('Comment').getAll();

  if (apiResponse.success && apiResponse.count > 0) {
    for (final ParseObject testObject in apiResponse.results) {
      print(keyAppName + ': ' + testObject.toString());
    }
  }

  print(apiResponse.count);

  var comment = ParseObject('Comment')
    ..set('content', 'test content')
    ..set('likes', 65);
  await comment.save();

  print(apiResponse.count);
}
