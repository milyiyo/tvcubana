import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tvcubana/models/ProgramItem.dart';
import 'package:tvcubana/notifications.dart' as tvc;
import 'package:tvcubana/widgets/ProgramItemCard.dart';

/// A fake [FlutterLocalNotificationsPlatform] that records the ids passed to
/// [cancel] instead of talking to the OS. Installed as
/// [FlutterLocalNotificationsPlatform.instance] so the production
/// [FlutterLocalNotificationsPlugin.cancel] dispatches into it on the test
/// host (where no Android/iOS platform implementation is registered).
class _RecordingNotificationsPlatform
    extends FlutterLocalNotificationsPlatform {
  final List<int> cancelledIds = <int>[];

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {}
}

/// Mock cache: three notifications with ids (741, 23, 502). The program the
/// tests unsubscribe from is `prog-B`, stored at **list index 1** but with real
/// scheduled id **23**, so the list index and the real id are deliberately
/// different.
Map<String, dynamic> _seededCacheValues() {
  return <String, dynamic>{
    'notifications': json.encode(<Map<String, dynamic>>[
      <String, dynamic>{
        'id': 741,
        'programItemId': 'prog-A',
        'dateStart': '2099-01-01',
        'timeStart': '12:00',
        'channelName': 'C1',
        'programTitle': 'A'
      },
      <String, dynamic>{
        'id': 23,
        'programItemId': 'prog-B',
        'dateStart': '2099-01-02',
        'timeStart': '12:00',
        'channelName': 'C2',
        'programTitle': 'B'
      },
      <String, dynamic>{
        'id': 502,
        'programItemId': 'prog-C',
        'dateStart': '2099-01-03',
        'timeStart': '12:00',
        'channelName': 'C3',
        'programTitle': 'C'
      },
    ]),
    'minutesBefore': 10,
  };
}

ProgramItem _progB() => ProgramItem('prog-B', '', '', '', '', '2099-01-02',
    '2099-01-02', '12:00', '13:00', 'B', <String>[]);

void main() {
  _RecordingNotificationsPlatform recorder;

  setUp(() {
    recorder = _RecordingNotificationsPlatform();
    FlutterLocalNotificationsPlatform.instance = recorder;
    tvc.flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    SharedPreferences.setMockInitialValues(_seededCacheValues());
    // Reset the module-level list; tests that need it seeded call
    // retrieveNotificationsFromCache() themselves.
    tvc.notifications = <tvc.Notification>[];
  });

  group('deleteNotification', () {
    test(
        'cancels the scheduled notification by its real stored id, not the '
        'list index', () async {
      await tvc.deleteNotification('prog-B');

      // prog-B is at list index 1, but its real scheduled id (used in
      // zonedSchedule) is 23. A regression that passes the index to cancel
      // would produce [1] here.
      expect(recorder.cancelledIds, <int>[23]);
      expect(recorder.cancelledIds, isNot(contains(1)));
    });

    test('does not call cancel when no matching notification exists', () async {
      expect(recorder.cancelledIds, isEmpty);

      await tvc.deleteNotification('prog-DOES-NOT-EXIST');

      // A missing program must not reach cancel (the fix guards with
      // `if (target != null)`); a regression would call cancel(-1) because
      // indexWhere returns -1.
      expect(recorder.cancelledIds, isEmpty);
    });
  });

  group('unsubscribe end-to-end via NotificationButton', () {
    testWidgets(
        'tapping the active bell cancels the scheduled notification by '
        'its real id', (WidgetTester tester) async {
      // NotificationButton reads the module-level `notifications` list, so seed
      // it from the mock cache before building the widget.
      tvc.notifications = await tvc.retrieveNotificationsFromCache();
      expect(tvc.existNotificationForProgram('prog-B'), isTrue);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NotificationButton(
            programItem: _progB(),
            channelName: 'C2',
          ),
        ),
      ));
      await tester.pump();

      // The active bell is shown because a reminder exists for prog-B.
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);

      await tester.tap(find.byIcon(Icons.notifications_active));
      await tester.pumpAndSettle();

      // The user-facing unsubscribe path must reach cancel() with the real id.
      expect(recorder.cancelledIds, <int>[23]);
    });
  });
}
