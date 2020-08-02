import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notification {
  int id;
  String programItemId;
  String dateStart;
  String timeStart;

  Notification(this.id, this.programItemId, this.dateStart, this.timeStart);

  Notification.fromJson(Map<String, dynamic> pjson)
      : id = pjson['id'],
        programItemId = pjson['programItemId'],
        dateStart = pjson['dateStart'],
        timeStart = pjson['timeStart'];

  Map<String, dynamic> toJson() => {
        'id': id,
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

var randomInt = new Random();

void addNotification(String programItemId, String dateStart, String timeStart,
    String programTitle, String channelName) async {
  int id = randomInt.nextInt(1000);
  notifications = await retrieveNotificationsFromCache();
  notifications.add(Notification(id, programItemId, dateStart, timeStart));
  storeNotificationsInCache(notifications);

  var chanName = channelName == null ? '' : 'Por ' + channelName;
  scheduleNotification(id, DateTime.parse('$dateStart $timeStart'),
      programTitle, '$chanName en 10 minutos.');
}

void deleteNotification(String programItemId) async {
  notifications = await retrieveNotificationsFromCache();
  int idNotif =
      notifications.indexWhere((notif) => notif.programItemId == programItemId);
  notifications.removeWhere((notif) => notif.programItemId == programItemId);
  storeNotificationsInCache(notifications);

  removeSchedNotification(idNotif);
}

void deleteOldNotifications() async {
  notifications = await retrieveNotificationsFromCache();
  List<Notification> oldNotifications = notifications
      .where((notif) => DateTime.parse(notif.dateStart + ' ' + notif.timeStart)
          .isBefore(DateTime.now()))
      .toList();
  notifications = notifications
      .where((notif) => DateTime.parse(notif.dateStart + ' ' + notif.timeStart)
          .isAfter(DateTime.now()))
      .toList();
  storeNotificationsInCache(notifications);

  oldNotifications.map((e) => removeSchedNotification(e.id));
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
      importance: Importance.Max,
      priority: Priority.High,
      vibrationPattern: vibrationPattern,
      enableLights: true,
      enableVibration: true,
      styleInformation: DefaultStyleInformation(true, true),
      playSound: true,
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
          androidAllowWhileIdle: true, payload: 'item')
      .then((value) => print('Notification executed'))
      .catchError((err) => print('Error ' + err));

  flutterLocalNotificationsPlugin.pendingNotificationRequests().then((value) {
    value.forEach((pnr) {
      print([pnr.id, pnr.title, pnr.body, pnr.payload]);
    });
  });
}

void removeSchedNotification(int idNotification) {
  flutterLocalNotificationsPlugin.cancel(idNotification);
}
