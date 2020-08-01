import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notification {
  String programItemId;
  String dateStart;
  String timeStart;

  Notification(this.programItemId, this.dateStart, this.timeStart);

  Notification.fromJson(Map<String, dynamic> pjson)
      : programItemId = pjson['programItemId'],
        dateStart = pjson['dateStart'],
        timeStart = pjson['timeStart'];

  Map<String, dynamic> toJson() => {
        'programItemId': programItemId,
        'dateStart': dateStart,
        'timeStart': timeStart,
      };
}

List<Notification> notifications = [];

bool existNotificationForProgram(String programId) {
  return notifications
          .indexWhere((notif) => notif.programItemId == programId) !=
      -1;
}

void addNotification(String programItemId, String dateStart, String timeStart,
    String programTitle, String channelName) async {
  notifications = await retrieveNotificationsFromCache();
  notifications.add(Notification(programItemId, dateStart, timeStart));
  storeNotificationsInCache(notifications);

  scheduleNotification(100, DateTime.parse('$dateStart $timeStart'),
      programTitle, 'Por $channelName en 10 minutos.');
}

Future<void> storeNotificationsInCache(List<Notification> notifications) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('notifications',
      json.encode(notifications.map((e) => e.toJson()).toList()));
}

Future<List<Notification>> retrieveNotificationsFromCache() async {
  // print('start:retrieveNotificationsFromCache');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var notifStr = prefs.getString('notifications');
  notifications = new List<Notification>();
  if (notifStr == null) {
    //TODO: If notifications is the empty list then the next line can be reduced.
    prefs.setString('notifications',
        json.encode(notifications.map((e) => e.toJson()).toList()));
  } else {
    var decodedStr = json.decode(notifStr);
    notifications =
        (decodedStr as List).map((e) => Notification.fromJson(e)).toList();
  }
  // var decodedStr = json.decode(notifStr);
  // var notifications = (decodedStr as List).map((e) => Notification.fromJson(e)).toList();
  // print('end:retrieveNotificationsFromCache');
  return notifications;
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> initializeNotifications() async {
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid = new AndroidInitializationSettings('icon');

  var initializationSettings =
      InitializationSettings(initializationSettingsAndroid, null);

  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (payload) => null);
}

void scheduleNotification(
    int id, DateTime dateTime, String title, String body) {
  var vibrationPattern = Int64List(4);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 1000;
  vibrationPattern[2] = 5000;
  vibrationPattern[3] = 2000;

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id_TVCubana', 'channel_TVCubana', 'channel_TVCubana_description',
      vibrationPattern: vibrationPattern,
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500);

  var platformChannelSpecifics =
      NotificationDetails(androidPlatformChannelSpecifics, null);

  var scheduledNotificationDateTime =
      dateTime.subtract(new Duration(minutes: 10));

  flutterLocalNotificationsPlugin
      .schedule(id, title, body, scheduledNotificationDateTime,
          platformChannelSpecifics,
          androidAllowWhileIdle: true, payload: 'item x')
      .then((value) => print('Notification executed'))
      .catchError((err) => print('Error ' + err));

  flutterLocalNotificationsPlugin.pendingNotificationRequests().then((value) {
    value.forEach((pnr) {
      print([pnr.id, pnr.title, pnr.body, pnr.payload]);
    });
  });
}
