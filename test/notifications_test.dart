// Regression tests for lib/notifications.dart, covering the
// "minutes before not retroactively rescheduled existing reminders" bug.
//
// Background: `reScheduleNotifications` previously drove its side-effecting
// cancel/reschedule work through `Iterable.map(...)`, whose return value was
// discarded. Dart `map` is lazy, so the callbacks ran zero times: no existing
// notification was cancelled or recreated, so already-scheduled reminders kept
// firing at the old lead time. These tests assert that the function now
// eagerly cancels and reschedules every cached notification.
//
// The reschedule path also requires `scheduleNotification` to actually reach
// the plugin. A separate latent regression (commit 63eb2d5) migrated
// `.schedule(...)` to `.zonedSchedule(...)` (whose parameter is a `TZDateTime`)
// while still passing a plain `DateTime`, which raised
// `type 'DateTime' is not a subtype of type 'TZDateTime'` and made every
// scheduling attempt throw. That is fixed by converting the computed instant
// to a UTC `TZDateTime` (preserving the same absolute fire time the deprecated
// `schedule` API used), so the reschedule path is actually exercised here.

import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';

import 'package:tvcubana/notifications.dart';

// A stand-in for the global `flutterLocalNotificationsPlugin` that records
// every cancel / zonedSchedule / pendingNotificationRequests call instead of
// talking to the platform. We override at the FlutterLocalNotificationsPlugin
// level, so the test never reaches a real method channel (and never needs
// timezone-database initialisation, since the production code now hands us a
// real `TZDateTime`).
class _RecordingPlugin extends FlutterLocalNotificationsPlugin {
  _RecordingPlugin() : super.private(FakePlatform(operatingSystem: 'android'));

  final List<int> canceledIds = <int>[];
  final List<int> scheduledIds = <int>[];
  final List<String> scheduledTitles = <String>[];
  final List<String> scheduledBodies = <String>[];
  final List<TZDateTime> scheduledDateTimes = <TZDateTime>[];

  @override
  Future<void> cancel(int id, {String tag}) async {
    canceledIds.add(id);
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String title,
    String body,
    TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    UILocalNotificationDateInterpretation uiLocalNotificationDateInterpretation,
    bool androidAllowWhileIdle,
    String payload,
    DateTimeComponents matchDateTimeComponents,
  }) async {
    scheduledIds.add(id);
    scheduledTitles.add(title);
    scheduledBodies.add(body);
    scheduledDateTimes.add(scheduledDate);
  }

  @override
  Future<List<PendingNotificationRequest>>
      pendingNotificationRequests() async => <PendingNotificationRequest>[];
}

void main() {
  _RecordingPlugin plugin;

  // Seed SharedPreferences with a `minutesBefore` (the value TouchSpin.onChanged
  // would already have persisted) and a JSON `notifications` list whose shape
  // matches what `storeNotificationsInCache` writes (see Notification.toJson).
  void seedCache({
    int minutesBefore,
    List<Map<String, dynamic>> notifications,
  }) {
    SharedPreferences.setMockInitialValues(<String, dynamic>{
      'minutesBefore': minutesBefore,
      'notifications': notifications == null ? null : jsonEncode(notifications),
    });
  }

  // `reScheduleNotifications` is declared `void ... async` (its static type is
  // `void`), so it cannot be cleanly awaited. It kicks off the cancel loop and
  // a fire-and-forget reschedule loop and returns. Pump the real event loop so
  // those microtasks complete before we assert on the recorded calls.
  Future<void> drainEventLoop() async {
    for (int i = 0; i < 50; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  List<Map<String, dynamic>> threeNotifications() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 11,
          'programItemId': 'p1',
          'dateStart': '2099-01-01',
          'timeStart': '12:00',
          'channelName': 'Cubavision',
          'programTitle': 'Noticias',
        },
        <String, dynamic>{
          'id': 22,
          'programItemId': 'p2',
          'dateStart': '2099-02-02',
          'timeStart': '08:30',
          'channelName': null,
          'programTitle': 'Pelicula',
        },
        <String, dynamic>{
          'id': 33,
          'programItemId': 'p3',
          'dateStart': '2099-03-03',
          'timeStart': '21:15',
          'channelName': 'Tele Rebelde',
          'programTitle': 'Beisbol',
        },
      ];

  setUp(() {
    // Fresh plugin (and thus fresh recording lists) for every test. The
    // production code reads the module-level `flutterLocalNotificationsPlugin`,
    // so we point it at our recording instance.
    plugin = _RecordingPlugin();
    flutterLocalNotificationsPlugin = plugin;
  });

  test(
      'reScheduleNotifications cancels every already-scheduled notification '
      'from the cache', () async {
    seedCache(minutesBefore: 10, notifications: threeNotifications());

    reScheduleNotifications(15);
    await drainEventLoop();

    expect(plugin.canceledIds, <int>[11, 22, 33]);
  });

  test(
      'reScheduleNotifications reschedules every notification from the cache, '
      'preserving order, ids and titles', () async {
    seedCache(minutesBefore: 10, notifications: threeNotifications());

    reScheduleNotifications(15);
    await drainEventLoop();

    expect(plugin.scheduledIds, <int>[11, 22, 33]);
    expect(plugin.scheduledTitles, <String>['Noticias', 'Pelicula', 'Beisbol']);
  });

  test(
      'the rescheduled time is recomputed from the CACHED minutes-before, not '
      'the minsBefore parameter (the plumbing the bug report describes)',
      () async {
    final notifs = threeNotifications();
    // Cache holds the value TouchSpin.onChanged already persisted.
    seedCache(minutesBefore: 5, notifications: notifs);
    // The parameter only feeds the body text; use a different value to make a
    // regression obvious if the parameter were ever wired into the schedule.
    reScheduleNotifications(15);
    await drainEventLoop();

    expect(plugin.scheduledDateTimes.length, notifs.length);
    for (int i = 0; i < notifs.length; i++) {
      final base =
          DateTime.parse('${notifs[i]['dateStart']} ${notifs[i]['timeStart']}');
      final expected = base.subtract(const Duration(minutes: 5));
      expect(
        plugin.scheduledDateTimes[i].millisecondsSinceEpoch,
        expected.millisecondsSinceEpoch,
        reason: 'scheduled time must reflect the cached minutesBefore (5), '
            'not the minsBefore parameter (15)',
      );
    }
  });

  test(
      'notification body text is built from the passed minsBefore parameter '
      'and the channel name', () async {
    seedCache(minutesBefore: 5, notifications: threeNotifications());

    reScheduleNotifications(15);
    await drainEventLoop();

    expect(plugin.scheduledBodies, <String>[
      'Por Cubavision en 15 minutos.',
      ' en 15 minutos.', // channelName null -> empty channel prefix
      'Por Tele Rebelde en 15 minutos.',
    ]);
  });

  test('a minsBefore of 0 produces an "ahora!" body', () async {
    seedCache(minutesBefore: 0, notifications: threeNotifications());

    reScheduleNotifications(0);
    await drainEventLoop();

    expect(plugin.scheduledBodies, <String>[
      'Por Cubavision ahora!',
      ' ahora!',
      'Por Tele Rebelde ahora!',
    ]);
  });

  test(
      'reScheduleNotifications is a safe no-op when no notifications are '
      'cached', () async {
    seedCache(minutesBefore: 10, notifications: null);

    reScheduleNotifications(15);
    await drainEventLoop();

    expect(plugin.canceledIds, <int>[]);
    expect(plugin.scheduledIds, <int>[]);
  });

  test(
      'reScheduleNotifications fires exactly one cancel and one reschedule '
      'per cached notification (no duplicates, none skipped)', () async {
    seedCache(minutesBefore: 10, notifications: threeNotifications());

    reScheduleNotifications(15);
    await drainEventLoop();

    expect(plugin.canceledIds.length, 3,
        reason: 'every notification must be cancelled exactly once');
    expect(plugin.scheduledIds.length, 3,
        reason: 'every notification must be rescheduled exactly once');
    expect(plugin.canceledIds.toSet(), plugin.scheduledIds.toSet(),
        reason: 'the same set of ids must be cancelled and rescheduled');
  });

  test(
      'calling reScheduleNotifications twice does not accumulate stale '
      'schedules between runs (each run cancels before rescheduling)',
      () async {
    seedCache(minutesBefore: 10, notifications: threeNotifications());

    reScheduleNotifications(15);
    await drainEventLoop();
    final firstRunCancels = List<int>.from(plugin.canceledIds);
    final firstRunSchedules = List<int>.from(plugin.scheduledIds);

    reScheduleNotifications(20);
    await drainEventLoop();

    expect(firstRunCancels, <int>[11, 22, 33]);
    expect(firstRunSchedules, <int>[11, 22, 33]);
    // Second run cancels every cached notification again, then reschedules
    // every cached notification again.
    expect(plugin.canceledIds, <int>[11, 22, 33, 11, 22, 33]);
    expect(plugin.scheduledIds, <int>[11, 22, 33, 11, 22, 33]);
  });
}
