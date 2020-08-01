import 'dart:convert';

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

void addNotification(
    String programItemId, String dateStart, String timeStart) async {
  notifications = await retrieveNotificationsFromCache();
  notifications.add(Notification(programItemId, dateStart, timeStart));
  print(notifications[0]);
  storeNotificationsInCache(notifications);

}

Future<void> storeNotificationsInCache(List<Notification> notifications) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('notifications', json.encode(notifications.map((e) => e.toJson()).toList()));
}

Future<List<Notification>> retrieveNotificationsFromCache() async {
  // print('start:retrieveNotificationsFromCache');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var notifStr = prefs.getString('notifications');
  notifications = new List<Notification>();
  if (notifStr == null) {
    //TODO: If notifications is the empty list then the next line can be reduced.
    prefs.setString('notifications', json.encode(notifications.map((e) => e.toJson()).toList()));
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
